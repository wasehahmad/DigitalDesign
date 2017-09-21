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
		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
//		  output logic        UART_RXD_OUT,
		  output logic        txd_ext,
		  output logic        rdy_ext,
		  output logic        ferr
//		  output logic        UART_CTS		  
            );
            
    assign ferr= LED[1];
//    assign UART_RXD_OUT = 1;
    assign rdy_ext = LED[0];
    assign txd_ext = UART_TXD_IN;
  // add SystemVerilog code & module instantiations here
    logic [7:0] data;
    receiver_top U_RECEIVER(.clk(CLK100MHZ), .reset(BTNC), .rxd(UART_TXD_IN), .rdy(LED[0]), .data(data), .ferr(LED[1]));

    dispctl U_DISPCTL(.clk(CLK100MHZ),.reset(BTNC),
                    .d0(data[3:0]),.d1(data[7:4]),.d2(0),.d3(0),.d4(0),.d5(0),.d6(0),.d7(0),
                    .dp0(1),.dp1(1),.dp2(1),.dp3(1),.dp4(1),.dp5(1),.dp6(1),.dp7(1),
                    .seg(SEGS),.dp(DP),.an(AN));

   
   




endmodule // nexys4DDR
