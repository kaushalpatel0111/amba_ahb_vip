// AHB Environment
`ifndef AHB_ENV
`define AHB_ENV

class ahb_env extends uvm_env;
    
    `uvm_component_utils(ahb_env)
	
  	ahb_cust_cfg cust_cfg_h;
  	ahb_mas_agnt magnt_h[];
  	ahb_slv_agnt sagnt_h[];
		ahb_scb scb_h;
		ahb_mas_fc mfc_h;
		ahb_slv_fc sfc_h;

    function new(string name = "ahb_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      	
				if (!uvm_config_db #(ahb_cust_cfg)::get(this," ", "ahb_cust_cfg", cust_cfg_h))
          `uvm_fatal("ENV_FATAL", "Custom Configuration object is not set properly");

      	uvm_config_db #(ahb_cust_cfg)::set(this,"magnt_h", "ahb_cust_cfg", cust_cfg_h);
        
      	magnt_h = new[cust_cfg_h.num_master];

      	foreach(magnt_h[i]) begin
          magnt_h[i] = ahb_mas_agnt::type_id::create($sformatf("magnt_h[%0d]", i), this);
        end
      
      	uvm_config_db #(ahb_cust_cfg)::set(this,"sagnt_h", "ahb_cust_cfg", cust_cfg_h);
      	
				sagnt_h = new[cust_cfg_h.num_slave];

      	foreach(sagnt_h[i]) begin
          sagnt_h[i] = ahb_slv_agnt::type_id::create($sformatf("sagnt_h[%0d]", i), this);
        end
		
      	if(cust_cfg_h.enable_scb) begin
					scb_h = ahb_scb::type_id::create("scb_h", this);
					scb_h.cust_cfg_h = cust_cfg_h;
				end

				if(cust_cfg_h.enable_mfc) begin
					mfc_h = ahb_mas_fc::type_id::create("mfc_h", this);
				end

				if(cust_cfg_h.enable_sfc) begin
					sfc_h = ahb_slv_fc::type_id::create("sfc_h", this);
				end
	
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

				foreach(magnt_h[i]) begin
					if(cust_cfg_h.enable_scb) begin
						magnt_h[i].mmon_h.item_req_port.connect(scb_h.mitem_export);
					end
				end

				foreach(sagnt_h[i]) begin
					if(cust_cfg_h.enable_scb) begin
						sagnt_h[i].smon_h.item_req_port.connect(scb_h.sitem_export);
					end
				end


				foreach(magnt_h[i]) begin
					if(cust_cfg_h.enable_mfc) begin
						magnt_h[i].mmon_h.item_req_port.connect(mfc_h.analysis_export);
					end
				end

				
				foreach(sagnt_h[i]) begin
					if(cust_cfg_h.enable_sfc) begin
						sagnt_h[i].smon_h.item_req_port.connect(sfc_h.analysis_export);
					end
				end
    endfunction
  
    function void end_of_elaboration_phase(uvm_phase phase);
        //uvm_top.print_topology();
    endfunction

endclass

`endif
