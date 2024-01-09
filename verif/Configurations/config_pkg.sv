
`ifndef CONFIG_PKG_SV
`define CONFIG_PKG_SV


package config_pkg;

    import uvm_pkg::*;      // import the UVM library   
    `include "uvm_macros.svh" // Include the UVM macros

    `include "imdct_config.sv"

endpackage : config_pkg

`endif
