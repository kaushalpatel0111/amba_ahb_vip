// AHB Base Seq
`ifndef AHB_BASE_SEQ
`define AHB_BASE_SEQ

class ahb_base_seq extends uvm_sequence #(ahb_transaction);

    `uvm_object_utils(ahb_base_seq)
    
    function new(string name = "ahb_base_seq");
        super.new(name);
    endfunction

endclass

`endif
