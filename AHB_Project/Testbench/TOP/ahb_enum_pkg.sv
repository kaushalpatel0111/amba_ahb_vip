`ifndef AHB_ENUM_PKG
`define AHB_ENUM_PKG

typedef enum bit {READ, WRITE} hwrite_enum;
typedef enum logic [(`HBURSTWIDTH-1):0] {SINGLE,INCR,WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16} hburst_enum;
typedef enum logic [2:0] {BYTE,HALFWORD,WORD,DOUBLEWORD,WORDLINE_4,WORDLINE_8,WORDLINE_16,WORDLINE_32} hsize_enum;
typedef enum bit {OKAY,ERROR} hresp_enum;
typedef enum bit [1:0] {IDLE,BUSY,NONSEQ,SEQ} htrans_enum;

`endif
