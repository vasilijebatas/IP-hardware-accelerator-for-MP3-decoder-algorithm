#ifndef _VP_H_
#define _VP_H_

#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "interconnect.h"
#include "ip_hard.h"
#include "memory.h"
#include "soft.h"

class Vp : public sc_core::sc_module
{
public:
	Vp(sc_core::sc_module_name);

	tlm_utils::simple_target_socket<Vp> s_soft;
	tlm_utils::simple_initiator_socket<Vp> isoc;

protected:
	tlm_utils::simple_initiator_socket<Vp> s_ic;
	tlm_utils::simple_target_socket<Vp> s_hard;

	Interconnect ic;
	Ip_hard ip;
	Memory mem;

	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
	void b_transport1(pl_t&, sc_core::sc_time&);
	void b_transport2(pl_t&, sc_core::sc_time&);
};

#endif