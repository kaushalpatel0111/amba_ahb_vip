// AHB Slave Monitor
`ifndef AHB_SLV_MON
`define AHB_SLV_MON

class ahb_slv_mon extends uvm_monitor;

	`uvm_component_utils(ahb_slv_mon)
	
	virtual ahb_slv_intf svif;
	
	ahb_cust_cfg cust_cfg_h;
	ahb_transaction common_trans_h;
	ahb_slv_seq_item sitem_h;
	ahb_slv_seq_item sitem_collected_q[$];
	ahb_slv_mem smem_h;
	
	bit[`ADDRWIDTH-1:0] tmp_addr_q[$];
	
	uvm_analysis_port #(ahb_transaction) item_req_port;
	
	//ahb_slv_seq_item sitem_collected[];
	//int pkt_cnt = -1;
	
	function new(string name = "ahb_slv_mon", uvm_component parent = null);
		super.new(name, parent);
		item_req_port = new("item_req_port", this);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		wait(!svif.SMON.hresetn)
		smon_reset();
		wait(svif.SMON.hresetn)
		
		forever begin
			fork
			begin
				wait(!svif.SMON.hresetn);
			end
			
			begin
			fork
				addr_phase();
				data_phase();
		  	join
			end
			join_any
			disable fork;
			smon_reset();
			wait(svif.SMON.hresetn);
		end
	endtask

	task smon_reset();
		sitem_collected_q.delete();
	endtask
		
