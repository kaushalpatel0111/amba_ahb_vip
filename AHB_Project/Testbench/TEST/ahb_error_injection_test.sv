// AHB Error Injection Test
`ifndef AHB_ERROR_INJECTION_TEST
`define AHB_ERROR_INJECTION_TEST

class ahb_error_injection_test extends ahb_base_test;
    
    `uvm_component_utils(ahb_error_injection_test)

    ahb_error_seq error_seq_h;
    ahb_slv_base_seq sbase_seq_h;

    function new(string name = "ahb_error_injection_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        error_seq_h = ahb_error_seq::type_id::create("error_seq_h");
        sbase_seq_h = ahb_slv_base_seq::type_id::create("sbase_seq_h");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
	assert(error_seq_h.randomize with {no_of_txn == 1;})
	else `uvm_fatal("ERROR_INJECTION_TEST","SEQUENCE RANDOMIZATION FAILED!")
         
      	fork 
        	error_seq_h.start(env_h.magnt_h[0].mseqr_h);
        	sbase_seq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sbase_seq_h.kill();
	
	phase.phase_done.set_drain_time(this, 500); 
        phase.drop_objection(this);
    endtask

endclass

`endif
