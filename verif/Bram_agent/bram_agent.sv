`ifndef BRAM_AGENT_SV
`define BRAM_AGENT_SV

class bram_agent extends uvm_agent;
   //component
   bram_driver drv1;
   bram_sequencer seqr1;
   bram_monitor mon1;
   
   
   virtual interface bram_if vif;
   // configuration
   imdct_config cfg;
   
   int 	   value;   
   `uvm_component_utils_begin (bram_agent)
       `uvm_field_object(cfg, UVM_DEFAULT)
   `uvm_component_utils_end

    function new(string name = "bram_agent", uvm_component parent = null);
       super.new(name,parent);
    endfunction // new

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);
        /************Geting from configuration database*******************/
       if (!uvm_config_db#(virtual bram_if)::get(this, "", "bram_if", vif))
         `uvm_fatal("NOVIF",{"(Agent)virtual interface must be set:",get_full_name(),".vif"})
       
       if(!uvm_config_db#(imdct_config)::get(this, "", "imdct_config", cfg))
         `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

       
       /************xcSetting to configuration database********************/
       uvm_config_db#(virtual bram_if)::set(this, "*", "bram_if", vif);
       /*****************************************************************/

           mon1 = bram_monitor::type_id::create("mon1", this);
         if(cfg.is_active == UVM_ACTIVE) begin
           drv1 = bram_driver::type_id::create("drv1", this);
           seqr1= bram_sequencer::type_id::create("seqr1", this);
         end
    endfunction // build_phase

   
   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if(cfg.is_active == UVM_ACTIVE) begin
           drv1.seq_item_port.connect(seqr1.seq_item_export);
       end
   endfunction : connect_phase

endclass : bram_agent

`endif