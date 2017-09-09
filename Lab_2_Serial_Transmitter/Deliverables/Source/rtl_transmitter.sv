//-----------------------------------------------------------------------------
// Title         : rtl_transmitter
// Project       : Lab 2
//-----------------------------------------------------------------------------
// File          : rtl_transmitter.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 9/04/2017
//-----------------------------------------------------------------------------
// Description :
// This module is the top level module for the asynchronous serial transmitter.
//-----------------------------------------------------------------------------


module rtl_transmitter(
    input logic clk_100mhz,
    input logic reset,
    input logic send,
    input logic [7:0] data,
    output logic txd,
    output logic rdy
    );
    parameter BAUD = 9600;
    logic clk_baud_out;
    logic baud_pulse_out;
    logic [3:0] counter_out;
    
    //outputs a clock at a rate of the baud rate
    clkenb #(.DIVFREQ(BAUD))U_BAUD_RATE(.clk(clk_100mhz),.reset(reset | rdy),.enb(clk_baud_out));
    
    // Single pulser used on the baud rate clk so that the we can use it to increment the
    // counter once per 100MHz clk cycle
    single_pulser U_BAUD_PULSE(.clk(clk_100mhz), .din(clk_baud_out), .d_pulse(baud_pulse_out));
    
    // Counter for the data signal to know which data bit is currently transmitting
    bcdcounter U_BIT_COUNTER(.clk(clk_100mhz), .reset(reset), .enb(baud_pulse_out & ~rdy), .Q(counter_out));
    
    transmitter_fsm U_FSM(.clk(clk_100mhz), .reset(reset), .send(send), .data(data), 
                          .count(counter_out), .rdy(rdy), .txd(txd));
    
    //use bcd counter to keep track of which bit was sent last
    //fsm to move between states(READY SENDING 
    //use clock enable to sample at the BAUD rate
    //
    
endmodule
