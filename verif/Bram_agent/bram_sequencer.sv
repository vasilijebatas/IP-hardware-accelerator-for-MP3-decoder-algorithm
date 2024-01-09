`ifndef BRAM_SEQUENCER_SV
`define BRAM_SEQUENCER_SV


class bram_sequencer extends uvm_sequencer#(bram_item);
  
	`uvm_component_utils(bram_sequencer)
    
	function new(string name = "bram_sequencer", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

endclass : bram_sequencer

`endif