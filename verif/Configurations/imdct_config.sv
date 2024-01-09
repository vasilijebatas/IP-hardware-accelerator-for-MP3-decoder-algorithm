
`ifndef IMDCT_CONFIG_SV
`define IMDCT_CONFIG_SV

class imdct_config extends uvm_object;
   uvm_active_passive_enum is_active = UVM_ACTIVE;

   `uvm_object_utils_begin (imdct_config)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
    `uvm_object_utils_end

   function new(string name = "imdct_config");
      super.new (name);
   endfunction // new

endclass : imdct_config
`endif