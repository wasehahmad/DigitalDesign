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
		  input logic [5:0]  SW,
		  input logic         run,
		  input logic 	      BTNC,
		  input logic 	      BTNU, 
//		  input logic 	      BTNL, 
//		  input logic 	      BTNR,
//		  input logic 	      BTND,
//		  output logic [6:0]  SEGS,
//		  output logic [7:0]  AN,
//		  output logic 	      DP,
		  output logic        LED[0],
//		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
//		  output logic        UART_RXD_OUT,
		  output logic        txd_ext,
		  output logic        rdy_ext,
		  output logic        txen,
		  output logic        send
//          output logic [2:0]  JB
//		  output logic        UART_CTS		  
            );
  // add SystemVerilog code & module instantiations here
  
    logic debounced_reset;
//    logic debounced_send;
    assign rdy_ext = LED[0];
    logic send_int;
    logic [7:0] data;
    assign send = send_int;
    
//    assign JB = 3'd0;
    
    mxtest_2 U_TEST(.clk(CLK100MHZ),.reset(debounced_reset),.run(run),.length(SW[5:0]),.send(send_int),.data(data),.ready(LED[0]));
    
    //Debouncers for the reset and send buttons
    debounce U_RESET_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNC), .button_out(debounced_reset));
    
   // debounce U_SEND_CONT(.clk(CLK100MHZ), .button_in(run), .button_out(continuous_send));
    
    //debounce U_SEND_PULSE(.clk(CLK100MHZ), .button_in(BTNU), .pulse(pulse_run)); 
    
    rtl_transmitter U_TRANSMITTER(.clk_100mhz(CLK100MHZ),.reset(debounced_reset),.send(send_int),.data(data),
                           .txd(txd_ext),.rdy(LED[0]),.txen(txen)/*,.curr_state(JB[2:0])*/);
   




endmodule // nexys4DDR
