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
    logic [7:0] write_addr_b;
    logic write_en,XWR,XSEND;
    logic done_writing;
    
     txd_write_fsm DUV(.clk(clk),.reset(rst),.XWR(XWR),.XSEND(XSEND),.wen(write_en),.w_addr(write_addr_b),.done_writing(done_writing));
       
    always begin
         clk = 0;
         #5 clk = 1;
         #5;
     end
     
     initial begin
        rst = 1;
        XWR = 0;
        XSEND = 0;
        repeat(10) @(posedge clk);
        rst = 0;
        repeat(10) @(posedge clk);
        #1;
        XWR = 1;
        repeat(20) @(posedge clk);
        #1;
        XWR = 0;
        @(posedge clk);
        #1 XWR = 1;
        @(posedge clk);
        #1 XWR = 0;
        @(posedge clk);
        #1 XSEND = 1;
        repeat(2)@(posedge clk);
        $stop;
       
        
     end


endmodule
