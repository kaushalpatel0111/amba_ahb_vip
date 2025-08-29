// AHB Sanity Test
`ifndef AHB_SANITY_TEST
`define AHB_SANITY_TEST

class ahb_sanity_test extends ahb_base_test;
    
    `uvm_component_utils(ahb_sanity_test)

    ahb_mas_sanity_seq msanity_seq_h;
    ahb_slv_base_seq sbase_seq_h;

    function new(string name = "ahb_sanity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        msanity_seq_h = ahb_mas_sanity_seq::type_id::create("msanity_seq_h");
        sbase_seq_h = ahb_slv_base_seq::type_id::create("sbase_seq_h");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
	assert(msanity_seq_h.randomize with {no_of_txn == 1;})
	else `uvm_fatal("SANITY_TEST","SEQUENCE RANDOMIZATION FAILED!")
         
      	fork 
        	msanity_seq_h.start(env_h.magnt_h[0].mseqr_h);
        	sbase_seq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sbase_seq_h.kill();
	
	phase.phase_done.set_drain_time(this, 2500); 
        phase.drop_objection(this);
    endtask

endclass

`endif
