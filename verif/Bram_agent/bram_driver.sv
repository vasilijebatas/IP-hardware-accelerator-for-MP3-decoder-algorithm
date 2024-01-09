`ifndef BRAM_DRIVER_SV
`define BRAM_DRIVER_SV


class bram_driver extends uvm_driver #(bram_item);
  
  	`uvm_component_utils(bram_driver)
  	
	
	logic [31:0] address;
     
  	// virtual interface reference
  	virtual interface bram_if vif1;
  
  	imdct_config cfg;
  
	// constructor
	function new(string name = "bram_driver", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	if (!uvm_config_db#(virtual bram_if)::get(this, "*", "bram_if", vif1))
      	`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif1"})
   	endfunction : connect_phase
   	
// process item
		
task run_phase(uvm_phase phase);
 	forever begin
	
                   
        @(posedge vif1.clock)begin
		
		address = vif1.s_addr_bram;
	

		if(vif1.s_en_bram)begin
		         
				$display("Getting item");
		 		seq_item_port.get_next_item(req);
         		`uvm_info(get_type_name(),
                $sformatf("Driver sending...\n%s", req.sprint()),
                UVM_FULL)
             
				
				vif1.s_din_bram = req.in_data;
				seq_item_port.item_done();

		  end
	end
		end

	
	
      



endtask : run_phase

endclass : bram_driver
`endif