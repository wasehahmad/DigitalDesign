`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 11/14/2017 08:57:35 AM
// Design Name: 
// Module Name: txd_fsm
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


module txd_fsm(
    input logic clk,
    input logic reset,
    input logic network_busy,
    input logic cardet,
    input logic [6:0] DIFS_COUNT,
    input logic done_writing,
    input logic [9:0] CONT_WIND_COUNT,//might need to parameterize the widths
    input logic [8:0] ACK_TIME_COUNT,
    output logic XRDY,
    output logic loading,
    output logic incr_error,
    output logic reset_counters,
    output logic transmit
    );
    
    
    
endmodule
