// AHB Slave Memory
`ifndef AHB_SLV_MEM
`define AHB_SLV_MEM

class ahb_slv_mem extends uvm_component;

	`uvm_component_utils(ahb_slv_mem)

	bit [(`DATAWIDTH-1):0] mem [int];

	function new(string name = "ahb_slv_mem", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	`ifdef AHB5
		function void wstrb_mem (bit [(`ADDRWIDTH-1):0] addr,bit [(`DATAWIDTH-1):0] data, bit [(`HWSTRBWIDTH-1):0] strb_data);
			for (int j = 0; j < `HWSTRBWIDTH; j++) begin
				if (strb_data[j]) begin
					// Write the corresponding byte to the memory
					mem[addr][8 * j +: 8] = data[8 * j +: 8];
				end
				else begin
					// Preserve the existing byte if strobe is 0
					mem[addr][8 * j +: 8] = mem[addr][8 * j +: 8];
				end
			end
			`uvm_info(get_full_name(),$sformatf("[WSTRB_MEM]: %p",mem), UVM_DEBUG)
		endfunction
	`else
		function void write_mem (bit [(`ADDRWIDTH-1):0] addr,bit [(`DATAWIDTH-1):0] data);
			mem[addr] = data;
			`uvm_info(get_full_name(),$sformatf("memory addr : %h | write_memory data : %h",addr,mem[addr]), UVM_DEBUG)
			`uvm_info(get_full_name(),$sformatf("[WRITE_MEM]: %p",mem), UVM_DEBUG)
		endfunction
	`endif
	
	function logic [(`DATAWIDTH-1):0] read_mem (bit [(`ADDRWIDTH-1):0] addr);
		bit [(`DATAWIDTH-1):0] read_data;
		if(mem.exists(addr)) begin
			read_data = mem[addr];
			`uvm_info(get_full_name(),$sformatf("memory addr : %h | read_memory data : %h",addr,mem[addr]), UVM_DEBUG)
			`uvm_info(get_full_name(),$sformatf("[READ_MEM]: %p",mem), UVM_DEBUG)
		end
		return(read_data);
	endfunction

endclass

`endif
