//-----------------------------------------------------------------------------
// Title         : Nexys4 Simple Top-Level File
// Project       : ECE 491
//-----------------------------------------------------------------------------
// File          : nexys4DDR.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 22.07.2016
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description :
// This file provides a starting point for Lab 1 and includes some basic I/O
// ports.  To use, un-comment the port declarations and the corresponding
// configuration statements in the constraints file "Nexys4DDR.xdc".
// This module only declares some basic i/o ports; additional ports
// can be added - see the board documentation and constraints file
// more information
// Credit to John Nestor
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
//-----------------------------------------------------------------------------

module nexys4DDR (
		  // un-comment the ports that you will use
          input logic         CLK100MHZ,
		  input logic [15:0]  SW,
		  input logic 	      BTNC,
//		  input logic 	      BTNU, 
//		  input logic 	      BTNL, 
//		  input logic 	      BTNR,
//		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP
//		  output logic [15:0] LED,
//		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
//		  output logic        UART_RXD_OUT,
//		  output logic        UART_CTS		  
            );
  // add SystemVerilog code & module instantiations here
   
   logic [4:0] reg_0,reg_1,reg_2,reg_3,reg_4,reg_5,reg_6,reg_7;
   
    reg_param #(.W(5)) U_D0(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[0]),.d(SW[15:11]),.q(reg_0));
    reg_param #(.W(5)) U_D1(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[1]),.d(SW[15:11]),.q(reg_1));
    reg_param #(.W(5)) U_D2(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[2]),.d(SW[15:11]),.q(reg_2));
    reg_param #(.W(5)) U_D3(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[3]),.d(SW[15:11]),.q(reg_3));
    reg_param #(.W(5)) U_D4(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[4]),.d(SW[15:11]),.q(reg_4));
    reg_param #(.W(5)) U_D5(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[5]),.d(SW[15:11]),.q(reg_5));
    reg_param #(.W(5)) U_D6(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[6]),.d(SW[15:11]),.q(reg_6));
    reg_param #(.W(5)) U_D7(.clk(CLK100MHZ),.reset(BTNC),.lden(SW[7]),.d(SW[15:11]),.q(reg_7));


    dispctl U_DISPCTL(.clk(CLK100MHZ),.reset(BTNC),
                    .d0(reg_0[3:0]),.d1(reg_1[3:0]),.d2(reg_2[3:0]),.d3(reg_3[3:0]),.d4(reg_4[3:0]),.d5(reg_5[3:0]),.d6(reg_6[3:0]),.d7(reg_7[3:0]),
                    .dp0(reg_0[4]),.dp1(reg_1[4]),.dp2(reg_2[4]),.dp3(reg_3[4]),.dp4(reg_4[4]),.dp5(reg_5[4]),.dp6(reg_6[4]),.dp7(reg_7[4]),
                    .seg(SEGS),.dp(DP),.an(AN));


endmodule // nexys4DDR
