// AHB Master Sequencer
`ifndef AHB_MAS_SEQR
`define AHB_MAS_SEQR

class ahb_mas_seqr extends uvm_sequencer#(ahb_mas_seq_item);
    
    `uvm_component_utils(ahb_mas_seqr)

    function new(string name = "ahb_mas_seqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass

`endif
