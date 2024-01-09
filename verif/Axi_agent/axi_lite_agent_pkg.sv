`ifndef AXI_LITE_AGENT_PKG_SV
`define AXI_LITE_AGENT_PKG_SV


package axi_lite_agent_pkg;
 
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // include Agent components : driver,sequencer
   /////////////////////////////////////////////////////////
   import config_pkg::*;   
   
   `include "axi_lite_item.sv"
   `include "axi_lite_sequencer.sv"
   `include "axi_lite_driver.sv"
   `include "axi_lite_monitor.sv"
   `include "axi_lite_agent.sv"
   

endpackage
`endif



