#ifndef _INTERCONNECT_H_
#define _INTERCONNECT_H_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>

class Interconnect : public sc_core::sc_module
{
public:
	Interconnect(sc_core::sc_module_name);

	tlm_utils::simple_target_socket<Interconnect> s_soft;
	tlm_utils::simple_target_socket<Interconnect> soc;

	tlm_utils::simple_initiator_socket<Interconnect> s_mem;
	tlm_utils::simple_initiator_socket<Interconnect> s_ip;
	tlm_utils::simple_initiator_socket<Interconnect> isoc;

protected:
	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
	void b_transport(pl_t&, sc_core::sc_time&);
	void msg(const pl_t&);
};

#endif