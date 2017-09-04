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
    input clk_100mhz,
    input send,
    input [7:0] data,
    output txd,
    output rdy
    );
    
    
    //use bcd counter to keep track of which bit was sent last
    //fsm to move between states(READY SENDING 
    //use clock enable to sample at the BAUD rate
    //
    
endmodule
