// AHB custom config
`ifndef AHB_CUST_CFG
`define AHB_CUST_CFG

class ahb_cust_cfg extends ahb_sys_cfg;
    
    `uvm_object_utils(ahb_cust_cfg)
      
    function new(string name = "ahb_cust_cfg");
        super.new(name);

        mcfg_h = new();

        this.num_master = 1;
        
        this.create_sub_cfg(); 
        
      	this.master_cfg[0].ahb_version = AHB;
        this.master_cfg[0].is_active = UVM_ACTIVE;
        this.master_cfg[0].addr_width = 32;
        this.master_cfg[0].data_width = 32;
/*
      	this.master_cfg[1].ahb_version = AHB;
        this.master_cfg[1].is_active = UVM_ACTIVE;
        this.master_cfg[1].addr_width = 32;
        this.master_cfg[1].data_width = 32;
*/      
      	scfg_h = new();

        this.num_slave = 1;
        
        this.create_sub_cfg(); 
        
      	this.slave_cfg[0].ahb_version = AHB;
        this.slave_cfg[0].is_active = UVM_ACTIVE;
        this.slave_cfg[0].addr_width = 32;
        this.slave_cfg[0].data_width = 32;
/*
      	this.slave_cfg[1].ahb_version = AHB;
        this.slave_cfg[1].is_active = UVM_ACTIVE;
        this.slave_cfg[1].addr_width = 32;
        this.slave_cfg[1].data_width = 32;
*/        
        this.enable_scb = 1;

	this.enable_mfc = 1;
        this.enable_sfc = 1;

        this.beat_by_beat_compare = 0;
        
	this.mcfg_h.enable_busy = 1;
	this.scfg_h.enable_busy = 1;
        
	this.mcfg_h.enable_error_injection = 0;
	this.scfg_h.enable_error_injection = 0;

	this.mcfg_h.beat_by_beat_sample = 1'b0;
	this.scfg_h.beat_by_beat_sample = 1'b0;
    endfunction
    
endclass

`endif
