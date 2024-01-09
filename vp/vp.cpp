#include "vp.h"
#include <iostream>

Vp::Vp(sc_core::sc_module_name name) : sc_module(name), ic("interconnect"), ip("ip_hard"), mem("memory")
{
	s_soft.register_b_transport(this, &Vp::b_transport1);
	s_hard.register_b_transport(this, &Vp::b_transport2);

	s_ic.bind(ic.s_soft);
	ic.isoc.bind(s_hard);
	ic.s_ip.bind(ip.soc);
	ic.s_mem.bind(mem.soc_s);
	ip.s_memo.bind(mem.soc_h);
	ip.isoc.bind(ic.soc);
	
	

	SC_REPORT_INFO("Vp", "Platform is constructed");
}

void Vp::b_transport1(pl_t& pl, sc_core::sc_time& delay)
{
	SC_REPORT_INFO("VP", "Transaction passes from soft to ic");
	s_ic->b_transport(pl, delay);
}

void Vp::b_transport2(pl_t& pl, sc_core::sc_time& delay)
{
	SC_REPORT_INFO("VP", "Transaction passes from ic to soft");
	isoc->b_transport(pl, delay);
	
}