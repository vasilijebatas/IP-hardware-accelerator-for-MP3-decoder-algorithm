#include "memory.h"
#include "vp_addr.h"
#include <tlm>


using namespace sc_core;
using namespace sc_dt;
using namespace std;
using namespace tlm;

Memory::Memory(sc_module_name name) : sc_module(name), soc_s("soc_s"), soc_h("soc_h")
{
	soc_h.register_b_transport(this, &Memory::b_transport);
	soc_s.register_b_transport(this, &Memory::b_transport);


}

void Memory::b_transport(pl_t& pl, sc_time& offset)
{

	tlm_command cmd = pl.get_command();
	uint64 addr = pl.get_address();
	unsigned char* data = pl.get_data_ptr();
	unsigned int len = pl.get_data_length();

	int addr_gr = 0;
	int addr_ch = 10;
	int addr_block = 25;
	int addr_samples = 70;

	switch(cmd)
	{ 
	case TLM_WRITE_COMMAND:
	{
		switch(addr)
		{
		case MEM_GR:
			for(unsigned int i = 0; i != len; ++i )
			{
					ram[addr_gr++] = data[i];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case MEM_CH:
			for(unsigned int i = 0; i != len; ++i )
			{
				ram[addr_ch++] = data[i];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case MEM_BLOCK:
			for(unsigned int i = 0; i != len; ++i )
			{
				ram[addr_block++] = data[i];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case MEM_SAMPLES:
			for(unsigned int i = 0; i != len; ++i )
			{
				ram[addr_samples++] = data[i];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		default:
			pl.set_response_status( TLM_ADDRESS_ERROR_RESPONSE );
			SC_REPORT_ERROR("MEM", "TLM bad address");

			break;
		}
		break;
	}
	case TLM_READ_COMMAND:
	{
		switch(addr)
		{
		case MEM_GR:
			for(unsigned int i = 0; i != len; ++i )
			{
				data[i] = ram[addr_gr++];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case MEM_CH:
			for(unsigned int i = 0; i != len; ++i )
			{
				data[i] = ram[addr_ch++];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case MEM_BLOCK:
			for(unsigned int i = 0; i != len; ++i )
			{
				data[i] = ram[addr_block++];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		case MEM_SAMPLES:
			for(unsigned int i = 0; i != len; ++i )
			{
				data[i] = ram[addr_samples++];
			}
			pl.set_response_status( TLM_OK_RESPONSE );
			break;
		default:
			pl.set_response_status( TLM_ADDRESS_ERROR_RESPONSE );
			SC_REPORT_ERROR("MEM", "TLM bad address");

			break;
		}
		break;
	}
	default:
		pl.set_response_status( TLM_COMMAND_ERROR_RESPONSE );
		SC_REPORT_ERROR("MEM", "TLM bad command");
		break;
	}

<<<<<<< HEAD
	offset += sc_time(19, SC_NS);
=======
	offset += sc_time(len*DELAY, SC_NS);
>>>>>>> Milos
}

void Memory::msg(const pl_t& pl)
{

	string msg;
	msg = " RAM at time " + sc_time_stamp().to_string();
		msg += "\n";
		for (int i = 0; i != 100; ++i)
		{
			// msg += std::to_string(pl.get_data_ptr()[i]);
			msg += std::to_string(ram[i]);

			msg += " ";
		}

	SC_REPORT_INFO("RAM", msg.c_str());
}