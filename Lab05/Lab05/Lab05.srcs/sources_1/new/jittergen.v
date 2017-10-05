`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2017 02:10:56 PM
// Design Name: 
// Module Name: jittergen
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


module jittergen(
    input clk,
    input sampclk,
    input din,
    output logic dout
    );
    
    parameter SHIFTRANGE=3;
    parameter SEED=2312;
    
    logic [SHIFTRANGE-1:0] shiftreg;
    integer index=0;
    integer seed=SEED;
    integer j=0; // random number between -1 and +1 used to increment index. 
    
   // Data shift register 
   always_ff @(posedge clk) begin
      if(sampclk) begin
        shiftreg <= { shiftreg[SHIFTRANGE-2:0], din };
      end
    end
   
   // Random take-off (index) from shift register yielding dout
   // with varying delay. Takeoff can only vary 1 sampclk each time
   // Takeoff does not "wrap around".
   always_ff @(posedge clk) begin
     if(sampclk) begin
       j<=$dist_uniform(seed,-1,1);
       if((index==0 && j>=0) || 
          (index==(SHIFTRANGE-1) && j<=0) ||
          (index>0 && index<(SHIFTRANGE-1))
          ) index<=index+j;
       dout <= shiftreg[index];
       end
     end
    
    
    
endmodule
