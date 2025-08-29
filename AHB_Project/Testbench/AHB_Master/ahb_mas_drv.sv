// AHB Master Driver
`ifndef AHB_MAS_DRV
`define AHB_MAS_DRV

class ahb_mas_drv extends uvm_driver #(ahb_mas_seq_item, ahb_mas_seq_item);
	
	`uvm_component_utils(ahb_mas_drv)
	
	ahb_mas_seq_item addr_phase_q[$];
	ahb_mas_seq_item data_phase_q[$];
	
	virtual ahb_mas_intf mvif;
	
	ahb_cust_cfg cust_cfg_h;
	
	function new(string name = "ahb_mas_drv", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		wait(!mvif.MDRV.hresetn)
		mreset_phase();
		wait(mvif.MDRV.hresetn)
		
		forever begin
			fork
			begin
				wait(!mvif.MDRV.hresetn);
			end
			
			forever @(mvif.MDRV.mdrv_cb) begin
				seq_item_port.get(req);
				req.print();
				if(!$cast(rsp, req.clone())) `uvm_fatal("MDRV", "cast to rsp failed!")
				rsp.set_id_info(req);
				addr_phase_q.push_back(req);
			end
			
			begin
			fork
				maddr_phase();
				mdata_phase();
			join
		end
		join_any
		disable fork;
		mreset_phase();
		wait(mvif.MDRV.hresetn);
		end
	endtask
	
	task mreset_phase();
		mvif.hwrite <= '0;
		mvif.hsize <= '0;
		mvif.hburst <= '0;
		mvif.htrans <= IDLE;
		mvif.haddr <= '0;
		mvif.hwdata <= '0;
		if (cust_cfg_h.master_cfg[0].ahb_version == AHB5 || cust_cfg_h.slave_cfg[0].ahb_version == AHB)
			mvif.hwstrb <= '0;
	endtask
	
	task maddr_phase();
		ahb_mas_seq_item req;
		//bit [`ADDRWIDTH-1:0] tmp_addr;
		
		forever begin
			wait(addr_phase_q.size() != 0);
			req = addr_phase_q.pop_front();

			//if(cust_cfg_h.mcfg_h.enable_busy == 1'b1) req.burst_len = req.burst_len + req.num_busy;
			
			for(int i=0; i<req.burst_len; i++) begin
				mvif.MDRV.mdrv_cb.hwrite <= req.hwrite;
				mvif.MDRV.mdrv_cb.hsize <=  req.hsize;
				mvif.MDRV.mdrv_cb.hburst <= req.hburst_type;
				mvif.MDRV.mdrv_cb.htrans <= req.htrans_q[i];
				if(i==0) data_phase_q.push_back(req);
				if(cust_cfg_h.mcfg_h.enable_busy == 1'b1 && i == req.index_busy) begin
					mvif.MDRV.mdrv_cb.htrans <= BUSY;
					repeat(req.num_busy) begin
						//req.htrans_q.insert(i, BUSY);
						//mvif.MDRV.mdrv_cb.htrans <= req.htrans_q[i];
						//tmp_addr = req.haddr_q[i];
						//req.haddr_q.insert(i, tmp_addr);
						//mvif.MDRV.mdrv_cb.haddr <= req.haddr_q[i];
				        	@(mvif.MDRV.mdrv_cb);
					end
					//continue;
				end
				//else begin
					mvif.MDRV.mdrv_cb.haddr <=  req.haddr_q[i];
				//end
				if(mvif.haddr>'h3FF && !mvif.hready && cust_cfg_h.mcfg_h.enable_error_injection == 1'b1) begin
					//@(mvif.MDRV.mdrv_cb);
					mvif.MDRV.mdrv_cb.htrans <= IDLE;
					mvif.MDRV.mdrv_cb.haddr <= '0;
					mvif.MDRV.mdrv_cb.hwrite <= '0;
					mvif.MDRV.mdrv_cb.hsize <= '0;
					mvif.MDRV.mdrv_cb.hburst <= '0;
				end
				@(mvif.MDRV.mdrv_cb);
			end

			if(addr_phase_q.size() == 0) begin
				if(req.hburst_type != INCR)
					mvif.MDRV.mdrv_cb.htrans <= IDLE;
				else
					mvif.MDRV.mdrv_cb.htrans <= BUSY;
				mvif.MDRV.mdrv_cb.haddr <= '0;
				mvif.MDRV.mdrv_cb.hwrite <= '0;
				mvif.MDRV.mdrv_cb.hsize <= '0;
				mvif.MDRV.mdrv_cb.hburst <= '0;
			end
		end
	endtask
	
	task mdata_phase();
		ahb_mas_seq_item req;
		
		forever begin
			wait(data_phase_q.size() != 0)
			req = data_phase_q.pop_front();
			
			@(mvif.MDRV.mdrv_cb);
			for(int i=0; i<req.burst_len; i++) begin
				if(req.hwrite == WRITE) begin
					if(cust_cfg_h.mcfg_h.enable_busy == 1'b1 && i == req.index_busy) begin
						repeat(req.num_busy) begin
							//req.hwdata_q.insert(i, '0);
							//mvif.MDRV.mdrv_cb.hwdata <= req.hwdata_q[i];
							//req.hwstrb_q.insert(i, '0);
							//mvif.MDRV.mdrv_cb.htrans <= req.hwstrb_q[i];
				        		@(mvif.MDRV.mdrv_cb);
						end
						//continue;
					end
					//else begin
						mvif.MDRV.mdrv_cb.hwdata <= req.hwdata_q[i];
						if (cust_cfg_h.master_cfg[0].ahb_version == AHB5 || cust_cfg_h.slave_cfg[0].ahb_version == AHB)
							mvif.MDRV.mdrv_cb.hwstrb <= req.hwstrb_q[i];
					//end
					if(req.haddr_q[i]>'h3FF && !mvif.hready && cust_cfg_h.mcfg_h.enable_error_injection == 1'b1) begin
						//@(mvif.MDRV.mdrv_cb);
						mvif.MDRV.mdrv_cb.hwdata <= '0;
						mvif.MDRV.mdrv_cb.hwstrb <= '0;
					end
				end
				@(mvif.MDRV.mdrv_cb);
			end
				
			if(data_phase_q.size() == 0) begin
				mvif.MDRV.mdrv_cb.hwdata <= '0;
				if (cust_cfg_h.master_cfg[0].ahb_version == AHB5 || cust_cfg_h.slave_cfg[0].ahb_version == AHB)
					mvif.MDRV.mdrv_cb.hwstrb <= '0;
			end
				
			`uvm_info("MDRV_DEBUG", "Before put_response", UVM_DEBUG)
			seq_item_port.put_response(rsp);
			`uvm_info("MDRV_DEBUG", "After put_response", UVM_DEBUG)
		end
	endtask

endclass

`endif
