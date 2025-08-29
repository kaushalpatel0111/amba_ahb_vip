// AHB BUSY during undefined length HBURST Test
`ifndef AHB_BUSY_DURING_UNDEF_LEN_HBURST_TEST
`define AHB_BUSY_DURING_UNDEF_LEN_HBURST_TEST

class ahb_busy_during_undef_len_burst_test extends ahb_base_test;
    
    `uvm_component_utils(ahb_busy_during_undef_len_burst_test)

    ahb_incr_burst_seq incr_burst_seq_h;
    ahb_slv_base_seq sbase_seq_h;
    ahb_incr4_burst_seq incr4_burst_seq_h;

    function new(string name = "ahb_busy_during_undef_len_burst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        incr_burst_seq_h = ahb_incr_burst_seq::type_id::create("incr_burst_seq_h");
        sbase_seq_h = ahb_slv_base_seq::type_id::create("sbase_seq_h");
	incr4_burst_seq_h = ahb_incr4_burst_seq::type_id::create("incr4_burst_seq_h");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
	assert(incr_burst_seq_h.randomize with {no_of_txn == 1;})
	else `uvm_fatal("BUSY_DURING_UNDEF_LEN_HBURST_TEST","SEQUENCE RANDOMIZATION FAILED!")
      	fork 
        	incr_burst_seq_h.start(env_h.magnt_h[0].mseqr_h);
        	sbase_seq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sbase_seq_h.kill();
	
	assert(incr4_burst_seq_h.randomize with {no_of_txn == 1;})
	else `uvm_fatal("BUSY_DURING_UNDEF_LEN_HBURST_TEST","SEQUENCE RANDOMIZATION FAILED!")
      	fork 
        	incr4_burst_seq_h.start(env_h.magnt_h[0].mseqr_h);
        	sbase_seq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sbase_seq_h.kill();
	
	phase.phase_done.set_drain_time(this, 250); 
        phase.drop_objection(this);
    endtask

endclass

`endif
