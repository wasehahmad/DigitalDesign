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


module rtl_transmitter(
    input logic clk_100mhz,
    input logic reset,
    input logic send,
    input logic [7:0] data,
    output logic txd,
    output logic txen,
    output logic rdy
    );
    
    
    parameter BAUD = 50_000;
    parameter BAUD2 = 100_000;
    logic clk_baud_out;
    logic baud_pulse_out;
    logic [3:0] counter_out;
    logic sending;
    logic baud2;
    assign baud2= BAUD*2;
    
    //outputs a clock at a rate of the baud rate
    clkenb #(.DIVFREQ(BAUD))U_BAUD_RATE(.clk(clk_100mhz),.reset(reset | ~sending),.enb(clk_baud_out));
    
    // Single pulser used on the baud rate clk so that the we can use it to increment the
    // counter once per 100MHz clk cycle
    single_pulser U_BAUD_PULSE(.clk(clk_100mhz), .din(clk_baud_out), .d_pulse(baud_pulse_out));
    
    // Counter for the data signal to know which data bit is currently transmitting
    bcdcounter #(.COUNT_CEILING(8)) U_BIT_COUNTER(.clk(clk_100mhz), .reset(reset), .enb(baud_pulse_out & sending), .Q(counter_out));
    
    //==========================================================================
    logic clk_baud_2_out;
    logic one_bit_sending;
    logic waiting;
    logic baud_pulse_2_out;
    logic [3:0] bit_counter_out;
    logic [3:0] wait_counter_out;
    
    
    
    //outputs a clock at a rate of twice the baud rate
    clkenb #(.DIVFREQ(BAUD2))U_BAUD2_RATE(.clk(clk_100mhz),.reset(reset | ~one_bit_sending),.enb(clk_baud_2_out));
    
    // Single pulser used on the baud rate clk so that the we can use it to increment the
    // counter once per 100MHz clk cycle
    single_pulser U_BAUD_2_PULSE(.clk(clk_100mhz), .din(clk_baud_2_out), .d_pulse(baud_pulse_2_out));
    
    // Counter for the data signal to know which part of the data bit is currently transmitting
    bcdcounter #(.COUNT_CEILING(2)) U_2_BIT_COUNTER(.clk(clk_100mhz), .reset(reset), .enb(baud_pulse_2_out & one_bit_sending), .Q(bit_counter_out));
    
    //counts time for two bits to send. waiting in IDLE state
    bcdcounter #(.COUNT_CEILING(5)) U_WAIT_BIT_COUNTER(.clk(clk_100mhz), .reset(reset), .enb(baud_pulse_2_out & waiting), .Q(wait_counter_out));
    
    
    //==========================================================================
    transmitter_fsm U_FSM(.clk(clk_100mhz), .reset(reset), .send(send), .data(data), 
                          .count(counter_out), .bit_count(bit_counter_out), .wait_counter(wait_counter_out),
                          .rdy(rdy), .txd(txd), .txen(txen),
                          .sending(sending), .one_bit_sending(one_bit_sending), .waiting(waiting));
    
    //use bcd counter to keep track of which bit was sent last
    //fsm to move between states(READY SENDING 
    //use clock enable to sample at the BAUD rate
    //
    
endmodule
