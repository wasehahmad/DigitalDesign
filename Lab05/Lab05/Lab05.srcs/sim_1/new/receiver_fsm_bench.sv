`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2017 02:22:52 PM
// Design Name: 
// Module Name: correlator_with_sampler_bench
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


module receiver_fsm_benc;
    parameter BAUD = 50000;
    parameter TXD_BAUD = 50000;
    parameter NUM_SAMP = 16;
    parameter SAMP_WIDTH = $clog2(NUM_SAMP);
    parameter WAIT_TIME = 100_000_000/(TXD_BAUD*NUM_SAMP);
    parameter NUM_SAMPLES = 16;


    logic clk;
    logic reset;
    logic rxd;


    logic samp_clk;
    //sampler that varies frequency of sampling based on input
    variable_sampler #(.BAUD(BAUD),.SAMPLE_FREQ(NUM_SAMP)) U_SAMPLER(.clk(clk),.reset(reset), .speed_up(0),.slow_down(0),
                                                              .diff_amt(0),.enb(samp_clk));    
                                                  
    logic start_receive;
    logic reset_counters;
    logic [3:0] byte_count;
    logic [1:0] abn_bit_count;
    logic abn_bit_seen;
    logic [$clog2(NUM_SAMPLES*2):0] samp_count;
    logic consec_high,consec_low;
    logic bit_seen;
    logic eof_seen;
    
    
    
    
    //counter to count number of bits seen for the byte
    bcdcounter #(.LAST_VAL(9),.W(4)) U_BYTE_COUNTER(.clk(clk),.reset(reset | reset_counters),.enb(bit_seen),.Q(byte_count));
    
    //counter for number of samples
    bcdcounter #(.LAST_VAL(NUM_SAMPLES*2)) U_SAMP_COUNTER(.clk(clk),.reset(reset|bit_seen|abn_bit_seen),.enb(samp_clk),.Q(samp_count));
    
    //num of samples since last bit>16
    logic samp_gt_16;
    assign samp_gt_16 = samp_count>16;
    
    //counter for number of abnormal bits i.e. consecutive highs or lows
    bcdcounter #(.LAST_VAL(2)) U_ABN_BIT_COUNTER(.clk(clk),.reset(reset | reset_counters),.enb(abn_bit_seen),.Q(abn_bit_count));
    
    //correlators that tell if a bit is high or low consecutively
    correlator #(.PATTERN(16'hFFFF)) U_CORREL_ABN_HIGH(.clk(clk),.reset(reset),.enb(samp_clk),.d_in(rxd),.write(consec_high));
    correlator #(.PATTERN(16'h0000)) U_CORREL_ABN_LOW(.clk(clk),.reset(reset),.enb(samp_clk),.d_in(rxd),.write(consec_low));
    correlator #(.PATTERN(32'hFFFFFFFF),.LEN(32)) U_CORREL_EOF(.clk(clk),.reset(reset),.enb(samp_clk),.d_in(rxd),.write(eof_seen));
    
    assign abn_bit_seen = (consec_high | consec_low) & samp_gt_16;
    
    receive_fsm U_RECEIVE_FSM(.clk(clk),.reset(reset),.count_8(byte_count),.bit_count(abn_bit_count),.eof_seen(eof_seen),
                           .error_condition(abn_bit_seen),.consec_low(consec_low & abn_bit_seen),.start_receiving(start_receive),
                           .error(error),.write(write),.eof(eof),.reset_counters(reset_counters));
                                                       
                                                       
    
                                                       
                                                       
    task send_0;
        integer i;
        for(i=0;i<8;i++)begin
            rxd = 0;
            repeat(WAIT_TIME)@(posedge clk);
        end
        for(i=0;i<8;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
        
    endtask
    task send_1;
        integer i;
        for(i=0;i<8;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
        for(i=0;i<8;i++)begin
            rxd = 0;
            repeat(WAIT_TIME)@(posedge clk);
        end
            
    endtask
    
    task send_high;
        integer i;
        for(i=0;i<16;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
    
    endtask
    
    task send_low;
        integer i;
        for(i=0;i<16;i++)begin
            rxd = 0;
            repeat(WAIT_TIME)@(posedge clk);
        end
        
    endtask
    
    task send_bit;
        @(posedge clk) #1;
        bit_seen = 1;
        @(posedge clk) #1;
        bit_seen = 0;
        //wait 16 samp numbers
        repeat(16*WAIT_TIME)@(posedge clk);

    
    endtask
    
    
    
    
    // clock generator
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end
    
    initial begin
        integer i;
        rxd = 0;
        reset = 1;
        repeat(30)@(posedge clk);
        #1;
        reset = 0;
        repeat(100000)@(posedge clk);
        repeat(1000)@(posedge clk);
        start_receive = 1;
        for(i =0; i< 256;i ++)begin
            send_bit;
        end            
        start_receive = 0;         
        send_high;
        send_high;
        
        rxd = 1;
        reset = 1;
        repeat(30)@(posedge clk);
        #1;
        reset = 0;
        repeat(100000)@(posedge clk);
        repeat(1000)@(posedge clk);
        start_receive = 1;
        for(i =0; i< 256;i ++)begin
            send_bit;
        end
        start_receive = 0;
        send_low;
        
        rxd = 1;
        reset = 1;
        repeat(30)@(posedge clk);
        #1;
        reset = 0;
        repeat(100000)@(posedge clk);
        repeat(1000)@(posedge clk);
        start_receive = 1;
        for(i =0; i< 250;i ++)begin
            send_bit;
        end
        start_receive = 0;
        send_low;
        
        rxd = 0;
        reset = 1;
        repeat(30)@(posedge clk);
        #1;
        reset = 0;
        repeat(100000)@(posedge clk);
        repeat(1000)@(posedge clk);
        start_receive = 1;
        for(i =0; i< 250;i ++)begin
            send_bit;
        end            
        start_receive = 0;         
        send_high;
        $stop;


    
    
    end
    
    


endmodule
