`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2017 07:10:56 PM
// Design Name: 
// Module Name: synchronizer
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


module synchronizer #(parameter  NUM_SAMP = 16, COUNT_MAX = NUM_SAMP-1,W = ($clog2(NUM_SAMP)+1))(
    input logic clk,
    input logic reset,
    input logic bit_seen,
    input logic count_enb,
    output logic slow_down,
    output logic speed_up,
    output logic [W-1:0] phase_diff
    );
    
    //need to adjust for the beginnig of the fram i.e. if all im seeing is noise......... dont increase the counter or compare
    
    logic [W-1:0]num_samples;
    logic [W-1:0]n_diff;
    logic n_slow,n_speed;
    
    always_comb begin
        n_slow  = 0;
        n_speed = 0;
        n_diff = 0;
        if(num_samples>COUNT_MAX)begin
            n_diff = num_samples - COUNT_MAX;
            n_slow = 1;
        end
        else if(num_samples<COUNT_MAX)begin
            n_diff = COUNT_MAX-num_samples;
            n_speed = 1;
        end
    
    end
    
    bcdcounter #(.LAST_VAL(NUM_SAMP*2)) U_BIT_RECOG_COUNT(.clk(clk),.reset(reset | bit_seen),.enb(count_enb),.Q(num_samples));
    
    always_ff @(posedge clk)begin
        if(reset | !bit_seen)begin
            slow_down <= 0;
            speed_up <= 0;
            phase_diff <= 0;
        end
        else begin
            if(bit_seen)begin//might need to check more than just at this rate
                slow_down <= n_slow;
                speed_up  <= n_speed;
                phase_diff <= n_diff;
            end
     
        end
    
    end
    
endmodule
