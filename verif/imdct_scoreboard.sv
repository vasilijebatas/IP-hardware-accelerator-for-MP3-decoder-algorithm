`ifndef IMDCT_SCOREBOARD_SV
`define IMDCT_SCOREBOARD_SV


`uvm_analysis_imp_decl(_axi_lite)
`uvm_analysis_imp_decl(_bram)


class imdct_scoreboard extends uvm_scoreboard;
	
	//control fileds
   	bit checks_enable = 1;
   	bit coverage_enable = 1;
   	
	axi_lite_item item_clone1;
	bram_item item_clone;
	
	
	int unsigned block_type;
	int unsigned gr, ch;	
	int start_count = 0; //broj izvrsavanja
  	bit ready;
	int address_que[$];
	int bram_que[$];
	string s;
	int bram_data;
	int ocekivane_vrednosti[0:18] = {0,1148106,-1553148,2039364,-2350875,2390540,-2579279,2573034,-2578844,1763534,-2326642,1741068,-1467732,1059520,-390625,-95970,795907,-1636800,-424830};
	int address_of_data = 0;
	int i = 0;
	int j = 0;


	uvm_analysis_imp_axi_lite#(axi_lite_item, imdct_scoreboard) axi_lite_collected_port;
	uvm_analysis_imp_bram#(bram_item, imdct_scoreboard) bram_collected_port;
	

	`uvm_component_utils_begin(imdct_scoreboard)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
   	`uvm_component_utils_end

	function new(string name = "imdct_scoreboard", uvm_component parent);
		super.new(name,parent);
		axi_lite_collected_port = new("axi_lite_collected_port", this);
		bram_collected_port = new("bram_collected_port", this);
	endfunction

	
	function void write_axi_lite(axi_lite_item item_clone1);

		
	
		if(checks_enable) begin
 			
			//block_type
			if(item_clone1.address == 16) begin
				block_type = item_clone1.data;
		    	`uvm_info(get_type_name(), $sformatf("BLOCK_TYPE : %d", block_type), UVM_LOW)
		    end	
			    
 			//gr
			else if(item_clone1.address == 8) begin
				gr = item_clone1.data;
		    	`uvm_info(get_type_name(), $sformatf("GR : %d", gr), UVM_LOW)
			end
				
			//ch
			else if(item_clone1.address == 12) begin
				ch = item_clone1.data;
		    	`uvm_info(get_type_name(), $sformatf("CH : %d", ch), UVM_LOW)
			end
		
			//start
			else if(item_clone1.address == 4) begin
			
    			if(item_clone1.data == 1) begin
     				`uvm_info(get_type_name(), $sformatf("IMDCT started (start_count: %d)", start_count), UVM_LOW)
    				start_count++;
   				end
   				
			end
  				
			//ready	
			else if(item_clone1.address == 0) begin
			
    			if(item_clone1.data == 1) begin
     				ready = 1;
 					`uvm_info(get_type_name(), "READY is 1.", UVM_LOW)
   				end
   				
			end
				
			//Ako pokusamo da pristupimo registru koji ne postoji
			if(item_clone1.address == 0 || item_clone1.address == 4 || item_clone1.address == 8 || item_clone1.address == 12 || item_clone1.address == 16 || item_clone1.address == 20 || item_clone1.address == 24 || item_clone1.address == 28) begin
				`uvm_info(get_type_name(), $sformatf("AXI DATA SCOREBOARD: \n%s", item_clone1.sprint()), UVM_DEBUG)
			end
			else begin
				`uvm_error(get_type_name(), $sformatf("Register with the address of %d doesn't exist.",item_clone1.address))
			end
			
		end
	
	endfunction : write_axi_lite
	

	function void write_bram(bram_item item_clone);	

	    	 		
		if(checks_enable) begin
     		

		if(item_clone.en == 1)begin
			if(item_clone.we == 1) begin
				
				bram_que.push_back(item_clone.out_data); //punim queue A sa podacima
				`uvm_info(get_type_name(),"=========================================", UVM_LOW)
   				`uvm_info(get_type_name(), $sformatf("BRAM QUEUE: \n%p", bram_que), UVM_LOW)


  				if( address_of_data ==  item_clone.address) begin
					//trigger = 0;
					
    				`uvm_info(get_type_name(),"Address is okay.", UVM_LOW)
  				end
  				else begin
    				`uvm_error(get_type_name(),$sformatf("Address  is %d, it should be %d",item_clone.address,address_of_data ))
  				end
				  address_of_data++;

			

				if(bram_que[j] == ocekivane_vrednosti[i]) begin
					`uvm_info(get_type_name(), $sformatf("Output match. (%d = %d)",ocekivane_vrednosti[i], bram_que[j] ), UVM_LOW)
				end
				else begin 
    				`uvm_error(get_type_name(), $sformatf("Output mismatch. OCEKIVANO: %d, REZULTAT: %d", ocekivane_vrednosti[i], bram_que[j]))
				end

				
				i++;
				j++;
			end
			end
		end
	endfunction : write_bram
endclass: imdct_scoreboard
	
`endif