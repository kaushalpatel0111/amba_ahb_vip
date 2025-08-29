// AHB Narrow Transfer Sequence
`ifndef AHB_NARROW_TRANS_SEQ
`define AHB_NARROW_TRANS_SEQ

class ahb_narrow_transfer_seq extends ahb_mas_base_seq;
	`uvm_object_utils(ahb_narrow_transfer_seq)
	
	function new(string name = "ahb_narrow_transfer_seq");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_txn) begin
			mreq = ahb_mas_seq_item::type_id::create("mreq");
			
			start_item(mreq);
			assert(mreq.randomize with {hwrite==1; hburst_type==INCR4; hsize==HALFWORD;})
			tmp_addr = mreq.start_addr;
			finish_item(mreq);
			get_response(rsp);
			
			mreq = ahb_mas_seq_item::type_id::create("mreq");
				
			start_item(mreq);
			assert(mreq.randomize with {hwrite==0; hburst_type==INCR4; hsize==HALFWORD; start_addr==tmp_addr;})
			finish_item(mreq);
			get_response(rsp);
		end
	endtask

endclass

`endif
