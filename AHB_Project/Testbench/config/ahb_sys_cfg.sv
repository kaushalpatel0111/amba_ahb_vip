// AHB system config
`ifndef AHB_SYS_CFG
`define AHB_SYS_CFG

class ahb_sys_cfg extends uvm_object;
  
    ahb_mas_cfg mcfg_h;
    ahb_slv_cfg scfg_h;
    
    int num_master = 1;
    int num_slave = 1;
    
    ahb_mas_cfg master_cfg[];
    ahb_slv_cfg slave_cfg[];

    bit enable_scb = 0;

    bit enable_mfc = 0;
    bit enable_sfc = 0;

    bit beat_by_beat_compare = 0;

    function new(string name = "ahb_sys_cfg");
        super.new(name);
    endfunction

    function void create_sub_cfg();
        master_cfg = new[num_master];

      	foreach(master_cfg[i]) begin
            master_cfg[i] = ahb_mas_cfg::type_id::create($sformatf("master_cfg[%0d]", i));
        end
      
      	slave_cfg = new[num_slave];

        foreach(slave_cfg[i]) begin
            slave_cfg[i] = ahb_slv_cfg::type_id::create($sformatf("slave_cfg[%0d]", i));
        end
    endfunction

    `uvm_object_utils_begin(ahb_sys_cfg)
        `uvm_field_int(num_master, UVM_ALL_ON)
  	`uvm_field_int(num_slave, UVM_ALL_ON) 
        `uvm_field_int(enable_scb, UVM_ALL_ON)
	`uvm_field_int(enable_mfc, UVM_ALL_ON)
	`uvm_field_int(enable_sfc, UVM_ALL_ON)
        `uvm_field_int(beat_by_beat_compare, UVM_ALL_ON)
        `uvm_field_array_object(master_cfg, UVM_ALL_ON)
  	`uvm_field_array_object(slave_cfg, UVM_ALL_ON)
    `uvm_object_utils_end

endclass

`endif
