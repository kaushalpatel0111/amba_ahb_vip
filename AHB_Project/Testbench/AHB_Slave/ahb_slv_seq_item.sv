// AHB Slave Seq_item
`ifndef AHB_SLV_SEQ_ITEM
`define AHB_SLV_SEQ_ITEM

class ahb_slv_seq_item extends ahb_transaction;
	
	`uvm_object_utils(ahb_slv_seq_item)
	
	function new(string name = "ahb_slv_seq_item");
		super.new(name);
	endfunction
	
endclass

`endif
