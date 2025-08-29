// AHB Scoreboard
`ifndef AHB_SCB
`define AHB_SCB

`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)

class ahb_scb extends uvm_scoreboard;

	`uvm_component_utils(ahb_scb)

	ahb_cust_cfg cust_cfg_h;

	ahb_transaction mitem_q[$];
	ahb_transaction sitem_q[$];

	uvm_analysis_imp_master #(ahb_transaction, ahb_scb) mitem_export;
	uvm_analysis_imp_slave #(ahb_transaction, ahb_scb) sitem_export;

	// Memory array to track the expected values
	bit[`DATAWIDTH-1:0] mem_expected [int];
	
	function new(string name = "ahb_scb", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	
		mitem_export = new("mitem_export", this);
		sitem_export = new("sitem_export", this);

		foreach(mem_expected[i]) begin
			mem_expected[i] = '0;
		end
	endfunction

	function void write_master(ahb_transaction common_trans_h);
		mitem_q.push_back(common_trans_h);
	endfunction

	function void write_slave(ahb_transaction common_trans_h);
		sitem_q.push_back(common_trans_h);
	endfunction
	
	task run_phase(uvm_phase phase);
		if(cust_cfg_h.beat_by_beat_compare == 1'b1) begin
			beat_by_beat_cmp();
		end
		else begin
			pkt_by_pkt_cmp();
		end		
	endtask

	task beat_by_beat_cmp();
		ahb_transaction mas_trans_h, slv_trans_h;

		forever begin
			wait(mitem_q.size() > 0);
			wait(sitem_q.size() > 0);

			mas_trans_h = mitem_q.pop_front();
			`uvm_info("AHB_SCB", $sformatf("-------------Received Master Transaction-------------\n %s", mas_trans_h.sprint()), UVM_DEBUG)

     			slv_trans_h = sitem_q.pop_front();
			`uvm_info("AHB_SCB", $sformatf("-------------Received Slave Transaction-------------\n %s", slv_trans_h.sprint()), UVM_DEBUG)

			$cast(mas_trans_h, slv_trans_h);
			if(mas_trans_h.compare(slv_trans_h)) begin 
          			`uvm_info(get_full_name(),"PACKETS ARE MATCHING!",UVM_DEBUG)
        		end
			else begin
          			`uvm_info(get_full_name(),"PACKETS ARE NOT MATCHING!",UVM_DEBUG)
			end	
		end
	endtask

	task pkt_by_pkt_cmp();
		ahb_transaction mas_trans_h, slv_trans_h;

		forever begin
			wait(mitem_q.size() > 0);
			wait(sitem_q.size() > 0);

			mas_trans_h = mitem_q.pop_front();
			`uvm_info("AHB_SCB", $sformatf("-------------Received Master Transaction-------------\n %s", mas_trans_h.sprint()), UVM_DEBUG)

     			slv_trans_h = sitem_q.pop_front();
			`uvm_info("AHB_SCB", $sformatf("-------------Received Slave Transaction-------------\n %s", slv_trans_h.sprint()), UVM_DEBUG)

			$cast(mas_trans_h, slv_trans_h);
			if(mas_trans_h.compare(slv_trans_h)) begin 
          			`uvm_info(get_full_name(),"PACKETS ARE MATCHING!",UVM_DEBUG)
        		end
			else begin
          			`uvm_info(get_full_name(),"PACKETS ARE NOT MATCHING!",UVM_DEBUG)
			end	
		end
	endtask

endclass

`endif
