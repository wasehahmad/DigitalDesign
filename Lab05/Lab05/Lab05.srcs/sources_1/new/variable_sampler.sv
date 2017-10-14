`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2017 04:57:28 PM
// Design Name: 
// Module Name: variable_sampler
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


module variable_sampler
    #(
    parameter CLKFREQ = 100_000_000,
    BAUD = 50000,  //BAUD rate 
    SAMPLE_FREQ = 16,  
    SAMPLE_RATE = BAUD*SAMPLE_FREQ,//sample rate default 16*BAUD
    INCR_AMT = BAUD/10 //rate at which single error accumulates
    )
    (
    input logic clk,
    input logic reset,
    input logic speed_up,
    input logic slow_down,
    input logic [4:0] diff_amt,
    output logic enb
    );
    
    
     
    int actualClkFreq;
    int accumulated;
    assign actualClkFreq = SAMPLE_RATE+accumulated;
    
    int DIVAMT;
    assign DIVAMT = (CLKFREQ / actualClkFreq);
    int  q;
    
    always @(posedge clk) begin
        if (reset)begin
            q <= 0;
            enb <= 0;
        end
        else if (q == DIVAMT-1)begin
            q <= 0;
            enb <= 1;  // note it will be delayed by 1 clock, but so what?
        end
        else begin
            q <= q + 1;
            enb <= 0;
        end
    
    end 
    
    always_ff @(posedge clk)begin
        if(reset) accumulated <=0;
        else begin
            if(speed_up)accumulated <=accumulated+diff_amt*INCR_AMT;
            else if(slow_down)accumulated <=accumulated-diff_amt*INCR_AMT;
            else accumulated <=accumulated;
        
        end
    
    end
    
    
    
    
endmodule
