// AHB Random Busrt Sequence
`ifndef AHB_RANDOM_BURST_SEQ
`define AHB_RANDOM_BURST_SEQ

class ahb_random_burst_seq extends ahb_mas_base_seq;
	`uvm_object_utils(ahb_random_burst_seq)
	
	function new(string name = "ahb_random_burst_seq");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_txn) begin
			mreq = ahb_mas_seq_item::type_id::create("mreq");
			
			start_item(mreq);
			assert(mreq.randomize with {hwrite==1; hburst_type!=INCR; hsize==WORD; start_addr=='h3F8;})
			finish_item(mreq);
			get_response(rsp);
			
			mreq = ahb_mas_seq_item::type_id::create("mreq");
				
			start_item(mreq);
			assert(mreq.randomize with {hwrite==0; hburst_type!=INCR; hsize==WORD; start_addr=='h3F8;})
			finish_item(mreq);
			get_response(rsp);
		end
	endtask
endclass

`endif
