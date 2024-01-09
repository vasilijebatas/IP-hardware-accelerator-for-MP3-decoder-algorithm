#include "interconnect.h"
#include "vp_addr.h"
#include <string>
#include <sstream>

using namespace std;
using namespace tlm;
using namespace sc_core;
using namespace sc_dt;

Interconnect::Interconnect(sc_module_name name) : sc_module(name)
{
	s_soft.register_b_transport(this, &Interconnect::b_transport);
	soc.register_b_transport(this, &Interconnect::b_transport);

}

void Interconnect::b_transport(pl_t& pl, sc_time& offset)
{
	uint64 addr = pl.get_address();
	uint64 taddr;
<<<<<<< HEAD
	offset += sc_time(5, SC_NS);
=======
	offset += sc_time(DELAY, SC_NS);
>>>>>>> Milos

	if(addr >= VP_ADDR_MEM && addr < VP_ADDR_MEM_H)
	{
		taddr = addr & 0x0000000F;
		pl.set_address(taddr);
		SC_REPORT_INFO("Interconnect", "Transaction passes to memory");
		s_mem->b_transport(pl, offset);
		
	}
	else if (addr >= VP_ADDR_HARD && addr <  VP_ADDR_HARD_H)
	{
		taddr = addr & 0x0000000F;
		pl.set_address(taddr);
		SC_REPORT_INFO("Interconnect", "Transaction passes to hardware");
		s_ip->b_transport(pl, offset);
		
	}
	else if(addr >= VP_ADDR_SOFT && addr <  VP_ADDR_SOFT_H)
	{
		taddr = addr & 0x0000000F;
		pl.set_address(taddr);
		SC_REPORT_INFO("Interconnect", "Transaction passes to software");
		isoc->b_transport(pl, offset);
		
	}

	pl.set_address(addr);
}

void Interconnect::msg(const pl_t& pl)
{
	stringstream ss;
	ss << hex << pl.get_address();
	sc_uint<32> val = *((sc_uint<32>*)pl.get_data_ptr());
	string cmd  = pl.get_command() == TLM_READ_COMMAND ? "read  " : "write ";

	string msg = cmd + "val: " + to_string((int)val) + " adr: " + ss.str();
	msg += " @ " + sc_time_stamp().to_string();

	SC_REPORT_INFO("Interconnect", msg.c_str());
}