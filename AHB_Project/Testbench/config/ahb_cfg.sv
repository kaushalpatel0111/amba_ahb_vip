// AHB Main config class
`ifndef AHB_CFG
`define AHB_CFG

typedef enum bit[1:0] {AHB_LITE, AHB5, AHB} ahb_version_t;

class ahb_cfg extends uvm_object;
   
    

    function new(string name = "ahb_mas_cfg");
        super.new(name);
    endfunction
    
    ahb_version_t ahb_version = AHB;

    uvm_active_passive_enum is_active = UVM_ACTIVE;
   
    `uvm_object_utils_begin(ahb_cfg)
        `uvm_field_enum(ahb_version_t, ahb_version, UVM_ALL_ON)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass

`endif
