`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2017 08:16:34 PM
// Design Name: 
// Module Name: var_samp_bench
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


module var_samp_bench;
    
    logic clk;
    logic reset;
    logic speed_up;
    logic slow_down;
    logic [3:0] phase_dif;
    logic sample;
    
    //sampler that varies frequency of sampling based on input
    variable_sampler #(.BAUD(50000),.SAMPLE_FREQ(16)) DUV(.clk(clk),.reset(reset), .speed_up(speed_up),.slow_down(slow_down),
                                                           .diff_amt(phase_dif),.enb(sample));




    // clock generator
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end

    initial begin
        phase_dif = 0;
        speed_up = 0;
        slow_down = 0;
        

        reset = 1;
        repeat(30)@(posedge clk);
        #1;
        reset = 0;
        repeat(1000)@(posedge clk);
        phase_dif = 2;
        speed_up = 1;
        @(posedge clk);#1;
        phase_dif = 0;
        speed_up = 0;


    
    end
endmodule
