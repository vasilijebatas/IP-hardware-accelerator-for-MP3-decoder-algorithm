`ifndef IMDCT_PKG_SV
`define IMDCT_PKG_SV

package imdct_pkg;

   import uvm_pkg::*;      // import the UVM library   
 `include "uvm_macros.svh" // Include the UVM macros

    import axi_lite_agent_pkg::*;
    import simple_pkg::*;
    import config_pkg::*;
    import bram_agent_pkg::*;

    
    `include "imdct_scoreboard.sv"
    `include "imdct_env.sv"
    `include "test_base.sv"
    `include "test_simple.sv"
    `include "test_simple_2.sv"   

endpackage : imdct_pkg

 `include "imdct_if.sv"

 
`endif 
