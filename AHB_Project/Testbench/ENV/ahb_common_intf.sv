// AHB Common Interface
`ifndef AHB_MAIN_INTF
`define AHB_MAIN_INTF

`include "ahb_mas_intf.sv"
`include "ahb_slv_intf.sv"

//`timescale 1ns/1ns

interface ahb_common_intf();

  logic hclk;
  logic hreset;

  ahb_mas_intf mintf();
  ahb_slv_intf sintf();
  
endinterface

`endif
