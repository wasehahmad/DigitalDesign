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


module man_receiver #(parameter DATA_WIDTH = 8,NUM_SAMPLES = 16, PHASE_WIDTH = $clog2(NUM_SAMPLES)+1, BAUD = 50000)(
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
    logic [PHASE_WIDTH-1:0] num_samples;
    assign bit_seen = write_one | write_zero;
    

    
    

    //==========================================================================Synchronizer and correlators for bit detection
    //sampler that varies frequency of sampling based on input
    variable_sampler #(.BAUD(BAUD),.SAMPLE_FREQ(16)) U_SAMPLER(.clk(clk),.reset(reset), .speed_up(speed_up),.slow_down(slow_down),
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
    correlator #(.PATTERN(32'hFFFFFFFF),.LEN(32)) U_CORREL_EOF(.clk(clk),.reset(reset|bit_seen),.enb(sample),.d_in(rxd),.write(eof_seen));

    assign abn_bit_seen = (consec_high | consec_low) & samp_gt_16;
    
    receive_fsm U_RECEIVE_FSM(.clk(clk),.reset(reset),.count_8(byte_count),.bit_count(abn_bit_count),.eof_seen(eof_seen),
                            .error_condition(abn_bit_seen),.consec_low(consec_low & abn_bit_seen),.start_receiving(start_receive_pulse),
                            .error(error),.write(write),.eof(eof),.reset_counters(reset_counters));
                            
                            
    
    //==========================================================================Shift registers and FSM for pre-receive stages
    logic   sfd_detected,corroborating;
    logic [7:0] data_rxd;
    logic preamble_detected;
    logic start_receiving;
    
    
    //shift register for the preamble
    preamble_detector_shreg U_PRE_SHREG(.clk(clk),.reset(reset),.write_0(write_zero),.write_1(write_one),.preamble_detected(preamble_detected));
    
    //shift register to check for the sfd
    sfd_detector_shreg U_SFD_SHREG(.clk(clk),.reset(reset),.write_0(write_zero),.write_1(write_one),.cardet(preamble_detected | corroborating | cardet),.sfd_detected(sfd_detected),.corroborating(corroborating));
    
    //register to store the received data
    data_shreg U_DATA_REG(.clk(clk),.reset(reset),.write_0(write_zero),.write_1(write_one),.sfd_detected(sfd_detected),.data_out(data_rxd));
    
    //fsm for the pre_receive stage
    sfd_fsm U_SFD_FSM(.clk(clk),.reset(reset),.preamble_detected(preamble_detected),.corroborating(corroborating),.sfd_detected(sfd_detected),
                    .eof(eof),.error(error),.cardet(cardet),.start_receiving(start_receiving));
    
    //converts start receiving output to a single pulse 
    single_pulser U_STRT_RECEIVE_PULSE(.clk(clk),.din(start_receiving),.d_pulse(start_receive_pulse));
    
    
    
    always_ff @(posedge clk) begin
        if(reset)data <= 8'hxx;
        else if(write)data<=data_rxd;
    
    end


endmodule
