// AHB Master Seq_item
`ifndef AHB_MAS_SEQ_ITEM
`define AHB_MAS_SEQ_ITEM

class ahb_mas_seq_item extends ahb_transaction;
    
    	`uvm_object_utils(ahb_mas_seq_item)
		
    	function new(string name = "ahb_mas_seq_item");
        	super.new(name);
    	endfunction

    	function void post_randomize();
		addr_burst_calc();
    	endfunction

	function void addr_burst_calc();
		bit [`ADDRWIDTH-1:0] lower_boundary, upper_boundary; 
		bit [`ADDRWIDTH-1:0] haddr; 
		shortint unsigned total_bytes;

		total_bytes = (1 << hsize) * burst_len;
		lower_boundary = int'(start_addr/total_bytes) * total_bytes;
		upper_boundary = lower_boundary + total_bytes;
			
		haddr = start_addr;
		haddr_q.push_back(haddr);

		repeat(burst_len-1) begin
			haddr += (1 << hsize);
			if ((hburst_type == WRAP4 | hburst_type == WRAP8 | hburst_type == WRAP16) && haddr == upper_boundary) haddr = lower_boundary;
			haddr_q.push_back(haddr);
		end
	endfunction

endclass                                             

`endif
