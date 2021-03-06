//-----------------------------------------------------------------------------
// Title         : Nexys4 Simple Top-Level File
// Project       : ECE 491
//-----------------------------------------------------------------------------
// File          : nexys4DDR.sv
// Author        : Waseh Ahmad $ Geoff Watson
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
//Credit : John Nestor
//-----------------------------------------------------------------------------
// Modification history :
// 22.07.2016 : created
//-----------------------------------------------------------------------------

module nexys4DDR #(parameter BAUD = 50_000,TXD_BAUD = 50_000, TXD_BAUD_2 = TXD_BAUD*2) (
		  // un-comment the ports that you will use
          input logic         CLK100MHZ,
		  input logic [7:0]   SW,
//		  input logic         run,
		  input logic 	      BTNC,
		  input logic 	      BTNU, 
		  input logic         RXDATA, 
//		  input logic 	      BTNL, 
//		  input logic 	      BTNR,
//		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP,
//		  output logic [1:0]  LED,
//		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
		  output logic        UART_RXD_OUT,
		  output logic        TXDATA,
		  output logic        CFGCLK,
		  output logic        CFGDAT,
		  output logic        received_radio,
          output logic        CARDET,
          output logic        WRITE,
          output logic        ERROR,
          output logic        SFD
//		  output logic        UART_CTS		  
            );
    logic rdy;    
    logic [7:0] reg_0,reg_1,reg_2,reg_3;
       
    logic debounced_reset;
    logic [7:0] data_rxd;
    logic [7:0] data;
    logic txen; 
    logic debounced_send;
    logic send;
    logic error,txd,write,cardet;
       
    logic radio_clk;
    assign TXDATA = txd; 
    assign CFGCLK =  !txen;
    assign CFGDAT = 1;
    assign received_radio = RXDATA;
    assign CARDET = cardet;
    assign WRITE = write;
    assign ERROR = error;
    

    
    //buttons for reset and sending
    debounce U_SEND_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNU), .button_out(debounced_send));
    debounce U_RESET_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNC), .button_out(debounced_reset));
    
    //use mxtest to transmit signals from the manchester transmitter
    mxtest_2 U_TEST(.clk(CLK100MHZ),.reset(debounced_reset),.run(debounced_send),.length(SW[5:0]),.send(send),.data(data),.ready(rdy));
    
    //manchester transmitter
    rtl_transmitter #(.BAUD(TXD_BAUD),.BAUD2(TXD_BAUD_2)) U_TRANSMITTER(.clk_100mhz(CLK100MHZ),.reset(debounced_reset),.send(send),.data(data),
                               .txd(txd),.rdy(rdy),.txen(txen));
    
    logic sync_data;
    always_ff @(posedge CLK100MHZ) begin
        if(debounced_reset) sync_data <=0;
        else sync_data <= RXDATA;
    end
    
    
    //manchester receiver
    man_receiver    #(.BIT_RATE(BAUD))  U_MAN_RECEIVER(.clk(CLK100MHZ), .reset(debounced_reset), .rxd(sync_data), .cardet(cardet), .data(data_rxd), .write(write), .error(error)
                                                       ,.SFD(SFD));
    
    
    //pulse the write signal
    single_pulser U_WRITE_PULSER (.clk(CLK100MHZ), .din(write), .d_pulse(write_pulse));
    
    reg_param #(.W(8)) U_D0(.clk(CLK100MHZ),.reset(debounced_reset),.lden(write_pulse),.d(data_rxd),.q(reg_0));
    reg_param #(.W(8)) U_D1(.clk(CLK100MHZ),.reset(debounced_reset),.lden(write_pulse),.d(reg_0),.q(reg_1));
    reg_param #(.W(8)) U_D2(.clk(CLK100MHZ),.reset(debounced_reset),.lden(write_pulse),.d(reg_1),.q(reg_2));
    reg_param #(.W(8)) U_D3(.clk(CLK100MHZ),.reset(debounced_reset),.lden(write_pulse),.d(reg_2),.q(reg_3));
    
    dispctl U_DISPCTL(.clk(CLK100MHZ),.reset(debounced_reset),
                    .d0(reg_0[3:0]),.d1(reg_0[7:4]),.d2(reg_1[3:0]),.d3(reg_1[7:4]),.d4(reg_2[3:0]),.d5(reg_2[7:4]),.d6(reg_3[3:0]),.d7(reg_3[7:4]),
                    .dp0(1),.dp1(1),.dp2(1),.dp3(1),.dp4(1),.dp5(1),.dp6(1),.dp7(1),
                    .seg(SEGS),.dp(DP),.an(AN));
                    
    //BUILD FIFO
    logic read,full,empty,read_pulse;
    logic [7:0] data_fifo;
    sasc_fifo #(.FIFO_DEPTH(256)) U_FIFO(.clk(CLK100MHZ),.rst(debounced_reset),.din(data_rxd),.we(write_pulse),.re(read_pulse),.dout(data_fifo),.full(full),.empty(empty));
    
    single_pulser U_READ_PULSER (.clk(CLK100MHZ), .din(read), .d_pulse(read_pulse));
    
    //SYNC TO REALTERM
    asynch_transmitter U_ASYNCH_TX(.clk_100mhz(CLK100MHZ),.reset(debounced_reset),.send(!empty),.data(data_fifo),.txd(UART_RXD_OUT),.rdy(read));
    
    
endmodule // nexys4DDR
