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


module man_receiver #(parameter DATA_WIDTH = 8,NUM_SAMPLES = 16, PHASE_WIDTH = $clog2(NUM_SAMPLES)+1, BIT_RATE = 50000)(
    input logic clk,
    input logic reset,
    input logic rxd,
    output logic cardet,
    output logic [DATA_WIDTH-1:0] data,
    output logic write,
    output logic error,
    output logic SFD,
    output logic samp_clk
    );
    
    logic speed_up,slow_down;
    logic sample;
    logic [PHASE_WIDTH-1:0] phase_diff;
    logic bit_seen;
    logic [PHASE_WIDTH-1:0] num_samples;
    assign bit_seen = write_one | write_zero;
    assign samp_clk = sample;
    

    
    

    //==========================================================================Synchronizer and correlators for bit detection

    
    //sampler that varies frequency of sampling based on input
    variable_sampler #(.BAUD(BIT_RATE),.SAMPLE_FREQ(16)) U_SAMPLER(.clk(clk),.reset(reset), .speed_up(speed_up),.slow_down(slow_down),
                                                               .diff_amt(phase_diff),.enb(sample));
     
    //synchronizer                                                           
    synchronizer #(.NUM_SAMP(NUM_SAMPLES)) U_SYNC(.clk(clk),.reset(reset),.bit_seen(write_zero | write_one),.num_samples(num_samples),
                                                .count_enb(sample),.slow_down(slow_down),.speed_up(speed_up),.phase_diff(phase_diff));
    
    //correlator to store the input values//resets to opposite 
    correlator #(.PATTERN(16'h00FF),.RST_PAT(16'hFFFF)) U_CORREL_ZERO(.clk(clk),.reset(reset | (cardet & write_one)),.enb(sample),.d_in(rxd),.write(write_zero));

    //correlator to store the input values//resets to opposite
    correlator #(.PATTERN(16'hFF00),.RST_PAT(16'h0000)) U_CORREL_ONE(.clk(clk),.reset(reset | (cardet & write_zero)),.enb(sample),.d_in(rxd),.write(write_one));
    
    
    //==========================================================================counters with error ccheck blocks and the FSM for receiving
    logic start_receive_pulse;
    logic reset_counters;
    logic [3:0] byte_count;
    logic [3:0] abn_bit_count;
    logic abn_bit_seen;
    logic [$clog2(NUM_SAMPLES*2):0] samp_count;
    logic consec_high,consec_low;
    logic eof_seen,eof;

    
    //counter to count number of bits seen for the byte
    bcdcounter #(.LAST_VAL(8+1),.W(4)) U_BYTE_COUNTER(.clk(clk),.reset(reset | reset_counters),.enb(bit_seen),.Q(byte_count));
    
    //counter for number of samples
    bcdcounter #(.LAST_VAL(NUM_SAMPLES*2)) U_SAMP_COUNTER(.clk(clk),.reset(reset|bit_seen|abn_bit_seen),.enb(sample),.Q(samp_count));
    
    //num of samples since last bit>16
    logic samp_gt_16;
    assign samp_gt_16 = samp_count>19;
    
    //counter for number of abnormal bits i.e. consecutive highs or lows
    bcdcounter #(.LAST_VAL(2)) U_ABN_BIT_COUNTER(.clk(clk),.reset(reset | reset_counters),.enb(abn_bit_seen),.Q(abn_bit_count));

    //correlators that tell if a bit is high or low consecutively
    correlator #(.PATTERN(16'hFFFF),.RST_PAT(16'h0000)) U_CORREL_ABN_HIGH(.clk(clk),.reset(reset|bit_seen),.enb(sample),.d_in(rxd),.h_out(consec_high));
    correlator #(.PATTERN(16'h0000),.RST_PAT(16'hFFFF)) U_CORREL_ABN_LOW(.clk(clk),.reset(reset | error),.enb(sample),.d_in(rxd),.h_out(consec_low));
    correlator #(.PATTERN(32'hFFFFFFFF),.LEN(32),.HTHRESH(26)) U_CORREL_EOF(.clk(clk),.reset(reset|bit_seen),.enb(sample),.d_in(rxd),.write(eof_seen));

    assign abn_bit_seen = (consec_high | consec_low) & samp_gt_16;
    logic preamble_detected;
    receive_fsm U_RECEIVE_FSM(.clk(clk),.reset(reset),.count_8(byte_count),.bit_count(abn_bit_count),.eof_seen(eof_seen),.preamble_detected(preamble_detected),
                            .error_condition(abn_bit_seen),.consec_low(consec_low & abn_bit_seen),.start_receiving(start_receive_pulse),
                            .error(error),.write(write),.eof(eof),.reset_counters(reset_counters));
                            
                            
    
    //==========================================================================Shift registers and FSM for pre-receive stages
    logic   sfd_detected,corroborating,preamble_bits_detected;
    logic [$clog2(NUM_SAMPLES*2):0] samp_count_pre_receive;
    logic [7:0] data_rxd;

    logic start_receiving;
    
    bcdcounter #(.LAST_VAL(NUM_SAMPLES*2)) U_SAMP_COUNTER_PRE(.clk(clk),.reset(reset|bit_seen),.enb(sample),.Q(samp_count_pre_receive));
    
    logic samp_num_24;
    assign samp_num_24 = samp_count_pre_receive>23;
    logic samp_num_31;
    assign samp_num_31 = samp_count_pre_receive>30;
    
    //shift register for the preamble
    preamble_detector_shreg U_PRE_SHREG(.clk(clk),.reset(reset | eof | (samp_num_24 & (!cardet | !start_receiving)) ),.write_0(write_zero),.write_1(write_one),.preamble_detected(preamble_detected));

    sfd_correl #(.PATTERN(128'h00FFFF0000FFFF0000FFFF0000FFFF00),.RST_PAT(128'd0),.LEN(128),.HTHRESH(104),.LTHRESH(24)) U_CORREL_PRE(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.h_out(preamble_bits_detected));

    //shift register to check for the sfd
    logic sfd_bits_detected;
    sfd_detector_shreg U_SFD_SHREG(.clk(clk),.reset(reset | (!cardet) | ( samp_num_31 )),.write_0(write_zero),.write_1(write_one),.cardet((preamble_detected && preamble_bits_detected)  | corroborating | cardet),.corroborating(corroborating),.sfd_detected(sfd_bits_detected));
   //correlators that tell if a bit is high or low consecutively
    sfd_correl #(.PATTERN(128'h00FF00FF00FF00FFFF0000FFFF00FF00),.RST_PAT(128'd0),.LEN(128),.HTHRESH(104),.LTHRESH(24)) U_CORREL_SFD(.clk(clk),.reset(reset),.enb(sample),.d_in(rxd),.h_out(sfd_detected));
    //register to store the received data
    data_shreg U_DATA_REG(.clk(clk),.reset(reset),.write_0(write_zero),.write_1(write_one),.sfd_detected(sfd_detected),.data_out(data_rxd),.start_receive(start_receive_pulse));
    
    //fsm for the pre_receive stage
    sfd_fsm U_SFD_FSM(.clk(clk),.reset(reset),.preamble_detected(preamble_detected && preamble_bits_detected),.corroborating(corroborating),.sfd_detected(sfd_detected && sfd_bits_detected ),
                    .eof(eof),.error(error),.cardet(cardet),.start_receiving(start_receiving));
    
    //converts start receiving output to a single pulse 
    single_pulser U_STRT_RECEIVE_PULSE(.clk(clk),.din(start_receiving),.d_pulse(start_receive_pulse));
    
    assign SFD = start_receiving;
    
    assign data = data_rxd;


endmodule
