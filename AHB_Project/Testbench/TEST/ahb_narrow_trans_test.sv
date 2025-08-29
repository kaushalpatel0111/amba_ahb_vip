// AHB Narrow Transfer Test
`ifndef AHB_NARROW_TRANS_TEST
`define AHB_NARROW_TRANS_TEST

class ahb_narrow_transfer_test extends ahb_base_test;
    
    `uvm_component_utils(ahb_narrow_transfer_test)

    ahb_narrow_transfer_seq narrow_transfer_seq_h;
    ahb_slv_base_seq sbase_seq_h;

    function new(string name = "ahb_narrow_transfer_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        narrow_transfer_seq_h = ahb_narrow_transfer_seq::type_id::create("narrow_transfer_seq_h");
        sbase_seq_h = ahb_slv_base_seq::type_id::create("sbase_seq_h");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
	assert(narrow_transfer_seq_h.randomize with {no_of_txn == 1;})
	else `uvm_fatal("NARROW_TRANS_TEST","SEQUENCE RANDOMIZATION FAILED!")
         
      	fork 
        	narrow_transfer_seq_h.start(env_h.magnt_h[0].mseqr_h);
        	sbase_seq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sbase_seq_h.kill();
	
	phase.phase_done.set_drain_time(this, 50); 
        phase.drop_objection(this);
    endtask

endclass

`endif
