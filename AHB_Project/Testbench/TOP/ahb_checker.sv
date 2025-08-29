// AHB Checkers
`ifndef AHB_CHECKER
`define AHB_CHECKER

`include "ahb_topvar_define.sv"

  typedef enum bit [(`HBURSTWIDTH-1):0] {SINGLE,INCR,WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16} hburst_enum;
  typedef enum bit {OKAY,ERROR} hresp_enum;
  typedef enum bit [`HTRANSWIDTH-1:0] {IDLE,BUSY,NONSEQ,SEQ} htrans_enum;
/*
  `define check_is_unknown(ARG1,ARG2,ARG3)\
                                   property ARG1;\
                                   @(posedge hclk) disable iff (!hrstn)\
                                  1 |-> !$isunknown(ARG2); \
                                  endproperty \
                                  ARG3: assert property(ARG1) \
                                   else `uvm_error(`"ARG1`","FAILED") \
                                  cover property (ARG1);
*/
module ahb_checker(
	input hclk,
	input hresetn,
	input [`ADDRWIDTH-1:0] haddr,
	input [`HBURSTWIDTH-1:0] hburst,
	input [`HSIZEWIDTH-1:0] hsize,
	input [`HTRANSWIDTH-1:0] htrans,
	input [`DATAWIDTH-1:0] hwdata,
	input hwrite,
	input [`DATAWIDTH-1:0] hrdata,
	input hresp,
	input hready,
`ifdef AHB5
	input [`HWSTRBWIDTH-1:0] hwstrb
`endif
);

   import uvm_pkg::*;
/*
  //------------------------------------------------------------------------ //
  //            CHECK NON TRISTATE VALUE FOR EVERY SIGNAL                    //
  //------------------------------------------------------------------------ //
  `check_is_unknown(HADDR_NOT_UNKN,haddr,HADDR_N_UNKN)
  `check_is_unknown(HBURST_NOT_UNKN,hburst,HBURST_N_UNKN)
  `check_is_unknown(HSIZE_NOT_UNKN,hsize,HSIZE_N_UNKN)
  `check_is_unknown(HTRANS_NOT_UNKN,htrans,HTRANS_N_UNKN)
  `check_is_unknown(HWDATA_NOT_UNKN,hwdata,HWDATA_N_UNKN)
  `check_is_unknown(HWRITE_NOT_UNKN,hwrite,HWRITE_N_UNKN)
  `check_is_unknown(HRDATA_NOT_UNKN,hrdata,HRDATA_N_UNKN)
  `check_is_unknown(HRESP_NOT_UNKN,hresp,HRESP_N_UNKN)
  `check_is_unknown(HREADY_NOT_UNKN,hready,HREADY_N_UNKN)
