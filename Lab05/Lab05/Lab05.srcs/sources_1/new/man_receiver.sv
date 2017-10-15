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


module man_receiver #(parameter DATA_WIDTH = 8)(
    input logic clk,
    input logic reset,
    input logic rxd,
    output logic cardet,
    output logic [DATA_WIDTH-1:0] data,
    output logic write,
    output logic error
    );
    
    logic speed_up,slow_down;
    logic speed_up_z,slow_down_z;
    logic speed_up_o,slow_down_o;
    logic sample;
    logic [4:0] diff_z,diff_o,phase_diff;/////////////this should be phase_dif--> var_campler input
    logic write_zero,write_one;
    
    always_comb begin
        speed_up = speed_up_z | speed_up_o;
        slow_down = slow_down_z | slow_down_o;
        
        //write_zero and write_one are both high for one clock cylce
        if(write_zero) phase_diff = diff_z;
        else if(write_one) phase_diff = diff_o;  
        else phase_diff = 0; 
        
    end
    

       
    
    //sampler that varies frequency of sampling based on input
    variable_sampler #(.BAUD(50000),.SAMPLE_FREQ(16)) U_SAMPLER(.clk(clk),.reset(reset), .speed_up(speed_up),.slow_down(slow_down),
                                                               .diff_amt(phase_diff),.enb(sample));
    
    //correlator to store the input values
    correlator #(.PATTERN(16'h00FF)) U_CORREL_ZERO(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.h_out(write_zero),
                                                   .diff(diff_z),.speed_up(speed_up_z),.slow_down(slow_down_z));

    //correlator to store the input values
    correlator #(.PATTERN(16'hFF00)) U_CORREL_ONE(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.h_out(write_one),
                                                   .diff(diff_o),.speed_up(speed_up_o),.slow_down(slow_down_o));
    
    
    //require: correlator to check for result, numerically controlled oscillator to sample (should be changeable) 
    
    //
    
    
    //in correlator, also check for 
    
    
endmodule
