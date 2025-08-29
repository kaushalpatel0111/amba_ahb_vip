// AHB rst sequence
`ifndef AHB_RST_SEQ
`define AHB_RST_SEQ

class ahb_rst_seq extends ahb_base_seq;

    `uvm_object_utils(ahb_rst_seq)

    virtual ahb_mas_intf mvif;    
    virtual ahb_slv_intf svif;    

    function new(string name = "ahb_rst_seq");
        super.new(name);
    endfunction
    
    task body();
	fork
      		mas_rst();
	  	//slv_rst();
	join
    endtask

    task mas_rst();
	if (!uvm_config_db #(virtual ahb_mas_intf)::get(null,"*", "ahb_mas_intf", mvif))
		`uvm_fatal("MAS_SEQR_FATAL", "Master Virtual interface config_db is not set properly");

	mvif.hresetn = 1'b0;
      	repeat(3) @(posedge mvif.hclk);
      	mvif.hresetn = 1'b1;
    endtask

    task slv_rst();
	if (!uvm_config_db #(virtual ahb_slv_intf)::get(null,"*", "ahb_slv_intf", svif))
		`uvm_fatal("SLV_SEQR_FATAL", "Virtual interface config_db is not set properly in ahb_slv_seqr");
	
	svif.hresetn = 1'b0;
      	repeat(3) @(posedge svif.hclk);
      	svif.hresetn = 1'b1;
    endtask

endclass

`endif
