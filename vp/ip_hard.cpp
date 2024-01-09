#include "ip_hard.h"
#include <tlm>
#include <tlm_utils/tlm_quantumkeeper.h>
#include <sstream>
#include <iomanip>
#include <fstream>
#include "memory.h"

using namespace sc_core;
using namespace sc_dt;
using namespace std;
using namespace tlm;

ofstream file;

SC_HAS_PROCESS(Ip_hard);

Ip_hard::Ip_hard(sc_module_name name) : sc_module(name), soc("soc"), s_memo("s_memo")
{
	soc.register_b_transport(this, &Ip_hard::b_transport);
	SC_METHOD(imdct);
	dont_initialize();
	sensitive << a;


}

void Ip_hard::b_transport(pl_t& pl, sc_time& offset)
{
	tlm_command    cmd  = pl.get_command();
	uint64         addr = pl.get_address();
	unsigned char* data = pl.get_data_ptr();

	switch(cmd)
	{
	case TLM_WRITE_COMMAND:
	{
		switch(addr)
		{
		case HARD_READY:
			ready = *((sc_uint<2>*)data);
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case HARD_START:
			start = *((sc_uint<2>*)data);
			a.notify();
			SC_REPORT_INFO("HARD", "Hard received flag");
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		default:
			pl.set_response_status( TLM_ADDRESS_ERROR_RESPONSE );
			break;
		}
		break;
	}
	case TLM_READ_COMMAND:
	{
		switch(addr)
		{
		case HARD_READY:
			memcpy(data, &ready, sizeof(ready));
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case HARD_START:
			memcpy(data, &start, sizeof(start));
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case HARD_OUT:
			memcpy(data, &output, sizeof(output));
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		default:
			cout << "HARD bad address.\n";
			pl.set_response_status( TLM_ADDRESS_ERROR_RESPONSE );
			break;
		}
		break;
	}
	default:
		pl.set_response_status( TLM_COMMAND_ERROR_RESPONSE );
		SC_REPORT_ERROR("HARD", "TLM bad command");
		break;
	}

}