*/
  //------------------------------------------------------------------------ //
  //           PROPERTY TO CHECK DEFAULT VALUES AFTER RESET                  // 
  //------------------------------------------------------------------------ //
  property ahb_check_reset_default_value;
     @(posedge hclk)
     !hresetn |-> (haddr=='0 && hburst=='0 && hsize=='0 && htrans=='0 && hwdata=='0 && hrdata=='0 && hresp=='0 && hready==1 && hwrite=='0);
  endproperty

  AHB_RESET: assert property (ahb_check_reset_default_value)
  else begin
	  `uvm_info("RESET_ASSERTION", $sformatf("haddr = %0h, hburst = %0h, hsize = %0h, htrans = %0h, hwdata = %0h, hrdata = %0h, hresp = %0h, hready = %0h, hwrite = %0h", haddr, hburst, hsize, htrans, hwdata, hrdata, hresp, hready, hwrite), UVM_DEBUG)
	  `uvm_error("RESET_ASSERTION","RESET ASSERT FAILED!")
  end
  AHB_RESET_CVR : cover property (ahb_check_reset_default_value);

  //------------------------------------------------------------------------ //
  //         PROPERTY TO CHECK HWRITE STABLE THROUGHOUT BURST                //
  //------------------------------------------------------------------------ //
  property ahb_check_hwrite_constant_throughout_burst (int incr_num, wrap_num, seq_num);
   @(posedge hclk) disable iff(!hresetn)
     (htrans == htrans_enum'(NONSEQ) && (hburst == incr_num || hburst == wrap_num)) |=> $stable(hwrite) throughout ((htrans == htrans_enum'(SEQ) && hready)[->seq_num]);
  endproperty
  
  STABLE_HWRITE_WRAP_INCR_4: assert property(ahb_check_hwrite_constant_throughout_burst(2,3,3))
  else `uvm_error("HWRITE_STABLE_WRAP_INCR_4_ASSERTION","WRAP_INCR_4 HWRITE STABLE ASSERT FAILED!")
  HWRITE_STABLE_WRAP_INCR_4_CVR: cover property (ahb_check_hwrite_constant_throughout_burst(2,3,3));

  STABLE_HWRITE_WRAP_INCR_8: assert property(ahb_check_hwrite_constant_throughout_burst(4,5,7))
  else `uvm_error("HWRITE_STABLE_WRAP_INCR_8_ASSERTION","WRAP_INCR_8 HWRITE STABLE ASSERT FAILED!")
  HWRITE_STABLE_WRAP_INCR_8_CVR: cover property (ahb_check_hwrite_constant_throughout_burst(4,5,7));

  STABLE_HWRITE_WRAP_INCR_16: assert property(ahb_check_hwrite_constant_throughout_burst(6,7,15))
  else `uvm_error("HWRITE_STABLE_WRAP_INCR_16_ASSERTION","WRAP_INCR_16 HWRITE STABLE ASSERT FAILED!")
  HWRITE_STABLE_WRAP_INCR_16_CVR: cover property (ahb_check_hwrite_constant_throughout_burst(6,7,15));

  //------------------------------------------------------------------------ //
  //     PROPERTY TO CHECK OKAY RESPONSE WHEN HTRANS IS BUSY                 // 
  //------------------------------------------------------------------------ // 
  property ahb_check_nowait_okay_resp_during_busy;
   @(posedge hclk) disable iff(!hresetn)
     ((htrans == htrans_enum'(BUSY)) && $past(hresp==hresp_enum'(OKAY),1) && hresp == hresp_enum'(OKAY)) |-> hready[->1] ##0 (hresp == hresp_enum'(OKAY));
  endproperty

  BUSY_RESPONSE: assert property(ahb_check_nowait_okay_resp_during_busy)
  else `uvm_error("BUSY_NO_WAIT_OKAY_RESPONSE_ASSERTION","BUSY NO WAIT OKAY RESPONSE ASSERT FAILED!")
  OKAY_RESP_BUSY_CVR: cover property (ahb_check_nowait_okay_resp_during_busy);

  //------------------------------------------------------------------------ //
  //     PROPERTY TO CHECK OKAY RESPONSE WHEN HTRANS IS IDLE                 // 
  //------------------------------------------------------------------------ // 
  property ahb_check_nowait_okay_resp_idle;
   @(posedge hclk) disable iff(!hresetn)
     ((htrans==htrans_enum'(IDLE)) && $past(hresp==hresp_enum'(OKAY),1) && hresp == hresp_enum'(OKAY)) |-> hready[->1] ##0 (hresp == hresp_enum'(OKAY));
  endproperty

  IDLE_RESPONSE: assert property(ahb_check_nowait_okay_resp_idle)
  else `uvm_error("IDLE_NO_WAIT_OKAY_RESPONSE_ASSERTION","IDLE NO WAIT OKAY RESPONSE ASSERT FAILED!")
  OKAY_RESP_IDLE_CVR: cover property (ahb_check_nowait_okay_resp_idle);
  //------------------------------------------------------------------------ //
  //     PROPERTY TO CHECK FIRST TRANS TYPE OF EVERY BURST IS NONSEQ         // 
  //------------------------------------------------------------------------ // 
  property ahb_check_first_trans_type_nonseq;
   @(posedge hclk) disable iff(!hresetn)
    ($changed(hburst) && (htrans != hburst_enum'(SINGLE)))|-> htrans == htrans_enum'(NONSEQ);
  endproperty

  FIRST_TRANS_NONSEQ: assert property(ahb_check_first_trans_type_nonseq) 
  else `uvm_error("FIRST_TRANS_NONSEQ_ASSERTION","FIRST TRANSFER NONSEQ ASSERT FAILED!")
  NONSEQ_FIRST_TRANSFER_CVR: cover property (ahb_check_first_trans_type_nonseq);

  //------------------------------------------------------------------------ //
  //     PROPERTY TO CHECK NOT MORE THAN ONE NONSEQ OCCUR DURING BURST       //
  //------------------------------------------------------------------------ //
  property ahb_check_not_more_than_one_nonseq (int incr_num, wrap_num, seq_num);
   @(posedge hclk) disable iff(!hresetn)
     (hready && htrans == htrans_enum'(NONSEQ) && (hburst == incr_num || hburst == wrap_num)) |=> (htrans != htrans_enum'(NONSEQ)) throughout ((htrans == htrans_enum'(SEQ) && hready)[->seq_num]);
  endproperty
  
  NOT_MORE_THAN_ONE_NOONSEQ_INCR_WRAP_4 : assert property(ahb_check_not_more_than_one_nonseq(2,3,3)) 
  else `uvm_error("NOT_MORE_THAN_ONE_NONSEQ_INCR_WRAP_4_ASSERTION","WRAP_INCR_4 NOT MORE THAN ONE NONSEQ ASSERT FAILED!")
  ONE_NONSEQ_WRAP_INCR_4_CVR: cover property (ahb_check_not_more_than_one_nonseq(2,3,3));

  NOT_MORE_THAN_ONE_NOONSEQ_INCR_WRAP_8 : assert property(ahb_check_not_more_than_one_nonseq(4,5,7)) 
  else `uvm_error("NOT_MORE_THAN_ONE_NONSEQ_INCR_WRAP_8_ASSERTION","WRAP_INCR_8 NOT MORE THAN ONE NONSEQ ASSERT FAILED!")
  ONE_NONSEQ_WRAP_INCR_8_CVR: cover property (ahb_check_not_more_than_one_nonseq(4,5,7));

  NOT_MORE_THAN_ONE_NOONSEQ_INCR_WRAP_16 : assert property(ahb_check_not_more_than_one_nonseq(6,7,15)) 
  else `uvm_error("NOT_MORE_THAN_ONE_NONSEQ_INCR_WRAP_16_ASSERTION","WRAP_INCR_16 NOT MORE THAN ONE NON SEQ ASSERT FAILED!")
  ONE_NONSEQ_WRAP_INCR_16_CVR: cover property (ahb_check_not_more_than_one_nonseq(6,7,15));
/*
  //------------------------------------------------------------------------------------ //
  //  PROPERTY TO CHECK HADDR STABLE WHEN BUSY ARRAIVES IN THE BURST FOR INCR 4,8,16     // 
  //------------------------------------------------------------------------------------ //
  property  ahb_check_addr_increment_as_per_hsize_busy_incr;
   @(posedge hclk) disable iff(!hresetn)
     (htrans == htrans_enum'(SEQ) && $past(htrans == htrans_enum'(BUSY)) && (hburst == hburst_enum'(INCR4) || hburst == hburst_enum'(INCR8) || hburst == hburst_enum'(INCR16)) && hready) |-> (haddr == $past(haddr)); 
  endproperty

  HADDR_VAL_AFTER_BUSY_INCR : assert property(ahb_check_addr_increment_as_per_hsize_busy_incr)
  else `uvm_error("ASSERTION INTERFACE","INCR_4_8_16 ADDR STABLE WHEN BUSY ASSERT FAILED!")
  ADDR_STABLE_BUSY_CVR: cover property ( ahb_check_addr_increment_as_per_hsize_busy_incr);
*/
  //------------------------------------------------------------------------ //
  //       PROPERTY TO CHECK IDLE SHOULD NOT OCCUR IN ANY FIXED BURST        // 
  //------------------------------------------------------------------------ // 
  property ahb_check_fixed_burst_without_IDLE (int incr_num, wrap_num, seq_num);
   @(posedge hclk) disable iff(!hresetn)
     (hready && htrans == htrans_enum'(NONSEQ) && (hburst == incr_num || hburst == wrap_num)) |=> (htrans != htrans_enum'(IDLE)) throughout ((htrans == htrans_enum'(SEQ) && hready)[->seq_num]);
  endproperty

  FIXED_BURST_WITHOUT_IDLE_INCR_WRAP_4 : assert property(ahb_check_fixed_burst_without_IDLE(2,3,3)) 
  else `uvm_error("FIXED_BURST_WITHOUT_IDLE_INCR_WRAP_4_ASSERTION","WRAP_INCR_4 FIXED BURST WITHOUT IDLE ASSERT FAILED!")
  BURST_WITHOUT_IDLE_WRAP_INCR_4_CVR: cover property (ahb_check_fixed_burst_without_IDLE(2,3,3));

  FIXED_BURST_WITHOUT_IDLE_INCR_WRAP_8 : assert property(ahb_check_fixed_burst_without_IDLE(4,5,7)) 
  else `uvm_error("FIXED_BURST_WITHOUT_IDLE_INCR_WRAP_8_ASSERTION","WRAP_INCR_8 FIXED BURST WITHOUT IDLE ASSERT FAILED!")
  BURST_WITHOUT_IDLE_WRAP_INCR_8_CVR: cover property (ahb_check_fixed_burst_without_IDLE(4,5,7));

  FIXED_BURST_WITHOUT_IDLE_INCR_WRAP_16 : assert property(ahb_check_fixed_burst_without_IDLE(6,7,15)) 
  else `uvm_error("FIXED_BURST_WITHOUT_IDLE_INCR_WRAP_16_ASSERTION","WRAP_INCR_16 FIXED BURST WITHOUT IDLE ASSERT FAILED!")
  BURST_WITHOUT_IDLE_WRAP_INCR_16_CVR: cover property (ahb_check_fixed_burst_without_IDLE(6,7,15));

  //------------------------------------------------------------------------ //
  //         PROPERTY TO CHECK HSIZE STABLE THROUGHOUT BURST                 // 
  //------------------------------------------------------------------------ //
  property ahb_check_hsize_constant_throughout_burst (int incr_num, wrap_num, seq_num);
   @(posedge hclk) disable iff(!hresetn)
     (htrans == htrans_enum'(NONSEQ) && (hburst == incr_num || hburst == wrap_num)) |=> $stable(hsize) throughout ((htrans == htrans_enum'(SEQ) && hready)[->seq_num]);
  endproperty

  STABLE_HSIZE_BURST_WRAP_INCR_4: assert property(ahb_check_hsize_constant_throughout_burst(2,3,3))
  else `uvm_error("HSIZE_STABLE_WRAP_INCR_4_ASSERTION","WRAP_INCR_4 HSIZE STABLE ASSERT FAILED!")
  HSIZE_STABLE_WRAP_INCR_4_CVR: cover property (ahb_check_hsize_constant_throughout_burst(2,3,3));

  STABLE_HSIZE_BURST_WRAP_INCR_8: assert property(ahb_check_hsize_constant_throughout_burst(4,5,7))
  else `uvm_error("HSIZE_STABLE_WRAP_INCR_8_ASSERTION","WRAP_INCR_8 HSIZE STABLE ASSERT FAILED!")
  HSIZE_STABLE_WRAP_INCR_8_CVR: cover property (ahb_check_hsize_constant_throughout_burst(4,5,7));

  STABLE_HSIZE_BURST_WRAP_INCR_16: assert property(ahb_check_hsize_constant_throughout_burst(6,7,15))
  else `uvm_error("HSIZE_STABLE_WRAP_INCR_16_ASSERTION","WRAP_INCR_16 HSIZE STABLE ASSERT FAILED!")
  HSIZE_STABLE_WRAP_INCR_16_CVR: cover property (ahb_check_hsize_constant_throughout_burst(6,7,15));

  //------------------------------------------------------------------------ //
  //         PROPERTY TO CHECK HBURST STABLE THROUGHOUT BURST                // 
  //------------------------------------------------------------------------ //
  property ahb_check_hburst_constant_throughout_burst (int incr_num, wrap_num, seq_num);
   @(posedge hclk) disable iff(!hresetn)
     (htrans == htrans_enum'(NONSEQ) && (hburst == incr_num || hburst == wrap_num)) |=> $stable(hburst) throughout ((htrans == htrans_enum'(SEQ) && hready)[->seq_num]);
  endproperty

  STABLE_HBURST_WRAP_INCR_4: assert property(ahb_check_hburst_constant_throughout_burst(2,3,3))
  else `uvm_error("HBURST_STABLE_WRAP_INCR_4_ASSERTION","WRAP_INCR_4 HBURST STABLE ASSERT FAILED!")
  HBURST_STABLE_WRAP_INCR_4_CVR: cover property (ahb_check_hburst_constant_throughout_burst(2,3,3));

  STABLE_HBURST_WRAP_INCR_8: assert property(ahb_check_hburst_constant_throughout_burst(4,5,7))
  else `uvm_error("HBURST_STABLE_WRAP_INCR_8_ASSERTION","WRAP_INCR_8 HBURST STABLE ASSERT FAILED!")
  HBURST_STABLE_WRAP_INCR_8_CVR: cover property (ahb_check_hburst_constant_throughout_burst(4,5,7));

  STABLE_HBURST_WRAP_INCR_16: assert property(ahb_check_hburst_constant_throughout_burst(6,7,15))
  else `uvm_error("HBURST_STABLE_WRAP_INCR_16_ASSERTION","WRAP_INCR_16 HBURST STABLE ASSERT FAILED!")
  HBURST_STABLE_WRAP_INCR_16_CVR: cover property (ahb_check_hburst_constant_throughout_burst(6,7,15));
/*
  //------------------------------------------------------------------------ //
  //        PROPERTY TO CHECK DATA MUST BE STABE WHEN HREADY IS LOW          //
  //------------------------------------------------------------------------ //
  property ahb_check_stable_data_check;
   @(posedge hclk) disable iff(!hresetn)
   (!hready) |=> $stable(hwdata) throughout ((hready)[->1]) ;
  endproperty

  STABLE_DATA_WHEN_HREADY_LOW: assert property(ahb_check_stable_data_check)
  else `uvm_error("STABLE_DATA_ASSERTION","STABLE DATA ASSERT FAILED!")
  STABLE_DATA_CVR: cover property (ahb_check_stable_data_check);
*/
endmodule

`endif
