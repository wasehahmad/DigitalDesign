`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 09/19/2017 08:12:16 AM
// Design Name: 
// Module Name: receiver_top
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


module receiver_top(
    input logic clk,
    input logic rxd,
    input logic reset, 
    output logic rdy,
    output logic ferr,
    output logic [7:0] data
    );
    
    parameter BAUD = 9600;
    parameter BAUD16 = BAUD * 16;
    logic baud_clk;
    logic restart_16_clock;
    
    clkenb#(.DIVFREQ(BAUD16)) U_BAUD_CLK(.clk(clk), .reset(reset | restart_16_clock), .enb(baud_clk));
    
    receiver_fsm U_FSM(.clk(clk), .reset(reset), .rxd(rxd),  .baud16_clk(baud_clk), .rdy(rdy), .data(data), .ferr(ferr), .restart_16_clk(restart_16_clock));
    
    
    
    
endmodule
