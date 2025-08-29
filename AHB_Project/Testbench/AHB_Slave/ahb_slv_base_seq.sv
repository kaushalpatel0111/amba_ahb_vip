// AHB Slave Base Seq
`ifndef AHB_SLV_BASE_SEQ
`define AHB_SLV_BASE_SEQ

class ahb_slv_base_seq extends ahb_base_seq #(ahb_slv_seq_item);

	ahb_transaction common_trans_h;
	ahb_slv_seq_item req;
	
	`uvm_object_utils(ahb_slv_base_seq)
	`uvm_declare_p_sequencer(ahb_slv_seqr)
	
	function new(string name = "ahb_slv_base_seq");
		super.new(name);
	endfunction
	
	task body();
		forever begin
			p_sequencer.item_req_fifo.get(common_trans_h);
		
			$cast(req, common_trans_h.clone());

			`uvm_info("SSEQ_DEBUG", $sformatf("Slave SEQ: req.print() = %s", req.sprint()), UVM_DEBUG)
			
			if(p_sequencer.cust_cfg_h.beat_by_beat_compare == 1'b1) begin
			   if(req.hwrite == READ) begin
				req.hrdata = p_sequencer.smem_h.read_mem(req.haddr_q.pop_front());
				//`uvm_send(req);
				start_item(req);
				finish_item(req);
			   end
			end
			else begin
			   if(req.hwrite == READ) begin
				//`uvm_send(req);
				start_item(req);
				finish_item(req);
			   end
			end
		end
	endtask 

endclass

`endif
