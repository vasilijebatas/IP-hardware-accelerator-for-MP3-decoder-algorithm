`ifndef BRAM_ITEM_SV
`define BRAM_ITEM_SV


class bram_item extends uvm_sequence_item;
  
	// item fields

    
  	rand bit [31:0] out_data;
  	rand bit [31:0] in_data;
 	rand bit [15:0] address;
  	bit en;
  	rand bit [3:0]  we;
    
  	`uvm_object_utils_begin(bram_item)
    	`uvm_field_int(out_data, UVM_ALL_ON)
    	`uvm_field_int(in_data, UVM_ALL_ON)
    	`uvm_field_int(address, UVM_ALL_ON)
    	`uvm_field_int(en, UVM_ALL_ON)
    	`uvm_field_int(we, UVM_ALL_ON)
  	`uvm_object_utils_end

	// constructor
	function new(string name = "bram_item");
  		super.new(name);
	endfunction

endclass : bram_item
`endif