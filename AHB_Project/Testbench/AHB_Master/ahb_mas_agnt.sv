// AHB Master Agent
`ifndef AHB_MAS_AGNT
`define AHB_MAS_AGNT

class ahb_mas_agnt extends uvm_agent;

	`uvm_component_utils(ahb_mas_agnt)
	
	ahb_mas_cfg mcfg_h;
	ahb_cust_cfg cust_cfg_h;
	ahb_mas_mon mmon_h;
	ahb_mas_drv mdrv_h;
	ahb_mas_seqr mseqr_h;
	
	function new(string name = "ahb_mas_agnt", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if (!uvm_config_db #(ahb_cust_cfg)::get(this," ", "ahb_cust_cfg", cust_cfg_h))
			`uvm_fatal("MAGNT_FATAL", "Master Configuration object is not set properly");
			
			mmon_h = ahb_mas_mon::type_id::create("mmon_h", this);
			mmon_h.mvif = cust_cfg_h.mcfg_h.mvif;
			mmon_h.cust_cfg_h = cust_cfg_h;
			
			if (cust_cfg_h.master_cfg[0].is_active == UVM_ACTIVE) begin
				mdrv_h = ahb_mas_drv::type_id::create("mdrv_h", this);
				mdrv_h.mvif = cust_cfg_h.mcfg_h.mvif;
				mdrv_h.cust_cfg_h = cust_cfg_h;
				mseqr_h = ahb_mas_seqr::type_id::create("mseqr_h", this);
			end
		endfunction
		
		function void connect_phase(uvm_phase phase);
			if (cust_cfg_h.master_cfg[0].is_active == UVM_ACTIVE) begin
				mdrv_h.seq_item_port.connect(mseqr_h.seq_item_export);
			end
		endfunction

endclass

`endif 
