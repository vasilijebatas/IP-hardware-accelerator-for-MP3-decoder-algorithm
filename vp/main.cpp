#include <systemc>
#include "soft.h"
#include "ip_hard.h"
#include "vp.h"

using namespace sc_core;

int sc_main(int argc, char** argv)
{
	Soft soft("Soft", argv);
	Vp uut("uut");
	
	soft.isoc_s.bind(uut.s_soft);
	uut.isoc.bind(soft.tsoc);

<<<<<<< HEAD
	tlm::tlm_global_quantum::instance().set(sc_time(19, SC_NS));
=======
	tlm::tlm_global_quantum::instance().set(sc_time(1000, SC_NS));
>>>>>>> Milos

	sc_start(2,SC_MS);

    return 0;
}