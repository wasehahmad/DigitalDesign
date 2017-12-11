`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
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
// Module which attempts to output synchronization signals for the variable sampler depending on when the last bit was seen
//////////////////////////////////////////////////////////////////////////////////


module synchronizer #(parameter  NUM_SAMP = 16, COUNT_MAX = NUM_SAMP,W = ($clog2(NUM_SAMP)+1),MAX_WAIT_FOR_BIT = NUM_SAMP+5)(
    input logic clk,
    input logic reset,
    input logic bit_seen,
    input logic count_enb,
    output logic slow_down,
    output logic speed_up,
    output logic [W-1:0] phase_diff,
    output logic no_bit_seen,
    output logic [W-1:0] num_samples
    );
    
    //need to adjust for the beginnig of the frame i.e. if all im seeing is noise......... dont increase the counter or compare
    
    logic [W-1:0]n_diff;
    logic n_slow,n_speed,n_no_bit_seen;
    
    always_comb begin
        n_slow  = 0;
        n_speed = 0;
        n_diff = 0;
        n_no_bit_seen = 0;
        if(num_samples>COUNT_MAX)begin
            n_diff = num_samples - COUNT_MAX;//max ndiff = 5
            n_slow = 1;
        end
        else if(num_samples<COUNT_MAX)begin
            n_diff = COUNT_MAX-num_samples;
            if(n_diff>5)n_diff = 0;//max ndiff should be 5, if more than that, dont attempt to resynchronize
            n_speed = 1;
        end
        //check if too much time has passed since the next bit has been seen. value of 21 is chosen as default
        //for number of samples chosen
        if(num_samples >= MAX_WAIT_FOR_BIT)begin
            n_no_bit_seen = 1;
        end
    
    end
    
    bcdcounter #(.LAST_VAL(NUM_SAMP*2)) U_BIT_RECOG_COUNT(.clk(clk),.reset(reset | bit_seen | no_bit_seen ),.enb(count_enb),.Q(num_samples));
    
    always_ff @(posedge clk)begin
        if(reset | !bit_seen )begin
            slow_down <= 0;
            speed_up <= 0;
            phase_diff <= 0;
            //when the number of samples exceeds an upper bound
            no_bit_seen <= n_no_bit_seen;
        end
        else begin
            if(bit_seen)begin//might need to check more than just at this rate
                slow_down <= n_slow;
                speed_up  <= n_speed;
                if(n_diff < 5)phase_diff <= n_diff;
                else phase_diff <=0;
            end
        end
    
    end
    
endmodule
