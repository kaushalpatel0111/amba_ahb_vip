// AHB Slave Driver
`ifndef AHB_SLV_DRV
`define AHB_SLV_DRV

class ahb_slv_drv extends uvm_driver #(ahb_slv_seq_item, ahb_slv_seq_item);

	`uvm_component_utils(ahb_slv_drv)
	
	virtual ahb_slv_intf svif;
	
	ahb_cust_cfg cust_cfg_h;
	
	ahb_slv_mem smem_h;
	
	function new(string name = "ahb_slv_drv", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		wait(!svif.SDRV.hresetn)
		sreset_phase();
		wait(svif.SDRV.hresetn)
		
		forever begin
			fork
			begin
				wait(!svif.SDRV.hresetn);
			end
			
			begin
			fork
				error_resp();
				read_resp();
			join
			end	
			join_any
			disable fork;
			sreset_phase();
			wait(svif.SDRV.hresetn);
			end
	endtask
	
	task sreset_phase();
		svif.hready <= 1'b1;
		svif.hrdata <= '0;
		svif.hresp <= OKAY;
	endtask

	task error_resp();
		forever @(svif.SDRV.sdrv_cb) begin
			if(svif.haddr>'h3FF && cust_cfg_h.scfg_h.enable_error_injection == 1'b1) begin
				svif.SDRV.sdrv_cb.hready <= 1'b0;
				svif.SDRV.sdrv_cb.hresp <= ERROR;
				@(svif.SDRV.sdrv_cb);
				svif.SDRV.sdrv_cb.hready <= 1'b1;
				svif.SDRV.sdrv_cb.hrdata <= 1'b0;
				svif.SDRV.sdrv_cb.hresp <= ERROR;
				@(svif.SDRV.sdrv_cb);
				svif.SDRV.sdrv_cb.hresp <= OKAY;
			end
		end
	endtask

	task read_resp();
		forever @(svif.SDRV.sdrv_cb) begin
			seq_item_port.get_next_item(req);
			req.print();
			if(svif.haddr<='h3FF && cust_cfg_h.scfg_h.enable_error_injection == 1'b1) begin
				svif.SDRV.sdrv_cb.hready <= 1'b1;
				svif.SDRV.sdrv_cb.hrdata <= req.hrdata;
				svif.SDRV.sdrv_cb.hresp <= OKAY;
			end
			else if(cust_cfg_h.scfg_h.enable_error_injection == 1'b0) begin
				svif.SDRV.sdrv_cb.hready <= 1'b1;
				svif.SDRV.sdrv_cb.hrdata <= req.hrdata;
				svif.SDRV.sdrv_cb.hresp <= OKAY;
			end
			seq_item_port.item_done();
		end
	endtask

endclass

`endif
