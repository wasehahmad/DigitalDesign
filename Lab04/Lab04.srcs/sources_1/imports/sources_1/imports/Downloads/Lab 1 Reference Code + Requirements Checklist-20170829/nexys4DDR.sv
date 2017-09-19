//-----------------------------------------------------------------------------
// Title         : Nexys4 Simple Top-Level File
// Project       : ECE 491
//-----------------------------------------------------------------------------
// File          : nexys4DDR.sv
// Author        : John Nestor  <nestorj@nestorj-mbpro-15>
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
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
//-----------------------------------------------------------------------------

module nexys4DDR (
		  // un-comment the ports that you will use
          input logic         CLK100MHZ,
//		  input logic [7:0]   SW,
		  input logic 	      BTNC,
//		  input logic 	      BTNU, 
//		  input logic 	      run, 
//		  input logic 	      BTNL, 
//		  input logic 	      BTNR,
//		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP,
		  output logic [1:0]  LED,
		  input logic         UART_TXD_IN
//		  input logic         UART_RTS,		  
//		  output logic        UART_RXD_OUT,
//		  output logic        txd_ext,
//		  output logic        rdy_ext,
//		  output logic        send_ext
//		  output logic        UART_CTS		  
            );
  // add SystemVerilog code & module instantiations here
    logic [7:0] data;
    receiver_top U_RECEIVER(.clk(CLK100MHZ), .reset(BTNC), .rxd(UART_TXD_IN), .rdy(LED[0]), .data(data), .ferr(LED[1]));

    dispctl U_DISPCTL(.clk(CLK100MHZ),.reset(BTNC),
                    .d0(data[0]),.d1(data[1]),.d2(data[2]),.d3(data[3]),.d4(data[4]),.d5(data[5]),.d6(data[6]),.d7(data[7]),
                    .dp0(0),.dp1(0),.dp2(0),.dp3(0),.dp4(0),.dp5(0),.dp6(0),.dp7(0),
                    .seg(SEGS),.dp(DP),.an(AN));

   
   




endmodule // nexys4DDR
