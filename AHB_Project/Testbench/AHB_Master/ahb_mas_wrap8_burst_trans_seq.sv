// AHB WRAP8 HTRANS Sequence
`ifndef AHB_WRAP8_HTRANS_SEQ
`define AHB_WRAP8_HTRANS_SEQ

class ahb_wrap8_burst_seq extends ahb_mas_base_seq;
	`uvm_object_utils(ahb_wrap8_burst_seq)
	
	function new(string name = "ahb_wrap8_burst_seq");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_txn) begin
			mreq = ahb_mas_seq_item::type_id::create("mreq");
			
			start_item(mreq);
			assert(mreq.randomize with {hwrite==1; hburst_type==WRAP8; hsize==WORD;})
			else `uvm_fatal("WRAP8_SEQ", "Randomization Failed!")
			tmp_addr = mreq.start_addr;
			//`uvm_info("MSEQ_DEBUG", $sformatf("upper_boundary = %0h, lower_boundary = %0h", mreq.upper_boundary, mreq.lower_boundary), UVM_DEBUG)
			finish_item(mreq);
			get_response(rsp);
			
			mreq = ahb_mas_seq_item::type_id::create("mreq");
				
			start_item(mreq);
			assert(mreq.randomize with {hwrite==0; hburst_type==WRAP8; hsize==WORD; start_addr==tmp_addr;})
			else `uvm_fatal("WRAP8_SEQ", "Randomization Failed!")
			finish_item(mreq);
			get_response(rsp);
		end
	endtask

endclass

`endif
