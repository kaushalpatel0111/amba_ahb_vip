// AHB Random Burst Transfer Test
`ifndef AHB_RANDOM_BURST_TRANS_TEST
`define AHB_RANDOM_BURST_TRANS_TEST

class ahb_random_burst_transfer_test extends ahb_base_test;
    
    `uvm_component_utils(ahb_random_burst_transfer_test)

    ahb_random_burst_seq rand_burst_seq_h;
    ahb_slv_base_seq sbase_seq_h;

    function new(string name = "ahb_random_burst_transfer_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        rand_burst_seq_h = ahb_random_burst_seq::type_id::create("rand_burst_seq_h");
        sbase_seq_h = ahb_slv_base_seq::type_id::create("sbase_seq_h");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
	assert(rand_burst_seq_h.randomize with {no_of_txn == 50;})
	else `uvm_fatal("RANDOM_BURST_TEST","SEQUENCE RANDOMIZATION FAILED!")
         
      	fork 
        	rand_burst_seq_h.start(env_h.magnt_h[0].mseqr_h);
        	sbase_seq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sbase_seq_h.kill();
	
	phase.phase_done.set_drain_time(this, 50000); 
        phase.drop_objection(this);
    endtask

endclass

`endif
