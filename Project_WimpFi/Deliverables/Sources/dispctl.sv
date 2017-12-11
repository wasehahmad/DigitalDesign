//-----------------------------------------------------------------------------
// Title         : 7-Segment Display Controller
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : dispctl.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 08.08.2011
// Last modified : 07.22.2015
//-----------------------------------------------------------------------------
// Description :
// Control circuit that handles time-multiplexing of eight different 4-bit binary
// inputs to the time-multiplexed seven-segment display on the Nexys4DDR board.
// Output seg[6:0] connects to the seven-segment output to the display, while
// output an[7:0] enables whichever digits are held low.  This circuit must be
// clocked at a relatively low frequency for the time-multiplexing to work
// properly.
// Credit to John Nestor
//-----------------------------------------------------------------------------
// Modification history :
// 08.08.2011 : created (original Verilog version)
// 07.22.2015 : ported to SystemVerilog and expanded to 8 digits for nexys4ddr
//-----------------------------------------------------------------------------

module dispctl (
		input logic 	   clk,
		input logic 	   reset,
		input logic [3:0]  d7, d6, d5, d4, d3, d2, d1, d0,
		input logic 	   dp7, dp6, dp5, dp4, dp3, dp2, dp1, dp0,
		output logic [6:0] seg,
		output logic dp,
		output logic [7:0] an
		);

   // generate clock enable to drive time-multiplexing counter
   // (you may need to adjust the frequency!)

   logic enb;
   logic [2:0] count_out;
   logic [3:0] display_digit;

   clkenb #(.DIVFREQ(1000)) U_CLKENB(.clk(clk), .reset(reset), .enb(enb));
   
   counter #(.W(3)) THR_B_COUNTER(.clk(clk), .en(enb), .rst(reset), .Q(count_out));
   
   
   
   mux8_parm U_DIG_MUX(.d0(d0),.d1(d1),.d2(d2),.d3(d3),.d4(d4),.d5(d5),.d6(d6),.d7(d7),.sel(count_out),.y(display_digit)); 

   mux8_parm #(.W(1)) U_DP_MUX(.d0(dp0),.d1(dp1),.d2(dp2),.d3(dp3),.d4(dp4),.d5(dp5),.d6(dp6),.d7(dp7),.sel(count_out),.y(dp)); 

   seven_seg U_SEV_SEG(.data(display_digit),.segments(seg));
   
   decoder_3_8_en U_ANODE_DISPLAY(.a(count_out),.enb(1),.y(an));

endmodule // dispctl

   