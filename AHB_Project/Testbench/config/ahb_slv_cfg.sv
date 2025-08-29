// AHB Slave config class
`ifndef AHB_SLV_CFG
`define AHB_SLV_CFG

class ahb_slv_cfg extends ahb_cfg;
   
    virtual ahb_slv_intf svif;

    int addr_width;
    int data_width;

    bit beat_by_beat_sample = 1'b0;

    bit enable_busy = 0;

    bit enable_error_injection = 0;

    function new(string name = "ahb_slv_cfg");
        super.new(name);
    endfunction
   
    `uvm_object_utils_begin(ahb_slv_cfg)
        `uvm_field_int(addr_width, UVM_ALL_ON)
        `uvm_field_int(data_width, UVM_ALL_ON)
	`uvm_field_int(beat_by_beat_sample, UVM_ALL_ON)
	`uvm_field_int(enable_busy, UVM_ALL_ON)
	`uvm_field_int(enable_error_injection, UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass

`endif
