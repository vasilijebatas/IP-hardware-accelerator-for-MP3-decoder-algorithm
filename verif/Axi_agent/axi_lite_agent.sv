
`ifndef AXI_LITE_AGENT_SV
`define AXI_LITE_AGENT_SV

class axi_lite_agent extends uvm_agent;
   //component
   axi_lite_driver drv;
   axi_lite_sequencer seqr;
   axi_lite_monitor mon;
   
   
   virtual interface axi_lite_if vif;
   // configuration
   imdct_config cfg;
   
   int 	   value;   
   `uvm_component_utils_begin (axi_lite_agent)
       `uvm_field_object(cfg, UVM_DEFAULT)
   `uvm_component_utils_end

    function new(string name = "axi_lite_agent", uvm_component parent = null);
       super.new(name,parent);
    endfunction // new

    function void build_phase(uvm_phase phase);
       super.build_phase(phase);
        /************Geting from configuration database*******************/
       if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "axi_lite_if", vif))
         `uvm_fatal("NOVIF",{"(Agent)virtual interface must be set:",get_full_name(),".vif"})
       
       if(!uvm_config_db#(imdct_config)::get(this, "", "imdct_config", cfg))
         `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

       
       /************xcSetting to configuration database********************/
       uvm_config_db#(virtual axi_lite_if)::set(this, "*", "axi_lite_if", vif);
       /*****************************************************************/

         mon = axi_lite_monitor::type_id::create("mon", this);
         
         if(cfg.is_active == UVM_ACTIVE) begin
          
           drv = axi_lite_driver::type_id::create("drv", this);
           seqr = axi_lite_sequencer::type_id::create("seqr", this);
         end
    endfunction // build_phase

   
   function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       if(cfg.is_active == UVM_ACTIVE) begin
           drv.seq_item_port.connect(seqr.seq_item_export);
       end
   endfunction : connect_phase

endclass : axi_lite_agent

`endif