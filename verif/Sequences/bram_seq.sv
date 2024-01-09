`ifndef BRAM_SEQ_SV
`define BRAM_SEQ_SV

class bram_seq extends bram_base_seq;
    `uvm_object_utils(bram_seq)
  
    function new(string name = "bram_seq");
        super.new(name);
    endfunction

    virtual task body();
    


      `uvm_do_with(req, {req.in_data == 32'b00010000011001010000100000000000;});
        $display("Data sent to BRAM !");
    endtask : body
endclass : bram_seq
`endif