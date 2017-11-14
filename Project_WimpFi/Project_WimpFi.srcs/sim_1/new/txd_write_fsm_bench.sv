`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2017 09:43:35 AM
// Design Name: 
// Module Name: txd_write_fsm_bench
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


module txd_write_fsm_bench;

    logic clk;
    logic rst;
    logic [7:0] write_addr;
    logic [7:0] w_data,data;
    logic wen,read_en,XWR,send;
    logic done;
    
    txd_write_fsm DUV(.clk(clk),.reset(reset),.XWR(XWR),.XSEND(send),.data(data),.wen(wen),.w_addr(write_addr),.w_data(w_data),.done_writing(done));
endmodule
