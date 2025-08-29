// AHB Slave Interface
`ifndef AHB_SLV_INTF
`define AHB_SLV_INTF

//`timescale 1ns/1ns

interface ahb_slv_intf();
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
	//logic 									 hnonsec;
  `ifdef AHB5
  	logic [`HWSTRBWIDTH-1:0] hwstrb;
  `endif
  // AHB LITE Signals
	//logic 									 hexcl;
	//logic 									 hmaster;
	//logic 									 hexokay;

  // Clocking block for driver
  clocking sdrv_cb @(posedge hclk);
    default input #`IN_SKEW output #`OUT_SKEW;
    output  hrdata;
    output  hresp;
    output  hready;
    //output  hexokay;
  endclocking
  
  // Clocking block for monitor
  clocking smon_cb @(posedge hclk);
    default input #`IN_SKEW output #`OUT_SKEW;
    input haddr;
    input hburst;
    //input hmastlock;
    input hsize;
    input htrans;
    input hwdata;
    input hwrite;
    input hrdata;
    input hresp;
    input hready;
    input hwstrb;
    //input  hmaster;
    //input  hexokay;
    //input  hnonsec;
    //input  hexcl;
  endclocking
  
  // Modports
  modport SDRV (clocking sdrv_cb, input hclk, hresetn);
  modport SMON (clocking smon_cb, input hclk, hresetn);
endinterface

`endif
