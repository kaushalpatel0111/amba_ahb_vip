// AHB TOP Variable Define
`ifndef APB_TOPVAR_DEFINE
`define APB_TOPVAR_DEFINE

`define ADDRWIDTH 32
`define DATAWIDTH 32
`define HSIZEWIDTH 3
`define HBURSTWIDTH 3
`define HTRANSWIDTH 2


`define HWSTRBWIDTH `DATAWIDTH /8

`define IN_SKEW 1     // Clocking block skew to avoid setup violation
`define OUT_SKEW 1    // Clocking block skew to avoid hold violation

`endif
