// AHB Master Functional Coverage
`ifndef AHB_MAS_FC
`define AHB_MAS_FC

class ahb_mas_fc extends uvm_subscriber #(ahb_transaction);
    
    ahb_transaction mitem;
    real mcov_var;
    real mcov_for_addr_q;
    real mcov_for_trans_q;
    real mcov_for_wdata_q;

    `uvm_component_utils(ahb_mas_fc)

    covergroup ahb_mcvg_var;
			 AHB_HWRITE: coverpoint mitem.hwrite {
			 		bins hwrite_cov[] = {0,1};
			 }
			 AHB_HSIZE: coverpoint mitem.hsize {
			 		bins hsize_cov[] = {0,1,2};
			 }
			 AHB_HBURST: coverpoint mitem.hburst_type {
			 		bins hburst_cov[] = {0,1,2,3,4,5,6,7};
			 }
    endgroup

    covergroup ahb_mcvg_for_addr_q with function sample (bit [`ADDRWIDTH-1:0] addr);
	    		 AHB_HADDR: coverpoint addr; //{
			 		//bins haddr_cov[8] = {[0:31]};
			 //}
    endgroup

    covergroup ahb_mcvg_for_trans_q with function sample (bit [1:0] trans);
			 AHB_HTRANS: coverpoint trans {
			 		bins htrans_cov[] = {0,1,2,3};
			 }
    endgroup

    covergroup ahb_mcvg_for_wdata_q with function sample (bit [`DATAWIDTH-1:0] data);
			 AHB_HWDATA: coverpoint data; //{
			 		//bins hwdata_cov[8] = {[0:31]};
			 //}
    endgroup

    function new(string name = "ahb_mas_fc", uvm_component parent);
        super.new(name, parent);
        ahb_mcvg_var = new();
        ahb_mcvg_for_addr_q = new();
        ahb_mcvg_for_trans_q = new();
        ahb_mcvg_for_wdata_q = new();
    endfunction

    function void write(ahb_transaction t);
        mitem = new t;

        ahb_mcvg_var.sample();

	foreach(mitem.haddr_q[i]) begin
		ahb_mcvg_for_addr_q.sample(mitem.haddr_q[i]);
	end

	foreach(mitem.htrans_q[i]) begin
		ahb_mcvg_for_trans_q.sample(mitem.htrans_q[i]);
	end
	
	foreach(mitem.hwdata_q[i]) begin
		ahb_mcvg_for_wdata_q.sample(mitem.hwdata_q[i]);
	end	
    endfunction

    function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        mcov_var = ahb_mcvg_var.get_coverage();
        mcov_for_addr_q = ahb_mcvg_for_addr_q.get_coverage();
        mcov_for_trans_q = ahb_mcvg_for_trans_q.get_coverage();
        mcov_for_wdata_q = ahb_mcvg_for_wdata_q.get_coverage();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("MASTER COVERAGE: ahb_mcvg_var = %0f", mcov_var), UVM_DEBUG);
        `uvm_info(get_type_name(), $sformatf("MASTER COVERAGE: mcov_for_addr_q = %0f", mcov_for_addr_q), UVM_DEBUG);
        `uvm_info(get_type_name(), $sformatf("MASTER COVERAGE: mcov_for_trans_q = %0f", mcov_for_trans_q), UVM_DEBUG);
        `uvm_info(get_type_name(), $sformatf("MASTER COVERAGE: mcov_for_wdata_q = %0f", mcov_for_wdata_q), UVM_DEBUG);
    endfunction

endclass

`endif
