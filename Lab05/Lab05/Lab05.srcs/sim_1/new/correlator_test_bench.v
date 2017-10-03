`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2017 12:57:44 PM
// Design Name: 
// Module Name: correlator_test_bench
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


module correlator_test_bench;

            
    parameter ERROR_RATE = 10; // % prob. of error
    logic noise_error, d_in_noisy;
    always @(posedge clk) begin
        #1; // inject error (if any) after clock edge
        if ($urandom_range(100,1) <= ERROR_RATE) noise_error = 1;
        else noise_error = 0;
    end
    assign d_in_noisy = d_in ^ noise_error;

    

    logic jtr_clk;
    logic clk;
    logic samp_clk;
    logic reset;
    logic enb;
    logic d_in;
    logic [4:0] csum_0;
    logic h_out_0,l_out_0;
    logic [4:0] csum_1;
    logic h_out_1,l_out_1;    
    
    jitteryclock J_CLOCK(.clk(jtr_clk));
    
    //one tenth of the clock frequency is the sample rate
    clkenb #(.DIVFREQ(10000000)) U_SAMPLE_CLOCK(.clk(clk),.reset(reset),.enb(samp_clk));
    
    
//    logic d_out;
//    jittergen U_JIT_GEN(.clk(clk),.sampclk(samp_clk),.din(d_in_noisy),.dout(d_out));
    


    correlator #(.PATTERN(16'b0000000011111111)) DUV_0(.clk(clk),.reset(reset),.enb(enb),.d_in(d_in_noisy),.csum(csum_0),.h_out(h_out_0),.l_out(l_out_0));
    correlator #(.PATTERN(16'b1111111100000000)) DUV_1(.clk(clk),.reset(reset),.enb(enb),.d_in(d_in_noisy),.csum(csum_1),.h_out(h_out_1),.l_out(l_out_1));
    
    task send_0;
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
     
    endtask
    
    
    task send_1;
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 1;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
        d_in = 0;
        repeat(10)@(posedge jtr_clk);
         
    endtask
    
    
    // clock generator
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end

    initial begin
        integer i;
        d_in =1;
        reset = 1;
        enb = 0;
        repeat(30)@(posedge clk);
        #1;
        reset = 0;
        enb = 1;
        repeat(1000)@(posedge clk);
        for(i =0; i< 16;i ++)begin
            send_0;
            send_1;
        end

    
    end



endmodule
