`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2017 10:37:52 AM
// Design Name: 
// Module Name: correlator_bench_1
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


module correlator_bench_1;

    // signals for connecting the counter
    logic clk;
    logic enb;
    logic reset; 
    logic d_in;
    logic [4:0] csum;
    logic h_out;
    logic l_out;
    
    // instantiate device under verification (counter)
    correlator DUV(.clk(clk), .reset(reset), .enb(enb), .d_in(d_in), .csum(csum), .h_out(h_out), .l_out(l_out));
    
    // clock generator with period=20 time units
    always
        begin
            clk = 0; #5; 
            clk = 1; #5;
        end

    //task send

    initial begin
        reset = 0;
        @(posedge clk);
        // do a reset and check that it worked
        reset = 1;
        repeat(10)@(posedge clk);
        #1;
        reset = 0;
        d_in = 1;
        repeat(10)@(posedge clk);
        #1;
    end
endmodule
