`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2017 10:03:16 AM
// Design Name: 
// Module Name: preamble_shreg_bench
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


module preamble_shreg_bench;

    logic clk;
    logic reset;
    logic write_0;
    logic write_1;
    logic preamble_detected;
    
    //instantiation 
    preamble_detector_shreg DUV (.clk(clk), .reset(reset), .write_0(write_0), .write_1(write_1), .preamble_detected(preamble_detected));
    
    // clock generator
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end

    initial begin
        write_0 = 0;
        write_1 = 0;

        reset = 1;
        repeat(30)@(posedge clk);
        #2;
        reset = 0;
        repeat(1)@(posedge clk);#1;
        write_0 = 0;
        write_1 = 1;
        repeat(1)@(posedge clk);#1;//1
        write_0 = 1;
        write_1 = 0;
        repeat(1)@(posedge clk);#1;//2
        write_0 = 0;
        write_1 = 1;
        repeat(1)@(posedge clk);#1;//3
        write_0 = 1;
        write_1 = 0;
        repeat(1)@(posedge clk);#1;//4
        write_0 = 0;
        write_1 = 1;
        repeat(1)@(posedge clk);#1;//5
        write_0 = 1;
        write_1 = 0;
        repeat(1)@(posedge clk);#1;//6
        write_0 = 0;
        write_1 = 1;
        repeat(1)@(posedge clk);#1;//7
        write_0 = 1;
        write_1 = 0;
        repeat(1)@(posedge clk);#1;//8
        write_0 = 1;
        write_1 = 0;
        repeat(1)@(posedge clk);#1;//9 (make sure preamble_detect goes low)
                
    end
endmodule