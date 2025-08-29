// AHB Slave Sequencer
`ifndef AHB_SLV_SEQR
`define AHB_SLV_SEQR

class ahb_slv_seqr extends uvm_sequencer#(ahb_slv_seq_item);

	`uvm_component_utils(ahb_slv_seqr)
	
	uvm_tlm_analysis_fifo #(ahb_transaction) item_req_fifo;
	
	ahb_slv_mem smem_h;
	ahb_cust_cfg cust_cfg_h;
	
	function new(string name = "ahb_slv_seqr", uvm_component parent = null);
		super.new(name, parent);
		item_req_fifo = new("item_req_fifo", this);
	endfunction

endclass

`endif
