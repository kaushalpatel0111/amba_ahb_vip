// AHB WRAP16 HTRANS Sequence
`ifndef AHB_WRAP16_HTRANS_SEQ
`define AHB_WRAP16_HTRANS_SEQ

class ahb_wrap16_burst_seq extends ahb_mas_base_seq;
	`uvm_object_utils(ahb_wrap16_burst_seq)
	
	function new(string name = "ahb_wrap16_burst_seq");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_txn) begin
			mreq = ahb_mas_seq_item::type_id::create("mreq");
			
			start_item(mreq);
			assert(mreq.randomize with {hwrite==1; hburst_type==WRAP16; hsize==WORD;})
			tmp_addr = mreq.start_addr;
			finish_item(mreq);
			get_response(rsp);
			
			mreq = ahb_mas_seq_item::type_id::create("mreq");
				
			start_item(mreq);
			assert(mreq.randomize with {hwrite==0; hburst_type==WRAP16; hsize==WORD; start_addr==tmp_addr;})
			finish_item(mreq);
			get_response(rsp);
		end
	endtask

endclass

`endif
