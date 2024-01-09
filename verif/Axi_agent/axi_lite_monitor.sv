`ifndef AXI_LITE_MONITOR_SV
 `define AXI_LITE_MONITOR_SV

class axi_lite_monitor extends uvm_monitor;
   //Control fileds
   bit checks_enable = 1;
   bit coverage_enable = 1;
   bit [31:0] address;

   virtual interface axi_lite_if vif;
   int 	   id;

   uvm_analysis_port #(axi_lite_item) item_collected_port;
   
    axi_lite_item axi_lite_seq_item,item_clone1;
   

   `uvm_component_utils_begin(axi_lite_monitor)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
      `uvm_field_int(id, UVM_DEFAULT) 
   `uvm_component_utils_end

   //*******************************************************************************
	
	//coverage can go here 
	covergroup write_address;
		option.per_instance = 1;
      	write_address: coverpoint address{
     		bins start = {4};
  		}
		data_write: coverpoint vif.s_axi_wdata {
         	bins start_0 = {0};
         	bins start_1 = {1};
      	}
	endgroup

	covergroup block_type_address;
		option.per_instance = 1;
      	block_type_address: coverpoint address {
         	bins block_type = {16};

  		}
		block_type_data: coverpoint vif.s_axi_wdata {
		 	bins block_type_0 = {4'b0000};
		 	bins block_type_1 = {4'b0001};
		 	bins block_type_2 = {4'b0010};
		 	bins block_type_3 = {4'b0011};
    	bins block_type_4 = {4'b0100};
		 	bins block_type_5 = {4'b0101};
		 	bins block_type_6 = {4'b0110};
		 	bins block_type_7 = {4'b0111};
    	bins block_type_8 = {4'b1000};
		 	bins block_type_9 = {4'b1001};
		 	bins block_type_10 = {4'b1010};
		 	bins block_type_11 = {4'b1011};
    	bins block_type_12 = {4'b1100};
		 	bins block_type_13 = {4'b1101};
		 	bins block_type_14 = {4'b1110};
		 	bins block_type_15 = {4'b1111};        
      	}
      	block_type_cross: cross block_type_address, block_type_data;      	
	endgroup 

	covergroup gr_address;
		option.per_instance = 1;
      	gr_address: coverpoint address { 
     		bins gr = {8};
  		}
		gr_data: coverpoint vif.s_axi_wdata {
		 	    bins gr_0 = {0};
         	bins gr_1 = {1};     
      	}
      	gr_cross: cross gr_address, gr_data;
	endgroup 

	covergroup ch_address;
		option.per_instance = 1;
      	ch_address: coverpoint address { 
     		bins ch = {12};
  		}
		ch_data: coverpoint vif.s_axi_wdata {
		 	    bins ch_0 = {0};
         	bins ch_1 = {1};     
      	}
      	ch_cross: cross ch_address, ch_data;
	endgroup 
	
	covergroup ready;
		option.per_instance = 1;
      	ready_addr: coverpoint address { 
     		bins ready = {0};
  		}
		valid_bins: coverpoint vif.s_axi_awvalid {
		 	    bins valid_0 = {0};
         	bins valid_1 = {1};     
      	}
      	ready: cross ready_addr, valid_bins;
	endgroup 

   	covergroup read_address;
      	option.per_instance = 1;
      	read_address: coverpoint address {
         	bins start = {4};
         	bins block_type = {16};
     		  bins gr = {8};
         	bins ch = {12};
         	bins ready = {0};    
      	}     
		data_read: coverpoint vif.s_axi_rdata{
         	bins data_ready = {1};
         	bins data_not_ready = {0};
      	}
   	endgroup
   
//**********************************************************************************



   
   function new (string name = "axi_lite_monitor", uvm_component parent = null);
      super.new(name,parent);
      //axi_lite_seq_item = new();
      item_collected_port = new("item_collected_port", this);
      write_address = new();
  		read_address = new();
		  block_type_address = new();
		  gr_address = new();
		  ch_address = new();
		  ready = new();
   endfunction // new
   
   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
         `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
   endfunction // connect_phase
   

   
   task main_phase(uvm_phase phase);
     //axi_lite_seq_item = axi_lite_seq_item::type_id::create("axi_lite_seq_item",this);
    
    
     forever begin
	
	 if (vif.reset_n == 'b0) @(posedge vif.reset_n);
	 if (vif.s_axi_awvalid == 'b1) begin
	   
	   axi_lite_seq_item = axi_lite_item::type_id::create("axi_lite_seq_item",this);
	   
	   axi_lite_seq_item.write = 1; //write	    
	   axi_lite_seq_item.address  = vif.s_axi_awaddr[4:0];
	   $display("Collected ...: Address :=  %d \n", axi_lite_seq_item.address);
	   @(negedge vif.s_axi_wvalid);
	   axi_lite_seq_item.data  = vif.s_axi_wdata;
	   $display("Collected ...: Data :=  %d \n", axi_lite_seq_item.data);
	   @(posedge vif.s_axi_wvalid);
	   
	
	   $cast(item_clone1, axi_lite_seq_item.clone());
	   item_collected_port.write(item_clone1);

	 end
	 else if (vif.s_axi_arvalid == 'b1) begin
     read_address.sample();
	   axi_lite_seq_item = axi_lite_item::type_id::create("axi_lite_seq_item",this);
	   axi_lite_seq_item.read = 1;	    //read
	   axi_lite_seq_item.address  = vif.s_axi_araddr[4:0];
	   $display("Collected ...: Address :=  %d \n", axi_lite_seq_item.address);
	   @(negedge vif.s_axi_rvalid);
	   axi_lite_seq_item.data  = vif.s_axi_rdata;
	   $display("Collected ...: Data :=  %d \n", axi_lite_seq_item.data);
	   @(posedge vif.s_axi_rvalid);
	
	   $cast(item_clone1, axi_lite_seq_item.clone());
	   item_collected_port.write(item_clone1);
	   
	 end
	 @(posedge vif.clock);
	
	
	
     end

   endtask // main_phase



 
     
endclass // axi_lite_monitor


`endif