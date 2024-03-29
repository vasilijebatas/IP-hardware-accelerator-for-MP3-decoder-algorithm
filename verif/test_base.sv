`ifndef TEST_BASE_SV
`define TEST_BASE_SV
class test_base extends uvm_test;

   imdct_env env;
   imdct_config cfg;

   `uvm_component_utils(test_base)

   function new(string name = "test_base", uvm_component parent = null);
      super.new(name,parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cfg = imdct_config::type_id::create("cfg");      
      uvm_config_db#(imdct_config)::set(this, "*", "imdct_config", cfg);      
      env = imdct_env::type_id::create("env", this);      
   endfunction : build_phase

   function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      uvm_top.print_topology();
   endfunction : end_of_elaboration_phase

   function void init_vseq(virtual_seq vseq, virtual_seq1 vseq1);
      vseq.sequencer_axi_lite_if = env.agent.seqr;
      vseq1.sequencer_bram_if = env.agent1.seqr1;
      
   endfunction:init_vseq
endclass : test_base
`endif