/*	
	task addr_phase();
		forever @(svif.SMON.smon_cb) begin
			`uvm_info("SMON_DEBUG", "ADDR_PHASE: Before if", UVM_DEBUG)
			if(svif.SMON.smon_cb.htrans == NONSEQ || svif.SMON.smon_cb.htrans == SEQ) begin
			`uvm_info("SMON_DEBUG", "ADDR_PHASE: After if", UVM_DEBUG)
				if(svif.SMON.smon_cb.htrans == NONSEQ) begin
					`uvm_info("SMON_DEBUG", "ADDR_PHASE: Inside NONSEQ if loop", UVM_DEBUG)
					pkt_cnt++;
					if(pkt_cnt != 0) begin
						sitem_collected = new[pkt_cnt + 1] (sitem_collected);
					end
					else
						sitem_collected = new[1];
						
					`uvm_info("SMON_DEBUG", "ADDR_PHASE: Before create(sitem_collected[pkt_cnt])", UVM_DEBUG)
					sitem_collected[pkt_cnt] = ahb_slv_seq_item::type_id::create("sitem_collected[pkt_cnt]");
					`uvm_info("SMON_DEBUG", "ADDR_PHASE: After create(sitem_collected[pkt_cnt])", UVM_DEBUG)
					sitem_collected[pkt_cnt].start_addr = svif.SMON.smon_cb.haddr;
					sitem_collected[pkt_cnt].hwrite = hwrite_enum'(svif.SMON.smon_cb.hwrite);
					sitem_collected[pkt_cnt].hsize = hsize_enum'(svif.SMON.smon_cb.hsize);
					sitem_collected[pkt_cnt].hburst_type = hburst_enum'(svif.SMON.smon_cb.hburst);
				end
				
				sitem_collected[pkt_cnt].haddr_q.push_back(svif.SMON.smon_cb.haddr);
	     			`uvm_info(get_name(), $sformatf("-----------------ADDR_PHASE WRITE TRANSACTION-----------------\n %s", sitem_collected[pkt_cnt].sprint()), UVM_DEBUG)
			end
		end
	endtask
	
	task data_phase();
		forever @(svif.SMON.smon_cb) begin
			`uvm_info("SMON_DEBUG", "DATA_PHASE: Before wait(sitem_collected.size() != 0)", UVM_DEBUG)
			wait(sitem_collected.size() > 0);
			`uvm_info("SMON_DEBUG", "DATA_PHASE: After wait(sitem_collected.size() != 0)", UVM_DEBUG)
			
			if(sitem_collected[pkt_cnt].hwrite == WRITE) begin
				`uvm_info("SMON_DEBUG", "DATA_PHASE: Inside if WRITE loop", UVM_DEBUG)
				if(svif.SMON.smon_cb.htrans == SEQ || svif.SMON.smon_cb.htrans == IDLE) begin
					sitem_collected[pkt_cnt].hwdata_q.push_back(svif.SMON.smon_cb.hwdata);
					sitem_collected[pkt_cnt].hwstrb_q.push_back(svif.SMON.smon_cb.hwstrb);
					`uvm_info("SMON_DEBUG", "DATA_PHASE: Before WRITE write() method", UVM_DEBUG)
					item_req_port.write(sitem_collected[pkt_cnt]);
					`uvm_info("SMON_DEBUG", "DATA_PHASE: After if WRITE write() method", UVM_DEBUG)
					`uvm_info(get_name(), $sformatf("-----------------DATA_PHASE WRITE TRANSACTION-----------------\n %s", sitem_collected[pkt_cnt].sprint()), UVM_DEBUG)
					`uvm_info("SMON_DEBUG", $sformatf("DATA_PHASE: [SLAVE] pkt_cnt %0d", pkt_cnt), UVM_LOW)
					smem_h.write_mem(sitem_collected[pkt_cnt].haddr_q.pop_front(), sitem_collected[pkt_cnt].hwdata_q.pop_front());
				end
			end
	    		else begin
				`uvm_info("SMON_DEBUG", "DATA_PHASE: Inside if READ loop", UVM_DEBUG)
				sitem_collected[pkt_cnt].hrdata = svif.SMON.smon_cb.hrdata;
				`uvm_info(get_name(), $sformatf("-----------------DATA_PHASE READ TRANSACTION-----------------\n %s \n sitem_collected: %p", sitem_collected[pkt_cnt].sprint(), sitem_collected), UVM_LOW)
				item_req_port.write(sitem_collected[pkt_cnt]);
				`uvm_info("SMON_DEBUG", "DATA_PHASE: After READ write() loop", UVM_DEBUG)
			end
		end
	endtask
*/
	task addr_phase();
		if(cust_cfg_h.scfg_h.beat_by_beat_sample == 1'b1) begin
			addr_phase_beat();
		end
		else begin
			addr_phase_pkt();
		end
	endtask

	task data_phase();
		if(cust_cfg_h.scfg_h.beat_by_beat_sample == 1'b1) begin
			data_phase_beat();
		end
		else begin
			data_phase_pkt();
		end
	endtask

	task addr_phase_beat();
		forever @(svif.SMON.smon_cb) begin
			if(svif.SMON.smon_cb.htrans != IDLE) begin
				sitem_h = new();

				sitem_h.hwrite = hwrite_enum'(svif.SMON.smon_cb.hwrite);
				sitem_h.hsize = hsize_enum'(svif.SMON.smon_cb.hsize);
				sitem_h.hburst_type = hburst_enum'(svif.SMON.smon_cb.hburst);
				sitem_h.htrans_q = {htrans_enum'(svif.SMON.smon_cb.htrans)};
				sitem_h.haddr_q = {svif.SMON.smon_cb.haddr};
				
				sitem_collected_q.push_back(sitem_h);
				
				$cast(common_trans_h, sitem_h.clone());
				if(sitem_h.hwrite == READ) item_req_port.write(common_trans_h);
				`uvm_info(get_name(), $sformatf("-----------------SMON BEAT BY BEAT TRANSACTION-----------------\n %s", sitem_h.sprint()), UVM_DEBUG)
			end
		end
	endtask
	
	task data_phase_beat();
		forever begin
			wait(sitem_collected_q.size() != 0);
			@(svif.SMON.smon_cb);

			if(sitem_collected_q[0].hwrite == WRITE) begin
				sitem_collected_q[0].hwdata_q = {svif.SMON.smon_cb.hwdata};
				//if (cust_cfg_h.slave_cfg[0].ahb_version == AHB5 || cust_cfg_h.slave_cfg[0].ahb_version == AHB) begin
				`ifdef AHB5
					sitem_collected_q[0].hwstrb_q = {svif.SMON.smon_cb.hwstrb};
					smem_h.wstrb_mem(sitem_collected_q[0].haddr_q[0], sitem_collected_q[0].hwdata_q[0], sitem_collected_q[0].hwstrb_q[0]);
				//end
				//else begin
				`else
					smem_h.write_mem(sitem_collected_q[0].haddr_q[0], sitem_collected_q[0].hwdata_q[0]);
				//end
				`endif
				sitem_collected_q[0].hresp = hresp_enum'(svif.SMON.smon_cb.hresp);
				$cast(common_trans_h, sitem_collected_q[0].clone());
				`uvm_info(get_name(), $sformatf("-----------------[WRITE] SMON BEAT BY BEAT TRANSACTION-----------------\n %s", sitem_collected_q[0].sprint()), UVM_DEBUG)
				item_req_port.write(common_trans_h);
			end
			else begin
				sitem_collected_q[0].hrdata = svif.SMON.smon_cb.hrdata;
				sitem_collected_q[0].hresp = hresp_enum'(svif.SMON.smon_cb.hresp);
				//$cast(common_trans_h, sitem_collected_q[0].clone());
				`uvm_info(get_name(), $sformatf("-----------------[READ] SMON BEAT BY BEAT TRANSACTION-----------------\n %s", sitem_collected_q[0].sprint()), UVM_DEBUG)
				//item_req_port.write(common_trans_h);
			end
			`uvm_info(get_name(), $sformatf("-----------------SMON BEAT BY BEAT TRANSACTION-----------------\n %s", sitem_collected_q[0].sprint()), UVM_DEBUG)

			sitem_collected_q.delete(0);
		end
	endtask

	task addr_phase_pkt();

		forever @(svif.SMON.smon_cb) begin
			if(svif.SMON.smon_cb.htrans == NONSEQ || svif.SMON.smon_cb.htrans == SEQ) begin
				if(svif.SMON.smon_cb.htrans == NONSEQ) begin
					sitem_collected_q[0] = ahb_slv_seq_item::type_id::create("sitem_collected_q[0]");
					sitem_collected_q[0].hwrite = hwrite_enum'(svif.SMON.smon_cb.hwrite);
					sitem_collected_q[0].hsize = hsize_enum'(svif.SMON.smon_cb.hsize);
					sitem_collected_q[0].hburst_type = hburst_enum'(svif.SMON.smon_cb.hburst);
					sitem_collected_q[0].start_addr = svif.SMON.smon_cb.haddr;
				end
				
				sitem_collected_q[0].htrans_q.push_back(htrans_enum'(svif.SMON.smon_cb.htrans));
				sitem_collected_q[0].haddr_q.push_back(svif.SMON.smon_cb.haddr);
				tmp_addr_q.push_back(svif.SMON.smon_cb.haddr);
				
				if(sitem_collected_q[0].hwrite == READ) begin
					sitem_collected_q[0].hrdata = smem_h.read_mem(tmp_addr_q.pop_front());
					sitem_collected_q[0].hrdata_q.push_back(sitem_collected_q[0].hrdata);
					sitem_collected_q[0].hresp = hresp_enum'(svif.SMON.smon_cb.hresp);
					`uvm_info(get_name(), $sformatf("-----------------[READ] SMON PKT BY PKT TRANSACTION-----------------\n %s", sitem_collected_q[0].sprint()), UVM_DEBUG)
					$cast(common_trans_h, sitem_collected_q[0].clone());
					item_req_port.write(common_trans_h);
				end 
			end
		end
	endtask

	task data_phase_pkt();
		forever @(svif.SMON.smon_cb) begin
			wait(sitem_collected_q.size() != 0);

			if(sitem_collected_q[0].hwrite == WRITE) begin
				if(svif.SMON.smon_cb.htrans == SEQ || svif.SMON.smon_cb.htrans == IDLE || svif.SMON.smon_cb.htrans == BUSY) begin
					sitem_collected_q[0].hwdata_q.push_back(svif.SMON.smon_cb.hwdata);
					//if (cust_cfg_h.slave_cfg[0].ahb_version == AHB5 || cust_cfg_h.slave_cfg[0].ahb_version == AHB)
					`ifdef AHB5
						sitem_collected_q[0].hwstrb_q.push_back(svif.SMON.smon_cb.hwstrb);
					`endif
					sitem_collected_q[0].hresp = hresp_enum'(svif.SMON.smon_cb.hresp);
					$cast(common_trans_h, sitem_collected_q[0].clone());
					`uvm_info(get_name(), $sformatf("-----------------[WRITE] SMON PKT BY PKT TRANSACTION-----------------\n %s", sitem_collected_q[0].sprint()), UVM_DEBUG)
					item_req_port.write(common_trans_h);
					//if (cust_cfg_h.slave_cfg[0].ahb_version == AHB5 || cust_cfg_h.slave_cfg[0].ahb_version == AHB)
					`ifdef AHB5
						smem_h.wstrb_mem(tmp_addr_q.pop_front(), sitem_collected_q[0].hwdata_q.pop_front(), sitem_collected_q[0].hwstrb_q.pop_front());
					//else
					`else
						smem_h.write_mem(tmp_addr_q.pop_front(), sitem_collected_q[0].hwdata_q.pop_front());
					`endif
				end
			end
			//sitem_collected_q.delete(0);
		end
	endtask

endclass

`endif
