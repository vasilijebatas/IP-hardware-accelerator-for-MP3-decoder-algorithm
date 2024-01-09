`ifndef BRAM_AGENT_PKG_SV
`define BRAM_AGENT_PKG_SV
package bram_agent_pkg;
 
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // include Agent components : driver,sequencer
   /////////////////////////////////////////////////////////
   import config_pkg::*;   
   
    `include "bram_item.sv"
   `include "bram_sequencer.sv"
   `include "bram_driver.sv"
   `include "bram_monitor.sv"
   `include "bram_agent.sv"

endpackage
`endif


