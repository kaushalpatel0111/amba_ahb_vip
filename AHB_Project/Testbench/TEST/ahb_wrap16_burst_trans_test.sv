// AHB WRAP16 HTRANS Test
`ifndef AHB_WRAP16_HTRANS_TEST
`define AHB_WRAP16_HTRANS_TEST

class ahb_wrap16_burst_test extends ahb_base_test;
    
    `uvm_component_utils(ahb_wrap16_burst_test)

    ahb_wrap16_burst_seq wrap16_burst_seq_h;
    ahb_slv_base_seq sbase_seq_h;

    function new(string name = "ahb_wrap16_burst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        wrap16_burst_seq_h = ahb_wrap16_burst_seq::type_id::create("wrap16_burst_seq_h");
        sbase_seq_h = ahb_slv_base_seq::type_id::create("sbase_seq_h");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
	assert(wrap16_burst_seq_h.randomize with {no_of_txn == 1;})
	else `uvm_fatal("WRAP16_HTRANS_TEST","SEQUENCE RANDOMIZATION FAILED!")
         
      	fork 
        	wrap16_burst_seq_h.start(env_h.magnt_h[0].mseqr_h);
        	sbase_seq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sbase_seq_h.kill();
	
	phase.phase_done.set_drain_time(this, 50); 
        phase.drop_objection(this);
    endtask

endclass

`endif
