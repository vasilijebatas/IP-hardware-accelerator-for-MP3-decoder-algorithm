`ifndef IMDCT_VERIF_TOP_SV
`define IMDCT_VERIF_TOP_SV

module imdct_verif_top;
  
  import uvm_pkg::*;
  `include "uvm_macros.svh"  
  
  import imdct_pkg::*;	//import test package
  
  //signals
  logic reset_n;
  logic clock;
  
  //UVC interface instance
  axi_lite_if axi_lite_if_inst(clock, reset_n);
  bram_if bram_if_inst(clock, reset_n);

  
  //DUT instance
  IMDCT_v1_0 dut(
	.s00_axi_aclk	   	(clock),
	.s00_axi_aresetn 	(reset_n),   
	.s00_axi_awaddr	 	(axi_lite_if_inst.s_axi_awaddr),
	.s00_axi_awprot	 	(axi_lite_if_inst.s_axi_awprot),
	.s00_axi_awvalid 	(axi_lite_if_inst.s_axi_awvalid), 
	.s00_axi_awready 	(axi_lite_if_inst.s_axi_awready),
	.s00_axi_wdata	 	(axi_lite_if_inst.s_axi_wdata),
	.s00_axi_wstrb	 	(axi_lite_if_inst.s_axi_wstrb),
	.s00_axi_wvalid	 	(axi_lite_if_inst.s_axi_wvalid),
	.s00_axi_wready	 	(axi_lite_if_inst.s_axi_wready),
  .s00_axi_bresp	 	(axi_lite_if_inst.s_axi_bresp),
  .s00_axi_bvalid	 	(axi_lite_if_inst.s_axi_bvalid),
	.s00_axi_bready	 	(axi_lite_if_inst.s_axi_bready),
	.s00_axi_araddr	 	(axi_lite_if_inst.s_axi_araddr),
	.s00_axi_arprot	 	(axi_lite_if_inst.s_axi_arprot),
	.s00_axi_arvalid 	(axi_lite_if_inst.s_axi_arvalid), 
	.s00_axi_arready 	(axi_lite_if_inst.s_axi_arready),
	.s00_axi_rdata	 	(axi_lite_if_inst.s_axi_rdata),
	.s00_axi_rresp	 	(axi_lite_if_inst.s_axi_rresp),
	.s00_axi_rvalid	 	(axi_lite_if_inst.s_axi_rvalid),
	.s00_axi_rready  	(axi_lite_if_inst.s_axi_rready),

  .addrb   	 ( bram_if_inst.s_addr_bram ),
  .dinb   	 ( bram_if_inst.s_din_bram), 
  .doutb   	 ( bram_if_inst.s_dout_bram),                
  .en  	     ( bram_if_inst.s_en_bram ),
  .web     	 ( bram_if_inst.s_we_bram)
  
  );
  
  
    
    initial begin : config_if_block
    
    
    
  	  uvm_config_db#(virtual axi_lite_if)::set(null, "*", "axi_lite_if", axi_lite_if_inst);
  	  uvm_config_db#(virtual bram_if)::set(null, "*", "bram_if", bram_if_inst);
  	  
  	  
    end

    //clock and reset init.
    initial begin
      clock <= 0;
      reset_n <= 0;
      #500 reset_n <= 1;
    end

    //clock generation
    always #50 clock = ~clock;

    //run test
   initial begin : run_test_block
      run_test();
    end
   // clock generation

endmodule : imdct_verif_top

`endif