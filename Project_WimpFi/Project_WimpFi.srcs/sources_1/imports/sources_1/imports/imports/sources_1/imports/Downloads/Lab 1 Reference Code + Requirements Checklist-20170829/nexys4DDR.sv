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

module nexys4DDR #(parameter BAUD = 50_000,TXD_BAUD = 50_000, TXD_BAUD_2 = TXD_BAUD*2,UART_BAUD = 9600) (
		  // un-comment the ports that you will use
          input logic         CLK100MHZ,
		  input logic [7:0]   SW,
//		  input logic         run,
		  input logic 	      BTNC,
		  input logic 	      BTNU, 
		  input logic         RXDATA, 
		  input logic 	      BTNL, 
		  input logic 	      BTNR,
		  input logic 	      BTND,
		  output logic [6:0]  SEGS,
		  output logic [7:0]  AN,
		  output logic 	      DP,
//		  output logic [1:0]  LED,
		  input logic         UART_TXD_IN,
//		  input logic         UART_RTS,		  
		  output logic        UART_RXD_OUT,
		  output logic        TXDATA,
		  output logic        CFGCLK,
		  output logic        CFGDAT,
		  output logic        received_radio,
          output logic        CARDET,
          output logic        WRITE,
          output logic        ERROR,
          output logic        TXEN,
          output logic        TXD,
          output logic        TRANSMITTER_READY,
          output logic        WRITE_SOURCE
