// AHB BUSY during fixed HBURST Sequence
`ifndef AHB_BUSY_DURING_FIXED_HBURST_SEQ
`define AHB_BUSY_DURING_FIXED_HBURST_SEQ

class ahb_busy_during_fixed_burst_seq extends ahb_mas_base_seq;
	`uvm_object_utils(ahb_busy_during_fixed_burst_seq)
	
	function new(string name = "ahb_busy_during_fixed_burst_seq");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_txn) begin
			mreq = ahb_mas_seq_item::type_id::create("mreq");
			
			start_item(mreq);
			assert(mreq.randomize with {hwrite==1; hburst_type==INCR4; hsize==WORD; num_busy == 1; index_busy == 1;})
			tmp_addr = mreq.start_addr;
			finish_item(mreq);
			get_response(rsp);
			
			mreq = ahb_mas_seq_item::type_id::create("mreq");
				
			start_item(mreq);
			assert(mreq.randomize with {hwrite==0; hburst_type==INCR4; hsize==WORD; num_busy == 1; index_busy == 1; start_addr==tmp_addr;})
			finish_item(mreq);
			get_response(rsp);
		end
	endtask

endclass

`endif
