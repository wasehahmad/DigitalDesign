`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2017 04:12:52 PM
// Design Name: 
// Module Name: rtl_transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module asynch_transmitter(
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
    logic sending;
    
    //outputs a clock at a rate of the baud rate
    clkenb #(.DIVFREQ(BAUD))U_BAUD_RATE(.clk(clk_100mhz),.reset(reset | ~sending),.enb(clk_baud_out));
    
    // Single pulser used on the baud rate clk so that the we can use it to increment the
    // counter once per 100MHz clk cycle
    single_pulser U_BAUD_PULSE(.clk(clk_100mhz), .din(clk_baud_out), .d_pulse(baud_pulse_out));
    
    // Counter for the data signal to know which data bit is currently transmitting
    bcdcounter_txd U_BIT_COUNTER(.clk(clk_100mhz), .reset(reset), .enb(baud_pulse_out & sending), .Q(counter_out));
    
    asynch_transmitter_fsm U_FSM(.clk(clk_100mhz), .reset(reset), .send(send), .data(data), 
                          .count(counter_out), .rdy(rdy), .txd(txd),.sending(sending));
    
    //use bcd counter to keep track of which bit was sent last
    //fsm to move between states(READY SENDING 
    //use clock enable to sample at the BAUD rate
    //
    
endmodule
