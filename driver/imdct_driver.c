#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/irq.h>
#include <linux/platform_device.h>
#include <asm/io.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/io.h>

#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

#include <linux/version.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <linux/delay.h>

#include <linux/errno.h>
#include <linux/wait.h>
#include <linux/semaphore.h>

MODULE_LICENSE("Dual BSD/GPL");
MODULE_DESCRIPTION("Test Driver for IMDCT.");
MODULE_ALIAS("custom:imdct");
MODULE_AUTHOR ("Gotham Team");

#define DEVICE_NAME "imdct" 
#define DRIVER_NAME "imdct_driver"


//buffer size
#define BUFF_SIZE 576

//addresses for registers
#define START_REG     0x04
#define GR_REG        0x08
#define CH_REG        0x12
#define BLOCKTYPE_REG 0x16
#define READY_REG     0x00
#define RST_REG       0x18


//*************************************************************************
static int imdct_probe(struct platform_device *pdev);
static int imdct_open(struct inode *i, struct file *f);
static int imdct_close(struct inode *i, struct file *f);
static ssize_t imdct_read(struct file *f, char __user *buf, size_t len, loff_t *off);
static ssize_t imdct_write(struct file *f, const char __user *buf, size_t count, loff_t *off);

static int __init imdct_init(void);
static void __exit imdct_exit(void);
static int imdct_remove(struct platform_device *pdev);

unsigned int block_type, ch, gr;
unsigned int ready, start;
int done;
int endRead = 0;



DECLARE_WAIT_QUEUE_HEAD(readQ);
DECLARE_WAIT_QUEUE_HEAD(writeQ);

// @brief This struct contains our file operations.
struct file_operations my_fops =
{
	.owner = THIS_MODULE,
	.open = imdct_open,
	.read = imdct_read,
	.write = imdct_write,
	.release = imdct_close,
};



static struct of_device_id device_of_match[] = {
	{ .compatible = "xlnx,IMDCT-v1-0-1.0", },
	{ .compatible = "xlnx,axi-bram-ctrl-4.1", }, //bram 
	{ /* end of list */ },
};

static struct platform_driver my_driver = {
    .driver = {
	.name = DRIVER_NAME,
	.owner = THIS_MODULE,
	.of_match_table	= device_of_match,
    },
    .probe		= imdct_probe,
    .remove	= imdct_remove,
};

struct device_info {
    unsigned long mem_start;
    unsigned long mem_end;
    void __iomem *base_addr;
};

static struct device_info *imdct = NULL;
static struct device_info *bram = NULL;

MODULE_DEVICE_TABLE(of, device_of_match);

static dev_t my_dev_id;
static struct class *my_class;
static struct cdev *my_cdev;

int device_fsm = 0;

