`ifndef AXI_LITE_DRIVER_SV
 `define AXI_LITE_DRIVER_SV
 
 class axi_lite_driver extends uvm_driver#(axi_lite_item);
 	`uvm_component_utils(axi_lite_driver)
 	virtual interface axi_lite_if vif;
 	
 	 int loop_ready = 0;
 	function new(string name = "axi_lite_driver", uvm_component parent = null);
      		super.new(name,parent);

   	endfunction
   	
    	function void connect_phase(uvm_phase phase);
        	super.connect_phase(phase);
        	if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
         	   `uvm_fatal("NOVIF",{"(DRIVER)virtual interface must be set for: ",get_full_name(),".vif"})
   	endfunction : connect_phase
 
 
 	 task run_phase(uvm_phase phase);
 	@(negedge vif.reset_n);
 	forever begin
 	  seq_item_port.get_next_item(req);
         `uvm_info(get_type_name(),
                   $sformatf("Driver sending...\n%s", req.sprint()),
                   UVM_FULL)
             
                   
          @(posedge vif.clock)begin
          
          	 if(req.write)begin
				
				//read = 0, write = 1
				
	            vif.s_axi_awaddr = req.address;
	            vif.s_axi_awvalid = 1;
	            vif.s_axi_wdata = req.data;
	            vif.s_axi_wvalid = 1;
	            vif.s_axi_bready = 1'b1;
				vif.s_axi_wstrb = 4'b1111;	       
	            wait(vif.s_axi_awready && vif.s_axi_wready);	       
	            wait(vif.s_axi_bvalid);
	            //vif.s_axi_wdata = 0;
	            vif.s_axi_awvalid = 0; 
	            vif.s_axi_wvalid =  0;
               wait(!vif.s_axi_bvalid);	   
	            vif.s_axi_bready = 0;
				vif.s_axi_wstrb = 4'b0000;
	         end 
	         else begin
	            vif.s_axi_araddr = req.address;
                vif.s_axi_arvalid = 1;
                vif.s_axi_rready = 1;
	            wait(vif.s_axi_arready);
                    wait(vif.s_axi_rvalid);	           
	            vif.s_axi_arvalid = 0;
                    vif.s_axi_araddr = 0;
	            wait(!vif.s_axi_rvalid);
                    req.data = vif.s_axi_rdata;               
	            vif.s_axi_rready = 0;	       
	         end
          
           end// @posedge
          
          seq_item_port.item_done();
 	end
       
 	endtask : run_phase
 endclass
 
 
 
 `endif