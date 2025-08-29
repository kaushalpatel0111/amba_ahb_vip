// AHB Master Interface
`ifndef AHB_MAS_INTF
`define AHB_MAS_INTF

//`timescale 1ns/1ns

interface ahb_mas_intf();
  // Global Signals
  logic                    hclk;
  logic                    hresetn;
  // AHB Global Signals
  logic [`ADDRWIDTH-1:0]   haddr;
  logic [`HBURSTWIDTH-1:0] hburst;
	//logic 									 hmastlock;
  logic [`HSIZEWIDTH-1:0]  hsize;
  logic [`HTRANSWIDTH-1:0] htrans;
  logic [`DATAWIDTH-1:0]   hwdata;
  logic                    hwrite;
  // AHB Slave Signals
  logic [`DATAWIDTH-1:0]   hrdata;
  logic                    hresp;
  logic                    hready;
  // AHB5 Signals
  `ifdef AHB5
  	logic [`HWSTRBWIDTH-1:0] hwstrb;
  `endif
	//logic 									 hexokay;
  // AHB LITE Signals
	//logic 									 hnonsec;
	//logic 									 hexcl;
	//logic 									 hmaster;

  // Clocking block for driver
  clocking mdrv_cb @(posedge hclk);
    default input #`IN_SKEW output #`OUT_SKEW;
		//output hnomnsec;
		//output hexcl;
		//output hmaster;
    output hwstrb;
		//output hexokay;
    output haddr;
    output hburst;
    //output hmastlock;
    output hsize;
    output htrans;
    output hwdata;
    output hwrite;
    input  hready;
    input  hresp;
    //input  hrdata;
  endclocking
  
  // Clocking block for monitor
  clocking mmon_cb @(posedge hclk);
    default input #`IN_SKEW output #`OUT_SKEW;
    input hrdata;
    input hready;
    input hresp;
    input haddr;
    input hburst;
    //input hmastlock;
    input hsize;
    input htrans;
    input hwdata;
    input hwrite;
		//input hnomnsec;
    input hwstrb;
		//input hexokay;
		//input hexcl;
		//input hmaster;
  endclocking
  
  // Modports
  modport MDRV (clocking mdrv_cb, input hclk, hresetn);
  modport MMON (clocking mmon_cb, input hclk, hresetn);
endinterface

`endif