static int imdct_probe(struct platform_device *pdev)
{
    
    struct resource *r_mem;
    int rc = 0;

    printk(KERN_INFO "Probing\n");

    r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!r_mem) {
	printk(KERN_ALERT "invalid address\n");
	return -ENODEV;
    }

	switch (device_fsm)
    {
		case 0: // device imdct
		  imdct = (struct device_info *) kmalloc(sizeof(struct device_info), GFP_KERNEL);
		  if (!imdct)
			{
			  printk(KERN_ALERT "Could not allocate imdct device\n");
			  return -ENOMEM;
			}
		  imdct->mem_start = r_mem->start;
		  imdct->mem_end   = r_mem->end;
		  if(!request_mem_region(imdct->mem_start, imdct->mem_end - imdct->mem_start+1, DRIVER_NAME))
			{
			  printk(KERN_ALERT "Couldn't lock memory region at %p\n",(void *)imdct->mem_start);
			  rc = -EBUSY;
			  goto error1;
			}
		  imdct->base_addr = ioremap(imdct->mem_start, imdct->mem_end - imdct->mem_start + 1);
		  if (!imdct->base_addr)
			{
			  printk(KERN_ALERT "[PROBE]: Could not allocate imdct iomem\n");
			  rc = -EIO;
			  goto error2;
			}
      ++device_fsm;
		  printk(KERN_INFO "[PROBE]: Finished probing imdct.\n");
		  return 0;
		  error2:
			release_mem_region(imdct->mem_start, imdct->mem_end - imdct->mem_start + 1);
		  error1:
			return rc;
		  break;

		case 1: // device bram
		  bram = (struct device_info *) kmalloc(sizeof(struct device_info), GFP_KERNEL);
		  if (!bram)
			{
			  printk(KERN_ALERT "Could not allocate bram device\n");
			  return -ENOMEM;
			}
		  bram->mem_start = r_mem->start;
		  bram->mem_end   = r_mem->end;
		  if(!request_mem_region(bram->mem_start, bram->mem_end - bram->mem_start+1, DRIVER_NAME))
			{
			  printk(KERN_ALERT "Couldn't lock memory region at %p\n",(void *)bram->mem_start);
			  rc = -EBUSY;
			  goto error3;
			}
		  bram->base_addr = ioremap(bram->mem_start, bram->mem_end - bram->mem_start + 1);
		  if (!bram->base_addr)
			{
			  printk(KERN_ALERT "[PROBE]: Could not allocate bram iomem\n");
			  rc = -EIO;
			  goto error4;
			}
		  printk(KERN_INFO "[PROBE]: Finished probing bram.\n");
		  return 0;
		  error4:
			release_mem_region(bram->mem_start, bram->mem_end - bram->mem_start + 1);
		  error3:
			return rc;
		  break;
          default:
		  printk(KERN_INFO "[PROBE] Device FSM in illegal state. \n");
		  return -1;
		}
  printk(KERN_INFO "Succesfully probed driver\n");
  return 0;
    }




static int imdct_remove(struct platform_device *pdev)
{
  
  switch (device_fsm)
    {
    case 0: //device imdct
      printk(KERN_ALERT "imdct device platform driver removed\n");
      iowrite32(0, imdct->base_addr);
      iounmap(imdct->base_addr);
      release_mem_region(imdct->mem_start, imdct->mem_end - imdct->mem_start + 1);
      kfree(imdct);
      break;

    case 1: //device bram
      printk(KERN_ALERT "bram device platform driver removed\n");
      iowrite32(0, bram->base_addr);
      iounmap(bram->base_addr);
      release_mem_region(bram->mem_start, bram->mem_end - bram->mem_start + 1);
      kfree(bram);
      --device_fsm;
      break;
     default:
      printk(KERN_INFO "[REMOVE] Device FSM in illegal state. \n");
      return -1;
    }
  printk(KERN_INFO "Succesfully removed driver\n");
  return 0;
}	
























//***************************************************
// OPEN & CLOSE
//***************************************************

static int imdct_open(struct inode *i, struct file *f)
{
    printk("imdct opened\n");
    return 0;
}
static int imdct_close(struct inode *i, struct file *f)
{
    printk("imdct closed\n");
    return 0;
}
unsigned int doutb = 0;



