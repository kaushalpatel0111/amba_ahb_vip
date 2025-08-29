// Testcase- 1: in_bw_rst
`ifndef AHB_IN_BW_RST_TEST
`define AHB_IN_BW_RST_TEST

class ahb_in_bw_rst_test extends ahb_base_test;
    
    `uvm_component_utils(ahb_in_bw_rst_test)

    ahb_mas_sanity_seq mseq_h;
    ahb_rst_seq rst_seq_h;
    ahb_slv_base_seq sseq_h;

    function new(string name = "ahb_in_bw_rst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        mseq_h = ahb_mas_sanity_seq::type_id::create("mseq_h");
        rst_seq_h = ahb_rst_seq::type_id::create("rst_seq_h");  
	sseq_h = ahb_slv_base_seq::type_id::create("sseq_h");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
               
	assert(mseq_h.randomize with {no_of_txn == 1;})
	fork
		mseq_h.start(env_h.magnt_h[0].mseqr_h);
        	sseq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sseq_h.kill();

        rst_seq_h.start(env_h.magnt_h[0].mseqr_h);
        rst_seq_h.start(env_h.sagnt_h[0].sseqr_h);

	assert(mseq_h.randomize with {no_of_txn == 1;})
        fork
		mseq_h.start(env_h.magnt_h[0].mseqr_h);
        	sseq_h.start(env_h.sagnt_h[0].sseqr_h);
	join_any
	sseq_h.kill();
      
        phase.phase_done.set_drain_time(this, 250); 
        phase.drop_objection(this);
    endtask

endclass

`endif