//		  output logic        UART_CTS		  
            );
    logic [7:0] reg_0,reg_1,reg_2,reg_3, reg_4;
       
    logic debounced_reset,debounced_up,debounced_down,debounced_left,debounced_right;
    logic left_pusle,right_pusle,up_pusle,down_pusle;
    logic rrd_pulse;
    logic [7:0] XDATA,RDATA;
    logic [7:0] src_mac;
    logic [7:0] current_seg;
    logic txen; 
    logic debounced_send,send;
    logic error,txd,write,cardet;
    logic XWR,XSEND,XRDY,RRD,RRDY;
    logic type_2_seen,ACK_SEEN;
    logic [7:0] type_2_source;
    logic WATCHDOG_ERROR;
    logic [7:0] XERRCNT,RERRCNT;
       
    //========================RADIO_LOGIC========================================   
    logic radio_clk;
    assign TXDATA = txd; 
    assign CFGCLK =  !txen;
    assign CFGDAT = 1;
    assign received_radio = RXDATA;
    assign CARDET = cardet;
    assign WRITE = write;
    assign ERROR = error;
    assign debounced_reset = (debounced_left && debounced_right);
    //=========================================================================== 

    
    //buttons for reset and sending
    debounce U_SEND_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNC), .button_out(debounced_send));
    debounce U_UP_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNU), .button_out(debounced_up));
    debounce U_DOWN_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTND), .button_out(debounced_down));
    debounce U_LEFT_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNL), .button_out(debounced_left));
    debounce U_RIGHT_DEBOUNCE(.clk(CLK100MHZ), .button_in(BTNR), .button_out(debounced_right));
    
    //=================================================TRANSMITTER SETUP=================================================
    //asynch receiver
    logic uart_rxd_rdy;
    receiver_top #(.BAUD(UART_BAUD)) U_UART_RXD(.clk(CLK100MHZ),.reset(debounced_reset),.rxd(UART_TXD_IN),.rdy(uart_rxd_rdy),.ferr(),.data(XDATA));
    
    //single pulser to pulse the ready signal from the UART receiver
    single_pulser U_XWR_SINGLE_PULSE(.clk(CLK100MHZ),.din(uart_rxd_rdy),.d_pulse(XWR));

    assign XSEND = (XDATA ==8'h04 )&& XWR;//8'h04 is EOT or cntrl-D

    //transmitter module                    
    transmitter_module #(.BIT_RATE(BAUD)) U_TXD_MOD(.clk(CLK100MHZ),.reset(debounced_reset),.XDATA(XDATA),.XWR(XWR),.XSEND(XSEND),
                                                        .cardet(cardet),.type_2_seen(type_2_seen),.ACK_SEEN(ACK_SEEN),.type_2_source(type_2_source),
                                                        .MAC(src_mac),.XRDY(XRDY),.ERRCNT(XERRCNT),.txen(txen),.txd(txd),.WATCHDOG_ERROR(WATCHDOG_ERROR));       
              
    
    //=================================================RECEIVER SETUP=================================================
    logic sync_data;
    //synchronize the data by using a flip flop
    always_ff @(posedge CLK100MHZ) begin
        if(debounced_reset) sync_data <=0;
        else sync_data <= RXDATA;
    end
    
    logic uart_txd_rdy;
    //single pulser to pulse the ready signal from the UART receiver
    single_pulser U_RRD_SINGLE_PULSE(.clk(CLK100MHZ),.din(uart_txd_rdy),.d_pulse(RRD));
    
    //receiver module
    receiver_module #(.BIT_RATE(BAUD)) U_RXD_MOD(.clk(CLK100MHZ),.reset(debounced_reset),.RXD(sync_data),.RRD(RRD),.mac_addr(src_mac),.cardet(cardet),.RDATA(RDATA),.RRDY(RRDY),
                            .RERRCNT(RERRCNT),.type_2_seen(type_2_seen),.ack_seen(ack_seen),.source(source));                                                 
    //pulse the write signal
    single_pulser U_WRITE_PULSER (.clk(CLK100MHZ), .din(RRD), .d_pulse(rrd_pulse));

    //SYNC TO REALTERM
    asynch_transmitter U_ASYNCH_TX(.clk_100mhz(CLK100MHZ),.reset(debounced_reset),.send(RRDY),.data(RDATA),.txd(UART_RXD_OUT),.rdy(uart_txd_rdy)); 
    
    assign TXD = sync_data;
    assign TRANSMITTER_READY = RRDY;
    assign WRITE_SOURCE = RRD;
    assign TXEN = cardet;
    
    
    //=================================================DISPLAY SETUP=================================================
                                                    
    //single pulsers for the buttons
    single_pulser U_LEFT_PULSER (.clk(CLK100MHZ), .din(debounced_left), .d_pulse(left_pulse));
    single_pulser U_RIGHT_PULSER (.clk(CLK100MHZ), .din(debounced_right), .d_pulse(right_pulse));
    single_pulser U_UP_PULSER (.clk(CLK100MHZ), .din(debounced_up), .d_pulse(up_pulse));
    single_pulser U_DOWN_PULSER (.clk(CLK100MHZ), .din(debounced_down), .d_pulse(down_pulse));

    //configuration for Source MAC Address
    config_mac_fsm U_SRC_MAC_FSM(.clk(CLK100MHZ), .reset(debounced_reset), .button_left(left_pulse), .button_right(right_pulse), .button_up(up_pulse), .button_down(down_pulse), .src_mac(src_mac), .current_seg(current_seg));
    

    
    reg_param #(.W(8)) U_D0(.clk(CLK100MHZ),.reset(debounced_reset),.lden(rrd_pulse),.d(RDATA),.q(reg_0));
    reg_param #(.W(8)) U_D1(.clk(CLK100MHZ),.reset(debounced_reset),.lden(rrd_pulse),.d(reg_0),.q(reg_1));
    reg_param #(.W(8)) U_D2(.clk(CLK100MHZ),.reset(debounced_reset),.lden(rrd_pulse),.d(reg_1),.q(reg_2));
    reg_param #(.W(8)) U_D3(.clk(CLK100MHZ),.reset(debounced_reset),.lden(rrd_pulse),.d(reg_2),.q(reg_3));
    //reg_param #(.W(8)) U_SRC_MAC(.clk(CLK100MHZ),.reset(debounced_reset),.lden(up_pulse || down_pulse),.d(src_mac),.q(reg_4));
    
    dispctl U_DISPCTL(.clk(CLK100MHZ),.reset(debounced_reset),
                    .d0(reg_0[3:0]),.d1(reg_0[7:4]),.d2(reg_1[3:0]),.d3(reg_1[7:4]),.d4(reg_2[3:0]),.d5(reg_2[7:4]),.d6(src_mac[3:0]),.d7(src_mac[7:4]),
                    .dp0(1),.dp1(1),.dp2(1),.dp3(1),.dp4(1),.dp5(1),.dp6(1),.dp7(1),
                    .seg(SEGS),.dp(DP),.an(AN));

    
    
endmodule // nexys4DDR
