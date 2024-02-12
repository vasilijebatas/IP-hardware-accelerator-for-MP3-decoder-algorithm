#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <vector>
#include<cstdlib>
using namespace std;
		
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>
#include <string.h>
#include <math.h>


using namespace std;

int block_type, ch, gr, start;
int ready;
int dinb;

int *doutb;


void write_ip (const int block_type, const int gr, const int ch, const int start);
void write_bram(int dinb);
void read_ip();
void read_bram();

int main ()
{	

	write_bram(15);
	cout<<"Sending data to BRAM..." << endl;


    write_ip(0,0,0,1);

	cout << "Initialisation done by software" << endl;


	read_bram();


    cout << "Reading from BRAM" << endl;
	

				
	return 0;
}



void write_ip (const int block_type, const int gr, const int ch, const int start)
{
	FILE *imdct;
	imdct = fopen ("/dev/xlnx,imdct", "w");
	fprintf (imdct, "%d, %d, %d, %d\n", block_type, gr, ch, start);
	printf ("[APP] %d, %d, %d, %d\n", block_type, gr, ch, start);
	fclose (imdct);
}

void write_bram(int dinb)
{
    FILE *bram; 

    
    

    // Check if the file was opened successfully
    if (bram == NULL) {
        perror("Error opening file");
        return;
    }


    for (int i = 0; i < 576; i++)
    {
    	 bram = fopen ("/dev/xlnx,bram", "w");
        fprintf(bram, "%d %d",i,dinb);
		fclose(bram);
    }

  

}

void read_ip()
{
	FILE *imdct;
	imdct = fopen ("/dev/xlnx,imdct", "r");
	fscanf (imdct, "ready = %d\n", &ready);
	fclose (imdct);
}

void read_bram()
{
	FILE *bram;


   for(int j = 0; j < 4000 ; j++)
   {
	bram = fopen ("/dev/xlnx,bram", "r");
	fscanf (bram, "%d", &doutb);
	fclose (bram);

   }
		
}
	