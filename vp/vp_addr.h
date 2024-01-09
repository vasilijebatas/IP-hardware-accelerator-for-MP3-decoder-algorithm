#ifndef _VP_ADDR_H_
#define _VP_ADDR_H_

#include "ip_hard.h"
#include "soft.h"


const sc_dt::uint64 VP_ADDR_MEM = 0x43C00000;
const sc_dt::uint64 VP_ADDR_HARD = 0x43D00000;
const sc_dt::uint64 VP_ADDR_SOFT = 0x43A00000;

const sc_dt::uint64 VP_ADDR_HARD_READY = VP_ADDR_HARD + 0;
const sc_dt::uint64 VP_ADDR_HARD_START = VP_ADDR_HARD + 1;
const sc_dt::uint64 VP_ADDR_HARD_OUT = VP_ADDR_HARD + 3;
const sc_dt::uint64 VP_ADDR_HARD_H = 0x43D00005;

const sc_dt::uint64 VP_ADDR_SOFT_READY = VP_ADDR_SOFT + 0;
const sc_dt::uint64 VP_ADDR_SOFT_START = VP_ADDR_SOFT + 1;
const sc_dt::uint64 VP_ADDR_SOFT_H = 0x43A00004;

const sc_dt::uint64 VP_ADDR_MEM_GR = 0x43C00000;
const sc_dt::uint64 VP_ADDR_MEM_CH = 0x43C00001;
const sc_dt::uint64 VP_ADDR_MEM_BLOCK = 0x43C00002;
const sc_dt::uint64 VP_ADDR_MEM_SAMPLES = 0x43C00003;
const sc_dt::uint64 VP_ADDR_MEM_H = 0x43C00004;

#define DELAY 20



#endif