// AHB Slave Agent
`ifndef AHB_SLV_AGNT
`define AHB_SLV_AGNT

class ahb_slv_agnt extends uvm_agent;
	
	`uvm_component_utils(ahb_slv_agnt)
	
	ahb_slv_cfg scfg_h;
	ahb_cust_cfg cust_cfg_h;
	ahb_slv_mon smon_h;
	ahb_slv_drv sdrv_h;
	ahb_slv_seqr sseqr_h;
	ahb_slv_mem smem_h;
	
	function new(string name = "ahb_slv_agnt", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if (!uvm_config_db #(ahb_cust_cfg)::get(this," ", "ahb_cust_cfg", cust_cfg_h))
			`uvm_fatal("SAGNT_FATAL", "Slave Configuration object is not set properly");
			
		smon_h = ahb_slv_mon::type_id::create("smon_h", this);
		smon_h.svif = cust_cfg_h.scfg_h.svif;
		smon_h.cust_cfg_h = cust_cfg_h;
		smem_h = ahb_slv_mem::type_id::create("smem_h", this);
			
		if (cust_cfg_h.slave_cfg[0].is_active == UVM_ACTIVE) begin
			sdrv_h = ahb_slv_drv::type_id::create("sdrv_h", this);
			sdrv_h.cust_cfg_h = cust_cfg_h;
			sdrv_h.svif = cust_cfg_h.scfg_h.svif;
			sseqr_h = ahb_slv_seqr::type_id::create("sseqr_h", this);
			sseqr_h.cust_cfg_h = cust_cfg_h;
		end
	endfunction
	
	function void connect_phase(uvm_phase phase);
		smon_h.smem_h = this.smem_h;
		smon_h.item_req_port.connect(sseqr_h.item_req_fifo.analysis_export);
		
		if (cust_cfg_h.slave_cfg[0].is_active == UVM_ACTIVE) begin
			sseqr_h.smem_h = this.smem_h;
			sdrv_h.smem_h = this.smem_h;
			sdrv_h.seq_item_port.connect(sseqr_h.seq_item_export);
		end
		
	endfunction

endclass

`endif 
