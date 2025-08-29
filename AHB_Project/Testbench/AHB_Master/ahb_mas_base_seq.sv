// AHB Master Base Seq
`ifndef AHB_MAS_BASE_SEQ
`define AHB_MAS_BASE_SEQ

class ahb_mas_base_seq extends ahb_base_seq #(ahb_mas_seq_item);

	rand int no_of_txn;
	bit [`ADDRWIDTH-1:0] tmp_addr;
	
	ahb_mas_seq_item mreq;
	
	`uvm_object_utils(ahb_mas_base_seq)
	
	function new(string name = "ahb_mas_base_seq");
		super.new(name);
	endfunction

endclass

class ahb_mas_sanity_seq extends ahb_mas_base_seq;
	`uvm_object_utils(ahb_mas_sanity_seq)
	
	function new(string name = "ahb_mas_sanity_seq");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_txn) begin
			mreq = ahb_mas_seq_item::type_id::create("mreq");
			
			start_item(mreq);
			assert(mreq.randomize with {hwrite==1; hburst_type==INCR4; hsize==WORD;})
			tmp_addr = mreq.start_addr;
			finish_item(mreq);
			get_response(rsp);
			
			mreq = ahb_mas_seq_item::type_id::create("mreq");
				
			start_item(mreq);
			assert(mreq.randomize with {hwrite==0; hburst_type==INCR4; hsize==WORD; start_addr==tmp_addr;})
			finish_item(mreq);
			get_response(rsp);
		end
	endtask

endclass

`endif
