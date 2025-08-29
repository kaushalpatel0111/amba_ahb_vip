// AHB Slave Functional Coverage
`ifndef AHB_SLV_FC
`define AHB_SLV_FC

class ahb_slv_fc extends uvm_subscriber #(ahb_transaction);
    
    ahb_transaction sitem;
    real scov;

    `uvm_component_utils(ahb_slv_fc)

    covergroup ahb_scvg; 
			 AHB_HRESP: coverpoint sitem.hresp {
			 		bins hresp_cov[] = {0,1};
			 }
			 AHB_HRDATA: coverpoint sitem.hrdata {
			 		bins hrdata_cov = {[0:31]};
			 } 
    endgroup

    function new(string name = "ahb_slv_fc", uvm_component parent);
        super.new(name, parent);
        ahb_scvg = new();
    endfunction

    function void write(ahb_transaction t);
        sitem = new t;
        ahb_scvg.sample();
    endfunction

    function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        scov = ahb_scvg.get_coverage();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("SLAVE COVERAGE: %0f", scov), UVM_DEBUG);
    endfunction

endclass

`endif