void Ip_hard::msg(const pl_t& pl)
{
	stringstream ss;
	ss << hex << pl.get_address();
	sc_uint<32> val = *((sc_uint<32>*)pl.get_data_ptr());
	string cmd  = pl.get_command() == TLM_READ_COMMAND ? "read  " : "write ";

	string regname;
	switch(pl.get_address())
	{
	case 0: regname = "READY"; break;
	case 1: regname = "START"; break;
	case 2: regname = "OUT"; break;
	default: regname = "no reg";
	}

	string msg = cmd + "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " " + regname;
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("HARD", msg.c_str());
}
void Ip_hard::imdct()
{
	sc_time loct;

	start = 0;

	pl.set_address(MEM_GR);
	pl.set_command(TLM_READ_COMMAND);
	pl.set_data_length(2);
	pl.set_data_ptr((unsigned char*)&gr);
	SC_REPORT_INFO("Hard", "Hard reads gr from memory");
	s_memo->b_transport(pl, loct);


<<<<<<< HEAD
	loct += sc_time(19, SC_NS);

=======
>>>>>>> Milos
	pl.set_address(MEM_CH);
	pl.set_command(TLM_READ_COMMAND);
	pl.set_data_length(2);
	pl.set_data_ptr((unsigned char*)&ch);
	SC_REPORT_INFO("Hard", "Hard reads ch from memory");
	s_memo->b_transport(pl, loct);


<<<<<<< HEAD
	loct += sc_time(19, SC_NS);

=======
>>>>>>> Milos
	pl.set_address(MEM_BLOCK);
	pl.set_command(TLM_READ_COMMAND);
	pl.set_data_length(2*2);
	pl.set_data_ptr(val_block_type);
	SC_REPORT_INFO("Hard", "Hard reads block_type from memory");
	s_memo->b_transport(pl, loct);
	
	//array to 2d matrix
	for (int i = 0; i < 4; i++) {
        block_type[i / 2][i % 2] = val_block_type[i];
    }


<<<<<<< HEAD
	loct += sc_time(19, SC_NS);

=======
>>>>>>> Milos
	pl.set_address(MEM_SAMPLES);
	pl.set_command(TLM_READ_COMMAND);
	pl.set_data_length(2*2*576*sizeof(sc_fixed<32,16>));
	pl.set_data_ptr(val_samples);
	SC_REPORT_INFO("Hard", "Hard reads samples from memory");
	s_memo->b_transport(pl, loct);

	//array to 3d matrix
	for (int c = 0; c < 2; c++) {
        for (int s = 0; s < 2; s++) {
            for (int f = 0; f < 576; f++) {
                memcpy(&samples[c][s][f], &val_samples[(c * 2 * 576 + s * 576 + f) * sizeof(sc_fixed<32,16>)], sizeof(sc_fixed<32,16>));
            }
        }
    }


<<<<<<< HEAD
	loct += sc_time(19, SC_NS);
=======
>>>>>>> Milos

	int cnt = 0;

    //IMDCT
	sc_fixed<16,2> sample_block[36];
	const int n = block_type[gr][ch] == 2 ? 12 : 36;
	cnt++;
	const int half_n = n / 2;
	int sample = 0;


	for (int block = 0; block < 32; block++) {
		for (int win = 0; win < (block_type[gr][ch] == 2 ? 3 : 1); win++) {
			for (int i = 0; i < n; i++) {
				sc_fixed<16,2> xi = 0.0;
				cnt++;
				for (int k = 0; k < half_n; k++) {
				
					sc_fixed<16,2> s = samples[gr][ch][18 * block + half_n * win + k];
					cnt++;
					
					xi += s * std::cos(PI / (2 * n) * (2 * i + 1 + half_n) * (2 * k + 1));
					cnt++;
				}
				//Windowing samples. 
				sample_block[win * n + i] = xi * sine_block[block_type[gr][ch]][i];
				cnt++;
			}
		}

		if (block_type[gr][ch] == 2) {
		
			sc_fixed<16,2> temp_block[36];
									
			
			int i = 0;
			for (; i < 6; i++){
				sample_block[i] = 0;
				cnt++;
			}
			for (; i < 12; i++){
				sample_block[i] = temp_block[0 + i - 6];
				cnt++;
			}
			for (; i < 18; i++){
				sample_block[i] = temp_block[0 + i - 6] + temp_block[12 + i - 12];
				cnt++;
			}
			for (; i < 24; i++){
				sample_block[i] = temp_block[12 + i - 12] + temp_block[24 + i - 18];
				cnt++;
			}
			for (; i < 30; i++){
				sample_block[i] = temp_block[24 + i - 18];
				cnt++;
			}
			for (; i < 36; i++){
				sample_block[i] = 0;
				cnt++;
			}
		}

		 //Overlap. 
		for (int i = 0; i < 18; i++) {
			samples[gr][ch][sample + i] = sample_block[i] + prev_samples[ch][block][i];
			cnt++;
			prev_samples[ch][block][i] = sample_block[18 + i];
			cnt++;
		}
		sample += 18;
		cnt++;
	}

	//3d matrix to array
	memcpy(output, samples, 2*2*576*sizeof(sc_fixed<32,16>));
    

	ready = 1;
	pl.set_address(VP_ADDR_SOFT_READY);
	pl.set_command(TLM_WRITE_COMMAND);
	pl.set_data_length(1);
	pl.set_data_ptr((unsigned char*)&ready);
	SC_REPORT_INFO("Hard", "Hard sends flag to software");
	isoc->b_transport(pl, loct);

<<<<<<< HEAD
	loct += sc_time(19, SC_NS);


	static int cnt = 0;
	cnt++;
	cout << "cnt = " << cnt << endl;
			
=======
	if(block_type[gr][ch] == 2)
	{
		file.open("report1.txt");
		file << "when block_type = 2, cnt = "<< cnt << endl;
		file.close();
		
	}

	if(block_type[gr][ch] != 2)
	{
		file.open("report2.txt");
		file << "when block_type != 2, cnt = "<< cnt << endl;
		file.close();
		
	}

>>>>>>> Milos

}

