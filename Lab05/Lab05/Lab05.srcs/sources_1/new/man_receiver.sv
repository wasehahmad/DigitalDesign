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
    logic bit_seen;
    assign bit_seen = write_one | write_zero;


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
    
    
    //==========================================================================counters with error ccheck blocks
    logic start_receive;
    logic reset_counters;
    logic [3:0] byte_count;
    logic [3:0] abn_bit_count;
    logic abn_bit_seen;
    logic [$clog2(NUM_SAMPLES*2):0] samp_count;
    logic consec_high,consec_low;

    
    //counter to count number of bits seen for the byte
    bcdcounter #(.LAST_VAL(8),.W(4)) U_BYTE_COUNTER(.clk(clk),.reset(reset | reset_counters),.enb(bit_seen),.Q(byte_count));
    
    //counter for number of samples
    bcdcounter #(.LAST_VAL(NUM_SAMPLES*2)) U_SAMP_COUNTER(.clk(clk),.reset(reset|bit_seen|abn_bit_seen),.enb(sample),.Q(samp_count));
    
    //num of samples since last bit>16
    logic samp_gt_16;
    assign samp_gt_16 = samp_count>15;
    
    //counter for number of abnormal bits i.e. consecutive highs or lows
    bcdcounter #(.LAST_VAL(2)) U_ABN_BIT_COUNTER(.clk(clk),.reset(reset | reset_counters),.enb(abn_bit_seen),.Q(abn_bit_count));

    //correlators that tell if a bit is high or low consecutively
    correlator #(.PATTERN(16'hFFFF)) U_CORREL_ABN_HIGH(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.write(consec_high));
    correlator #(.PATTERN(16'h0000)) U_CORREL_ABN_LOW(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.write(consec_low));

    assign abn_bit_seen = (consec_high | consec_low) & samp_gt_16;
    
    receive_fsm U_RECEIVE_FSM(.clk(clk),.reset(reset),.count_8(byte_count),.bit_count(abn_bit_count),
                            .error_condition(abn_bit_seen),.consec_low(consec_low & abn_bit_seen),.start_receiving(start_receive),
                            .error(error),.write(write),.eof(eof),.resetcounters(reset_counters));




endmodule
