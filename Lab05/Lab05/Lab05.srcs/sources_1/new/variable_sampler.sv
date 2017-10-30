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
    INCR_AMT = BAUD/10, //rate at which single error accumulates
    ACC_BOUND = BAUD,
    ACC_LW_BOUND = -1*ACC_BOUND
    )
    (
    input logic clk,
    input logic reset,
    input logic speed_up,
    input logic slow_down,
    input logic [4:0] diff_amt,
    output logic enb
    );
    
    logic changed,prevChanged;
     
    int actualClkFreq,n_actualClkFreq;
    int accumulated;
    logic initialized,n_initialized;  
    int DIVAMT,n_DIVAMT;

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
        if(reset) begin
            accumulated <=0;
            changed<=0;
            initialized <=0;
        end
        else begin
            initialized<=n_initialized;
            
            if((accumulated>ACC_BOUND && !slow_down) || ((accumulated<ACC_LW_BOUND)&&(!speed_up)))begin
                accumulated <= accumulated;//dont go past the bounds
                changed<=0;
            end
            else if((speed_up || slow_down) & !changed )begin
                if(speed_up)accumulated <=accumulated+diff_amt*INCR_AMT;
                else if(slow_down)accumulated <=accumulated-diff_amt*INCR_AMT;
                changed<=1;
            end
            else begin
                accumulated <=accumulated;
                changed<=0;
            end
        end
    
    end
    


//    always_ff @(posedge clk) begin
//        if(reset)begin
//            n_initialized <= initialized;
//            actualClkFreq <= SAMPLE_RATE;
//            DIVAMT <= (CLKFREQ / actualClkFreq);
//        end
//            else begin
//            DIVAMT <= n_DIVAMT;
//            actualClkFreq <= n_actualClkFreq;

            
//        end

//    end
    
//    assign n_DIVAMT = (CLKFREQ / actualClkFreq);   
    
//    always_comb begin
//        n_actualClkFreq = actualClkFreq;
//        if(changed)n_actualClkFreq <= SAMPLE_RATE+accumulated; 
//    end 
    
    always_comb begin
        if(reset)begin
            n_initialized = initialized;
            actualClkFreq = SAMPLE_RATE;
        end
        if(changed)begin
            actualClkFreq = SAMPLE_RATE+accumulated;
        end
        else begin
            if(initialized)
                actualClkFreq = actualClkFreq;
            else begin
                actualClkFreq = SAMPLE_RATE;
                n_initialized = 1;
            end
        end
    
    end
    
endmodule