ssize_t imdct_write(struct file *pfile, const char __user *buffer, size_t length, loff_t *offset)
{ 
  char buff[BUFF_SIZE];
  int val = 0;
  int pos = 0;
  int minor = MINOR(pfile->f_inode->i_rdev);
  int size_of_buff;


  size_of_buff = sizeof(buff)/sizeof(buff[0]);

  if(copy_from_user(buff, buffer, length))
  {

   return -EFAULT;
   buff[length-1] = '\0';
  }

  switch(minor)
  {
      case 0 :
    
      sscanf(buff,"%d %d %d %d", &block_type, &gr, &ch, &start);
      iowrite32(start, imdct->base_addr + START_REG);
		  udelay(1000);
      if(start == 1)
      {
      printk(KERN_INFO "[WRITE] Succesfully started IMDCT device\n");
      }
      iowrite32(block_type, imdct->base_addr + BLOCKTYPE_REG);
		  iowrite32(gr, imdct->base_addr + CH_REG);
		  iowrite32(ch, imdct->base_addr + GR_REG);
      printk(KERN_INFO "[WRITE] Succesfully initialized IMDCT device.\n BLOCK TYPE =  %u\n  GR = %u\n  CH =  %u\n", block_type, ch, gr);

      break;
      case 1 :

      sscanf(buff, "%d %d", &pos, &val);
      iowrite32(val, bram->base_addr + 4*pos);
      printk(KERN_INFO "[WRITE] Succesfully wrote into BRAM device.\n Position = %d \n Value = %d\n", pos, val); 
      break;


      default:

      printk(KERN_INFO "[WRITE] Invalid minor. \n");

  }
  
   return length;
} 
ssize_t imdct_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset) 
{ 
  char buff[BUFF_SIZE];
  long int len = 0;
  int minor = MINOR(pfile->f_inode->i_rdev); 
  int value;


  if(endRead)
  {
    endRead = 0;
    printk(KERN_INFO"Succesfully read\n");
    return 0;
  }


  switch(minor)
  {
      case 0 :
      printk(KERN_INFO "[READ] Reading from IMDCT device. \n");
      block_type = ioread32(imdct -> base_addr + BLOCKTYPE_REG);
      printk(KERN_INFO "[READ] Succesfully read BLOCK_TYPE. \n");
      ready = ioread32(imdct -> base_addr + READY_REG);
      len = scnprintf(buff, BUFF_SIZE, "ready = %d, block_type = %d\n", ready,block_type);   
      if(copy_to_user(buffer, buff, len))
      { 
          
      return -EFAULT;  
       endRead = 1;  
      }
      break;
      case 1 :

      
            if(doutb < 576)
            {
                value = ioread32(bram -> base_addr + 4*doutb);
                len = scnprintf(buff, BUFF_SIZE, "%d\n", value);
            }
          doutb++;
              
      if(copy_to_user(buffer, buff, len))
      {
          
      return -EFAULT;  
       endRead = 1;  
      }
      break;


      default:

      printk(KERN_INFO "[WRITE] Invalid minor. \n");

  }
  
   return len;
}



static int __init imdct_init(void)
{
   printk(KERN_INFO "\n");
   printk(KERN_INFO "IMDCT driver starting insmod.\n");

   ready = 1;
   done = 0;
   
   if (alloc_chrdev_region(&my_dev_id, 0, 2, "imdct_region") < 0){
      printk(KERN_ERR "failed to register char device\n");
      return -1;
   }
   printk(KERN_INFO "char device region allocated\n");

   my_class = class_create(THIS_MODULE, "imdct_class");
   if (my_class == NULL){
      printk(KERN_ERR "failed to create class\n");
      goto fail_0;
   }
   printk(KERN_INFO "class created\n");

   if (device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id),0), NULL, "xlnx,imdct") == NULL) {
      printk(KERN_ERR "failed to create device IMDCT\n");
      goto fail_1;
   }
   printk(KERN_INFO "Device created - IMDCT\n");

   if (device_create(my_class, NULL, MKDEV(MAJOR(my_dev_id),1), NULL, "xlnx,bram") == NULL) {
     printk(KERN_ERR "failed to create device bram\n");
     goto fail_2;
   }
   printk(KERN_INFO "Device created - BRAM\n");

   
	my_cdev = cdev_alloc();
	my_cdev->ops = &my_fops;
	my_cdev->owner = THIS_MODULE;

	if (cdev_add(my_cdev, my_dev_id, 2) == -1)
	{
      printk(KERN_ERR "failed to add cdev\n");
      goto fail_3;
	}
   printk(KERN_INFO "cdev added\n");
   printk(KERN_INFO "IMDCT driver initialized.\n");

   return platform_driver_register(&my_driver);

   fail_3:
     device_destroy(my_class, MKDEV(MAJOR(my_dev_id),1));
   fail_2:
     device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
   fail_1:
      class_destroy(my_class);
   fail_0:
      unregister_chrdev_region(my_dev_id, 1);
   return -1;
}



static void __exit imdct_exit(void) {

    printk(KERN_INFO "IMDCT driver starting rmmod.\n");
	  platform_driver_unregister(&my_driver);
    cdev_del(my_cdev);

    device_destroy(my_class, MKDEV(MAJOR(my_dev_id),1));
    device_destroy(my_class, MKDEV(MAJOR(my_dev_id),0));
    
    class_destroy(my_class);
    unregister_chrdev_region(my_dev_id, 1);
    printk(KERN_INFO "IMDCT driver closed.\n");


}


module_init(imdct_init);
module_exit(imdct_exit);
