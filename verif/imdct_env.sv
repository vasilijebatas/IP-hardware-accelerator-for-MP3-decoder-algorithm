`ifndef IMDCT_ENV_SV
`define IMDCT_ENV_SV

class imdct_env extends uvm_env;
  
  	// component instance
	axi_lite_agent agent;
   	bram_agent agent1;
   	imdct_scoreboard scoreboard;
     
   imdct_config cfg;
   virtual interface axi_lite_if vif;
   virtual interface bram_if vif1;
	`uvm_component_utils(imdct_env)

	// constructor
	function new(string name = "imdct_env", uvm_component parent = null);
  		super.new(name, parent);
	endfunction

	// build phase
	function void build_phase(uvm_phase phase);
  		super.build_phase(phase);
  		
		if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
       	`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
       	
       if (!uvm_config_db#(virtual bram_if)::get(this, "", "bram_if", vif1))
       	`uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
       
       if(!uvm_config_db#(imdct_config)::get(this, "", "imdct_config", cfg))
         `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
      
      
      
      
      
      
       uvm_config_db#(imdct_config)::set(this, "*agent", "imdct_config", cfg);
       uvm_config_db#(virtual axi_lite_if)::set(this, "interface1_agent", "axi_lite_if", vif);
       uvm_config_db#(virtual bram_if)::set(this, "interface2_agent", "bram_if", vif1);
        
       
       agent = axi_lite_agent::type_id::create("interface1_agent",this);
       agent1 = bram_agent::type_id::create("interface2_agent",this);
		scoreboard = imdct_scoreboard::type_id::create("scoreboard", this);
	endfunction : build_phase

	// connect phase
	function void connect_phase(uvm_phase phase);
  		super.connect_phase(phase);

		
        agent.mon.item_collected_port.connect(scoreboard.axi_lite_collected_port);
		agent1.mon1.item_collected_port.connect(scoreboard.bram_collected_port);
        
    endfunction : connect_phase

endclass : imdct_env
`endif