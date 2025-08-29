// AHB TOP
`ifndef AHB_TOP
`define AHB_TOP

`include "ahb_top_define.svh"
`include "ahb_topvar_define.sv"
`include "ahb_enum_pkg.sv"
//`include "ahb_common_intf.sv"
`include "ahb_mas_intf.sv"
`include "ahb_slv_intf.sv"
`include "ahb_checker.sv"

module ahb_top();
    import uvm_pkg::*;
    import ahb_pkg::*;
    `include "uvm_macros.svh"
  
    // Binding assertion/checker module
    bind ahb_top ahb_checker chkr_h(.hclk(hclk), .hresetn(hresetn), .haddr(mas_intf.haddr), .hburst(mas_intf.hburst), .hsize(mas_intf.hsize), .htrans(mas_intf.htrans), .hwdata(mas_intf.hwdata), .hwrite(mas_intf.hwrite), `ifdef AHB5 .hwstrb(mas_intf.hwstrb) `endif , .hrdata(slv_intf.hrdata), .hresp(slv_intf.hresp), .hready(slv_intf.hready));	
    
    // Declaring global signals
    bit hclk, hresetn;

    // Variable to hold the frequency from $plusargs
    real freq = 100.0; // Default frequency in MHz

    // Compute clock period based on frequency
    real clk_period;
    real duty_cycle;
    real tclk_high; 
    real tclk_low;

    // Clock generation
    initial begin
        // Read clock frequency from $plusargs
        if ($value$plusargs("clk_freq=%f", freq)) begin
            $display("Clock frequency set to %f MHz", freq);
        end 
				else begin
            $display("Using default clock frequency %f MHz", freq);
        end

        // Calculate clock period and duty cycle
        clk_period = 1.0 / freq * 1000; // Clock period in ns
        duty_cycle = 0.5; //+ $urandom_range(0.00 * duty_cycle, 0.05 * duty_cycle); // 50% Duty cycle with 5% jitter
        tclk_high = clk_period * duty_cycle;
        tclk_low = clk_period - tclk_high;

        // Generate clock
        forever begin
            #tclk_low;
            hclk = 1;
            #tclk_high;
            hclk = 0;
        end
    end

    // Inital reset task
    task init_rst(int cycle = 3);
      hresetn = 0;
      repeat(cycle)
	      @(posedge hclk);
      hresetn = 1;      
    endtask

    // Reset generation
    initial begin
        // Initiate initial reset from $plusargs
        if ($test$plusargs("init_rst")) begin
            $display("Inside initial reset test");
            init_rst(2);
        end
    end

/*
    // AHB Common Interface Instantiation
    ahb_common_intf intf();

    assign intf.hclk = hclk;
    assign intf.hresetn = hresetn;
*/
    // AHB Master Interface Instantiation
    ahb_mas_intf mas_intf();
  
    assign mas_intf.hclk = hclk;
    assign mas_intf.hresetn = hresetn;
  
    // AHB Slave Interface Instantiation
    ahb_slv_intf slv_intf();
  
    assign slv_intf.hclk = hclk;
    assign slv_intf.hresetn = hresetn;
  
    // Assigning Master - Slave Signals
    assign slv_intf.haddr = mas_intf.haddr;
    assign slv_intf.hwrite = mas_intf.hwrite;
    assign slv_intf.hburst = mas_intf.hburst;
    assign slv_intf.hsize = mas_intf.hsize;
    assign slv_intf.htrans = mas_intf.htrans;
    assign slv_intf.hwdata = mas_intf.hwdata;
    assign slv_intf.hwstrb = mas_intf.hwstrb;
    assign mas_intf.hready = slv_intf.hready;
    assign mas_intf.hresp = slv_intf.hresp;
    assign mas_intf.hrdata = slv_intf.hrdata;

    // Test control
    initial begin
      fork
        uvm_config_db #(virtual ahb_mas_intf)::set(null,"*", "ahb_mas_intf", mas_intf);
        uvm_config_db #(virtual ahb_slv_intf)::set(null,"*", "ahb_slv_intf", slv_intf);
        run_test("");      
      join
    end

    initial begin
	`ifdef WAVES_FSDB
       	$fsdbDumpfile("fsdb_filename");
       	$fsdbDumpvars;
    	`endif
    end

endmodule

`endif
