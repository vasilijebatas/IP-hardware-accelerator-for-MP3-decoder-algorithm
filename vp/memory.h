#ifndef _MEMORY_H_
#define _MEMORY_H_

#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <sstream>
#include "vp_addr.h"

const sc_dt::uint64 MEM_GR = 0;
const sc_dt::uint64 MEM_CH = 1;
const sc_dt::uint64 MEM_BLOCK = 2;
const sc_dt::uint64 MEM_SAMPLES = 3;



class Memory : public sc_core::sc_module
{
public:
	Memory(sc_core::sc_module_name);

	tlm_utils::simple_target_socket<Memory> soc_s;
	tlm_utils::simple_target_socket<Memory> soc_h;
protected:

	static const int RAM_SIZE = 200000;
	unsigned char ram[RAM_SIZE];


	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
	void b_transport(pl_t&, sc_core::sc_time&);
	void msg(const pl_t&);
};

#endif