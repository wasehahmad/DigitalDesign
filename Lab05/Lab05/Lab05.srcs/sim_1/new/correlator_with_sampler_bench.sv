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


module correlator_with_sampler_bench;
    parameter BAUD = 50000;
    parameter NUM_SAMP = 16;
    parameter SAMP_WIDTH = $clog2(NUM_SAMP);
    parameter WAIT_TIME = 100000000/(BAUD*NUM_SAMP);


    logic clk;
    logic reset;
    logic enb;
    logic rxd;
    logic h_out_z,h_out_o;
    logic [SAMP_WIDTH:0]phase_diff;
    logic speed_up;
    logic slow_down;
    logic [SAMP_WIDTH:0] csum_0,csum_1;
    logic write_1,write_0;
    
    parameter ERROR_RATE = 10; // % prob. of error
    logic noise_error, rxd_noisy;
    always @(posedge clk) begin
       #1; // inject error (if any) after clock edge
       if ($urandom_range(100,1) <= ERROR_RATE) noise_error = 1;
       else noise_error = 0;
    end
    assign rxd_noisy = rxd ^ noise_error;
    


    logic samp_clk;
    //sampler that varies frequency of sampling based on input
    variable_sampler #(.BAUD(BAUD),.SAMPLE_FREQ(NUM_SAMP)) U_SAMPLER(.clk(clk),.reset(reset), .speed_up(speed_up),.slow_down(slow_down),
                                                              .diff_amt(phase_diff),.enb(samp_clk));    
    
    logic d_out;
    jittergen U_JIT_GEN(.clk(clk),.sampclk(samp_clk),.din(rxd),.dout(d_out));   
    
    
    synchronizer #(.NUM_SAMP(NUM_SAMP)) U_SYNC(.clk(clk),.reset(reset),.bit_seen(write_0 | write_1),
                                                   .count_enb(samp_clk),.slow_down(slow_down),.speed_up(speed_up),.phase_diff(phase_diff));
    
    

    
    //correlator to store the input values
    correlator #(.PATTERN(16'h00FF)) U_CORREL_ZERO(.clk(clk),.reset(reset),.enb(enb && samp_clk),.d_in(d_out),.h_out(h_out_z),.write(write_0),
                                                       .csum(csum_0));

    correlator #(.PATTERN(16'hFF00)) U_CORREL_ONE(.clk(clk),.reset(reset),.enb(enb && samp_clk),.d_in(d_out),.h_out(h_out_o),.write(write_1),
                                                       .csum(csum_1));
                                                       

                                                       
                                                       
    
                                                       
                                                       
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
        enb = 0;
        repeat(30)@(posedge clk);
        #1;
        reset = 0;
        enb = 1;
        //repeat(1000)@(posedge clk);
        for(i =0; i< 256;i ++)begin
            send_0;
            send_1;
        end
        $stop;


    
    
    end
    
    


endmodule
