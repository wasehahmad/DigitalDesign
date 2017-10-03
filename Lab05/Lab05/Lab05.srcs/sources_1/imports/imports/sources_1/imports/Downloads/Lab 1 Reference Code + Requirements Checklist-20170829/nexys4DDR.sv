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
		  input logic [7:0]   SW,
		  input logic         run,
		  input logic 	      BTNC,
		  input logic 	      BTNU, 
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
		  output logic        UART_RXD_OUT,
		  output logic        transmitted,
		  output logic        ferr,
		  output logic        rxd_rdy
//		  output logic        ferr
//		  output logic        UART_CTS		  
            );
    logic rdy;    
        
//    assign ferr= LED[1];
//    assign UART_RXD_OUT = 1;
    

    logic debounced_send;
    logic cont_send;
    logic send;
    assign send = debounced_send | cont_send;
    logic txd;
    logic rxd;
    
    assign rxd = UART_TXD_IN; 
    assign UART_RXD_OUT = 1;
   

    
    
  // add SystemVerilog code & module instantiations here
    logic [7:0] data;
    logic [7:0] data_2;
    logic [7:0] reg_0,reg_1,reg_2,reg_3;
    logic rdy_pulse;
    
    assign transmitted = txd;  
    assign rdy = LED[0];
    
    debounce U_SEND_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNU), .pulse(debounced_send));
    debounce U_SEND_CONT(.clk(CLK100MHZ), .button_in(run), .button_out(cont_send));
    
    rtl_transmitter(.clk_100mhz(CLK100MHZ),.reset(BTNC),.send(send),.data(SW[7:0]),.txd(txd),.rdy());
    
    receiver_top U_RECEIVER_RTERM(.clk(CLK100MHZ), .reset(BTNC), .rxd(rxd), .rdy(LED[0]), .data(data), .ferr(LED[1]));
    
    single_pulser U_RDY_PULSER (.clk(CLK100MHZ), .din(rdy), .d_pulse(rdy_pulse));
    
    reg_param #(.W(8)) U_D0(.clk(CLK100MHZ),.reset(BTNC),.lden(rdy_pulse),.d(data),.q(reg_0));
    reg_param #(.W(8)) U_D1(.clk(CLK100MHZ),.reset(BTNC),.lden(rdy_pulse),.d(reg_0),.q(reg_1));
    reg_param #(.W(8)) U_D2(.clk(CLK100MHZ),.reset(BTNC),.lden(rdy_pulse),.d(reg_1),.q(reg_2));
    reg_param #(.W(8)) U_D3(.clk(CLK100MHZ),.reset(BTNC),.lden(rdy_pulse),.d(reg_2),.q(reg_3));
    
    
    
    receiver_top U_RECEIVER_TXD(.clk(CLK100MHZ), .reset(BTNC), .rxd(txd), .rdy(rxd_rdy), .data(data_2), .ferr(ferr));

    dispctl U_DISPCTL(.clk(CLK100MHZ),.reset(BTNC),
                    .d0(reg_0[3:0]),.d1(reg_0[7:4]),.d2(reg_1[3:0]),.d3(reg_1[7:4]),.d4(reg_2[3:0]),.d5(reg_2[7:4]),.d6(reg_3[3:0]),.d7(reg_3[7:4]),
                    .dp0(1),.dp1(1),.dp2(1),.dp3(1),.dp4(1),.dp5(1),.dp6(1),.dp7(1),
                    .seg(SEGS),.dp(DP),.an(AN));

   
   




endmodule // nexys4DDR
