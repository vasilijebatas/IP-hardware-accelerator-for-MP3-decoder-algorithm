`ifndef IMDCT_VIRTUAL_SEQ_SV
 `define IMDCT_VIRTUAL_SEQ_SV

class virtual_seq extends axi_lite_base_seq;

    `uvm_object_utils (virtual_seq)

    uvm_sequencer #(axi_lite_item) sequencer_axi_lite_if;
        
    function new(string name = "virtual_seq");
	   super.new(name);
    endfunction

    virtual task body();

	   axi_lite_seq sequence_lite = axi_lite_seq::type_id::create("interface1_axi_lite"); 
	   sequence_lite.start(sequencer_axi_lite_if);

    endtask : body

endclass : virtual_seq

class virtual_seq1 extends bram_base_seq;

    `uvm_object_utils (virtual_seq1)

    uvm_sequencer #(bram_item) sequencer_bram_if;
        
    function new(string name = "virtual_seq1");
	   super.new(name);
    endfunction

    virtual task body();

	   bram_seq sequence_bram = bram_seq::type_id::create("interface1_bram"); 
	   sequence_bram.start(sequencer_bram_if);

    endtask : body

endclass : virtual_seq1
//*************************************************//



`endif