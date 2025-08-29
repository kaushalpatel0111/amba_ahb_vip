// AHB Master config class
`ifndef AHB_MAS_CFG
`define AHB_MAS_CFG

class ahb_mas_cfg extends ahb_cfg;
   
    virtual ahb_mas_intf mvif;

    int addr_width;
    int data_width;
    
    bit beat_by_beat_sample = 1'b0;

    bit enable_busy = 0;
    
    bit enable_error_injection = 0;

    function new(string name = "ahb_mas_cfg");
        super.new(name);
    endfunction
    
    `uvm_object_utils_begin(ahb_mas_cfg)
        `uvm_field_int(addr_width, UVM_ALL_ON)
        `uvm_field_int(data_width, UVM_ALL_ON)
	`uvm_field_int(beat_by_beat_sample, UVM_ALL_ON)
	`uvm_field_int(enable_busy, UVM_ALL_ON)
	`uvm_field_int(enable_error_injection, UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass

`endif
