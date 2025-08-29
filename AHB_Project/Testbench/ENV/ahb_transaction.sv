// AHB Transaction
`ifndef AHB_TRANSACTION
`define AHB_TRANSACTION

class ahb_transaction extends uvm_sequence_item;
	rand hwrite_enum              	hwrite;
  	rand hburst_enum		hburst_type;
  	rand hsize_enum			hsize;
  	rand htrans_enum 		htrans_q[$];
  	rand bit [`ADDRWIDTH-1:0]       haddr_q[$];
	`ifdef AHB5
		rand bit [`HWSTRBWIDTH-1:0] hwstrb_q[$];
	`endif
  	rand bit [`DATAWIDTH-1:0]   	hwdata_q[$];
	rand bit [`ADDRWIDTH-1:0]	start_addr;
	rand shortint unsigned 		burst_len;
   	     hresp_enum               	hresp;
	     bit [`DATAWIDTH-1:0]   	hrdata;
  	     bit [`DATAWIDTH-1:0]   	hrdata_q[$];
	rand shortint unsigned 		num_busy;
	rand shortint unsigned 		index_busy;
	
  	`uvm_object_utils_begin(ahb_transaction)
        	`uvm_field_enum(hwrite_enum,hwrite,UVM_ALL_ON)
        	`uvm_field_queue_int(haddr_q, UVM_ALL_ON)
        	`uvm_field_enum(hsize_enum, hsize, UVM_ALL_ON)
        	`uvm_field_enum(hburst_enum, hburst_type, UVM_ALL_ON) 
        	`uvm_field_int(start_addr, UVM_ALL_ON)
        	`uvm_field_queue_enum(htrans_enum, htrans_q, UVM_ALL_ON)
        	`uvm_field_int(burst_len, UVM_ALL_ON)
		`uvm_field_queue_int(hwstrb_q, UVM_ALL_ON)
		`uvm_field_queue_int(hwdata_q, UVM_ALL_ON)
		`uvm_field_enum(hresp_enum, hresp, UVM_ALL_ON)
  		`uvm_field_int(hrdata, UVM_ALL_ON)
		`uvm_field_queue_int(hrdata_q, UVM_ALL_ON)
        	`uvm_field_int(num_busy, UVM_ALL_ON)
        	`uvm_field_int(index_busy, UVM_ALL_ON)
    	`uvm_object_utils_end 
    
  	function new(string name = "ahb_transaction");
        	super.new(name);
    	endfunction

    	constraint addr_align_c {
		start_addr % (1 << hsize) == 0;
	}
/*	
	constraint addr_1kb_boundary_c {
		start_addr%1024 + ((1 << hsize) * burst_len) <= 1024;
	}
*/	
	`ifdef AHB5
	    constraint strb_calc {solve burst_len, hsize before hwstrb_q.size();
		hwstrb_q.size() == burst_len;
		foreach(hwstrb_q[i]){
			if(hsize == BYTE) hwstrb_q[i] inside {1, 2, 4, 8};
			else if(hsize == HALFWORD) hwstrb_q[i] inside {3, 12};
			else if(hsize == WORD) hwstrb_q[i] inside {15};
			/*else if(hsize == DOUBLEWORD) {hwstrb_q[i] inside {};
			else if(hsize == WORDLINE_4) hwstrb_q[i] inside {};
			else if(hsize == WORDLINE_8) hwstrb_q[i] inside {};
			else if(hsize == WORDLINE_16) hwstrb_q[i] inside {};
			else if(hsize == WORDLINE_32) hwstrb_q[i] inside {};*/
			else hwstrb_q[i] == 0;
		}
	    }
	`endif

	constraint burst_len_c {solve hburst_type before burst_len;
		if (hburst_type == SINGLE) {
			burst_len == 1;
		}
		else if (hburst_type == WRAP4 | hburst_type == INCR4) {
			burst_len == 4;
		}
		else if (hburst_type == WRAP8 | hburst_type == INCR8) {
			burst_len == 8;
		}
		else if (hburst_type == WRAP16 | hburst_type == INCR16) {
			burst_len == 16;
		}
	}

    	constraint burstlen_c {solve burst_len before hwdata_q.size(), htrans_q.size();
		hwdata_q.size() == burst_len;
		htrans_q.size() == burst_len;
	}

    	constraint htrans_c {
		foreach(htrans_q[j]){
			if(j==0)
				htrans_q[j] == NONSEQ;
			else
				htrans_q[j] == SEQ;
		}
	}
endclass

`endif
