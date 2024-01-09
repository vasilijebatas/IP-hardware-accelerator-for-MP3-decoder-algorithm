`ifndef AXI_LITE_SEQ_SV
`define AXI_LITE_SEQ_SV


class axi_lite_seq extends axi_lite_base_seq;
      
    `uvm_object_utils (axi_lite_seq)

    function new(string name = "axi_lite_seq");
        super.new(name);
    endfunction

	// body task
  	virtual task body();
		
		

	   `uvm_do_with(req, {req.write == 1; req.data == 4'b0000; req.address == 16;});
       `uvm_do_with(req, {req.write == 1; req.data == 1; req.address == 4;});
       `uvm_do_with(req, {req.write == 1; req.data == 2'b00; req.address == 8;});
       `uvm_do_with(req, {req.write == 1; req.data == 2'b00; req.address == 12;});

       

                                     
      `uvm_do_with(req, {req.read == 1; req.data == 1; req.address == 0;});
        


		

	endtask : body
  
endclass : axi_lite_seq

`endif