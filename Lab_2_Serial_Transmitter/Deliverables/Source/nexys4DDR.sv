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
//credit John Nestor  <nestorj@nestorj-mbpro-15>
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
//-----------------------------------------------------------------------------

module nexys4DDR (
		  // un-comment the ports that you will use
          input logic         CLK100MHZ,
		  input logic [7:0]  SW,
		  input logic 	      BTNC,
		  input logic 	      BTNU, 
//		  input logic 	      BTNL, 
//		  input logic 	      BTNR,
//		  input logic 	      BTND,
//		  output logic [6:0]  SEGS,
//		  output logic [7:0]  AN,
//		  output logic 	      DP,
		  output logic [1:0]   LED,
//		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
		  output logic        UART_RXD_OUT,
		  output logic        txd_ext,
		  output logic        rdy_ext,
		  output logic        send_ext
//		  output logic        UART_CTS		  
            );
  // add SystemVerilog code & module instantiations here
  
    logic debounced_reset;
    logic debounced_send;
    assign LED[1] = LED[0];
    assign txd_ext = UART_RXD_OUT;
    assign rdy_ext = LED[0];
    assign send_ext = debounced_send;
    
    //Debouncers for the reset and send buttons
    debounce U_RESET_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNC), .button_out(debounced_reset));
    debounce U_SEND_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNU), .button_out(debounced_send));
     
    rtl_transmitter #(.BAUD(9600)) U_TRANSMITTER(.clk_100mhz(CLK100MHZ),.reset(debounced_reset),.send(debounced_send),.data(SW[7:0]),
                           .txd(UART_RXD_OUT),.rdy(LED[0]));
   




endmodule // nexys4DDR
