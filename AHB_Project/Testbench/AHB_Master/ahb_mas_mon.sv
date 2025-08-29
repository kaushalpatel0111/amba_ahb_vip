// AHB Master Monitor
`ifndef AHB_MAS_MON
`define AHB_MAS_MON

class ahb_mas_mon extends uvm_monitor;

	`uvm_component_utils(ahb_mas_mon)
	
	virtual ahb_mas_intf mvif;
	
	ahb_cust_cfg cust_cfg_h;
	ahb_transaction common_trans_h;
	ahb_mas_seq_item mitem_h;
	ahb_mas_seq_item mitem_collected_q[$];
	ahb_slv_mem smem_h;
	
	uvm_analysis_port #(ahb_transaction) item_req_port;
	
	//ahb_mas_seq_item mitem_collected[];
	//int pkt_cnt = -1;
	
	function new(string name = "ahb_mas_mon", uvm_component parent = null);
		super.new(name, parent);
		item_req_port = new("item_req_port", this);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		wait(!mvif.MMON.hresetn)
		mmon_reset();
		wait(mvif.MMON.hresetn)
		
		forever begin
			fork
			begin
				wait(!mvif.MMON.hresetn);
			end
			
			begin
			fork
				addr_phase();
				data_phase();
		  	join
		end
		join_any
		disable fork;
		mmon_reset();
		wait(mvif.MMON.hresetn);
		end
	endtask

	task mmon_reset();
		mitem_collected_q.delete();
	endtask
/*	
	task addr_phase();
		forever @(mvif.MMON.mmon_cb) begin
			`uvm_info("MMON_DEBUG", "ADDR_PHASE: Before if", UVM_DEBUG)
			if(mvif.MMON.mmon_cb.htrans == NONSEQ || mvif.MMON.mmon_cb.htrans == SEQ) begin
			`uvm_info("MMON_DEBUG", "ADDR_PHASE: After if", UVM_DEBUG)
				if(mvif.MMON.mmon_cb.htrans == NONSEQ) begin
					`uvm_info("MMON_DEBUG", "ADDR_PHASE: Inside NONSEQ if loop", UVM_DEBUG)
					pkt_cnt++;
					if(pkt_cnt != 0) begin
						mitem_collected = new[pkt_cnt + 1] (mitem_collected);
					end
					else
						mitem_collected = new[1];
						
					`uvm_info("MMON_DEBUG", "ADDR_PHASE: Before create(mitem_collected[pkt_cnt])", UVM_DEBUG)
					mitem_collected[pkt_cnt] = ahb_mas_seq_item::type_id::create("mitem_collected[pkt_cnt]");
					`uvm_info("MMON_DEBUG", "ADDR_PHASE: After create(mitem_collected[pkt_cnt])", UVM_DEBUG)
					mitem_collected[pkt_cnt].start_addr = mvif.MMON.mmon_cb.haddr;
					mitem_collected[pkt_cnt].hwrite = hwrite_enum'(mvif.MMON.mmon_cb.hwrite);
					mitem_collected[pkt_cnt].hsize = hsize_enum'(mvif.MMON.mmon_cb.hsize);
					mitem_collected[pkt_cnt].hburst_type = hburst_enum'(mvif.MMON.mmon_cb.hburst);
				end
				
				mitem_collected[pkt_cnt].haddr_q.push_back(mvif.MMON.mmon_cb.haddr);
	     			`uvm_info(get_name(), $sformatf("-----------------ADDR_PHASE TRANSACTION-----------------\n %s", mitem_collected[pkt_cnt].sprint()), UVM_DEBUG)
			end
		end
	endtask
	
	task data_phase();
		forever @(mvif.MMON.mmon_cb) begin
			`uvm_info("MMON_DEBUG", "DATA_PHASE: Before wait(mitem_collected.size() != 0)", UVM_DEBUG)
			wait(mitem_collected.size() > 0);
			`uvm_info("MMON_DEBUG", "DATA_PHASE: After wait(mitem_collected.size() != 0)", UVM_DEBUG)
			
			if(mitem_collected[pkt_cnt].hwrite == WRITE) begin
				`uvm_info("MMON_DEBUG", "DATA_PHASE: Inside if WRITE loop", UVM_DEBUG)
				if(mvif.MMON.mmon_cb.htrans == SEQ || mvif.MMON.mmon_cb.htrans == IDLE) begin
					mitem_collected[pkt_cnt].hwdata_q.push_back(mvif.MMON.mmon_cb.hwdata);
					mitem_collected[pkt_cnt].hwstrb_q.push_back(mvif.MMON.mmon_cb.hwstrb);
					`uvm_info("MMON_DEBUG", "DATA_PHASE: Before WRITE write() method", UVM_DEBUG)
					item_req_port.write(mitem_collected[pkt_cnt]);
					`uvm_info("MMON_DEBUG", "DATA_PHASE: After if WRITE write() method", UVM_DEBUG)
					`uvm_info(get_name(), $sformatf("-----------------MMON: DATA_PHASE WRITE TRANSACTION-----------------\n %s", mitem_collected[pkt_cnt].sprint()), UVM_DEBUG)
					`uvm_info("MMON_DEBUG", $sformatf("DATA_PHASE: pkt_cnt %0d", pkt_cnt), UVM_LOW)
					//smem_h.write_mem(mitem_collected[pkt_cnt].haddr_q.pop_front(), mitem_collected[pkt_cnt].hwdata_q.pop_front());
				end
			end
	    else begin
				`uvm_info("MMON_DEBUG", "DATA_PHASE: Inside if READ loop", UVM_DEBUG)
				mitem_collected[pkt_cnt].hrdata = mvif.MMON.mmon_cb.hrdata;
				`uvm_info(get_name(), $sformatf("-----------------MMON: DATA_PHASE READ TRANSACTION-----------------\n %s", mitem_collected[pkt_cnt].sprint()), UVM_LOW)
				item_req_port.write(mitem_collected[pkt_cnt]);
				`uvm_info("MMON_DEBUG", "DATA_PHASE: After READ write() method", UVM_DEBUG)
			end
		end
	endtask
*/
	task addr_phase();
		if(cust_cfg_h.mcfg_h.beat_by_beat_sample == 1'b1) begin
			addr_phase_beat();
		end
		else begin
			addr_phase_pkt();
		end
	endtask

	task data_phase();
		if(cust_cfg_h.mcfg_h.beat_by_beat_sample == 1'b1) begin
			data_phase_beat();
		end
		else begin
			data_phase_pkt();
		end
	endtask

	task addr_phase_beat();
		forever @(mvif.MMON.mmon_cb) begin
			if(mvif.MMON.mmon_cb.htrans != IDLE) begin
				mitem_h = new();

				mitem_h.hwrite = hwrite_enum'(mvif.MMON.mmon_cb.hwrite);
				mitem_h.hsize = hsize_enum'(mvif.MMON.mmon_cb.hsize);
				mitem_h.hburst_type = hburst_enum'(mvif.MMON.mmon_cb.hburst);
				mitem_h.htrans_q = {htrans_enum'(mvif.MMON.mmon_cb.htrans)};
				mitem_h.haddr_q = {mvif.MMON.mmon_cb.haddr};
				
				mitem_collected_q.push_back(mitem_h);

				$cast(common_trans_h, mitem_h.clone());
				if(mitem_h.hwrite == READ) item_req_port.write(common_trans_h);
			end
		end
	endtask
	
	task data_phase_beat();
		forever begin
			wait(mitem_collected_q.size() != 0);
			@(mvif.MMON.mmon_cb);

			if(mitem_collected_q[0].hwrite == WRITE) begin
				mitem_collected_q[0].hwdata_q = {mvif.MMON.mmon_cb.hwdata};
				mitem_collected_q[0].hwstrb_q = {mvif.MMON.mmon_cb.hwstrb};
				mitem_collected_q[0].hresp = hresp_enum'(mvif.MMON.mmon_cb.hresp);
				$cast(common_trans_h, mitem_collected_q[0].clone());
				item_req_port.write(common_trans_h);
			end
			else begin
				mitem_collected_q[0].hrdata = mvif.MMON.mmon_cb.hrdata;
				mitem_collected_q[0].hresp = hresp_enum'(mvif.MMON.mmon_cb.hresp);
				//$cast(common_trans_h, mitem_collected_q[0].clone());
				//item_req_port.write(common_trans_h);
			end
			
			`uvm_info(get_name(), $sformatf("-----------------MMON BEAT BY BEAT TRANSACTION-----------------\n %s", mitem_collected_q[0].sprint()), UVM_DEBUG)

			mitem_collected_q.delete(0);
		end
	endtask

	task addr_phase_pkt();
		forever @(mvif.MMON.mmon_cb) begin
				if(mvif.MMON.mmon_cb.htrans == NONSEQ || mvif.MMON.mmon_cb.htrans == SEQ) begin
				if(mvif.MMON.mmon_cb.htrans == NONSEQ) begin
					mitem_collected_q[0] = ahb_mas_seq_item::type_id::create("mitem_collected_q[0]");
					mitem_collected_q[0].hwrite = hwrite_enum'(mvif.MMON.mmon_cb.hwrite);
					mitem_collected_q[0].hsize = hsize_enum'(mvif.MMON.mmon_cb.hsize);
					mitem_collected_q[0].hburst_type = hburst_enum'(mvif.MMON.mmon_cb.hburst);
					mitem_collected_q[0].start_addr = mvif.MMON.mmon_cb.haddr;
				end

				mitem_collected_q[0].htrans_q.push_back(htrans_enum'(mvif.MMON.mmon_cb.htrans));
				mitem_collected_q[0].haddr_q.push_back(mvif.MMON.mmon_cb.haddr);
				
				if(mitem_collected_q[0].hwrite == READ) begin
					mitem_collected_q[0].hrdata_q.push_back(mvif.MMON.mmon_cb.hrdata);
					mitem_collected_q[0].hresp = hresp_enum'(mvif.MMON.mmon_cb.hresp);
					`uvm_info(get_name(), $sformatf("-----------------[READ] MMON PKT BY PKT TRANSACTION-----------------\n %s", mitem_collected_q[0].sprint()), UVM_DEBUG)
					$cast(common_trans_h, mitem_collected_q[0].clone());
					item_req_port.write(common_trans_h);
				end
				end
			end
	endtask

	task data_phase_pkt();
		forever begin
			wait(mitem_collected_q.size() != 0);
			@(mvif.MMON.mmon_cb);

			if(mitem_collected_q[0].hwrite == WRITE) begin
				if(mvif.MMON.mmon_cb.htrans == SEQ || mvif.MMON.mmon_cb.htrans == IDLE || mvif.MMON.mmon_cb.htrans == BUSY) begin
					mitem_collected_q[0].hwdata_q.push_back(mvif.MMON.mmon_cb.hwdata);
					if (cust_cfg_h.master_cfg[0].ahb_version == AHB5 || cust_cfg_h.slave_cfg[0].ahb_version == AHB)
						mitem_collected_q[0].hwstrb_q.push_back(mvif.MMON.mmon_cb.hwstrb);
					mitem_collected_q[0].hresp = hresp_enum'(mvif.MMON.mmon_cb.hresp);
					$cast(common_trans_h, mitem_collected_q[0].clone());
					`uvm_info(get_name(), $sformatf("-----------------[WRITE] MMON PKT BY PKT TRANSACTION-----------------\n %s", mitem_collected_q[0].sprint()), UVM_DEBUG)
					item_req_port.write(common_trans_h);
				end
			end
			//mitem_collected_q.delete(0);
		end
	endtask

endclass

`endif
