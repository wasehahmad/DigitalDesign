`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 10/13/2017 04:31:04 PM
// Design Name: 
// Module Name: man_receiver
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
// Top level module for the manchester receiver block
//////////////////////////////////////////////////////////////////////////////////


module man_receiver #(parameter DATA_WIDTH = 8,NUM_SAMPLES = 16, PHASE_WIDTH = $clog2(NUM_SAMPLES)+1)(
    input logic clk,
    input logic reset,
    input logic rxd,
    output logic cardet,
    output logic [DATA_WIDTH-1:0] data,
    output logic write,
    output logic error
    );
    
    logic speed_up,slow_down;
    logic sample;
    logic [PHASE_WIDTH-1:0] phase_diff;


    //sampler that varies frequency of sampling based on input
    variable_sampler #(.BAUD(50000),.SAMPLE_FREQ(16)) U_SAMPLER(.clk(clk),.reset(reset), .speed_up(speed_up),.slow_down(slow_down),
                                                               .diff_amt(phase_diff),.enb(sample));
     
    //synchronizer                                                           
    synchronizer #(.NUM_SAMP(NUM_SAMPLES)) U_SYNC(.clk(clk),.reset(reset),.bit_seen(write_zero | write_one),
                                                .count_enb(sample),.slow_down(slow_down),.speed_up(speed_up),.phase_diff(phase_diff));
    
    //correlator to store the input values
    correlator #(.PATTERN(16'h00FF)) U_CORREL_ZERO(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.write(write_zero));

    //correlator to store the input values
    correlator #(.PATTERN(16'hFF00)) U_CORREL_ONE(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.write(write_one));
    
    
    //require: correlator to check for result, numerically controlled oscillator to sample (should be changeable) 
    
    //
    
    
    //in correlator, also check for 
    
    
endmodule
