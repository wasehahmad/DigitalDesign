`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2017 09:08:09 PM
// Design Name: 
// Module Name: bcdcounter_txd
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


module bcdcounter_txd(
        input logic        clk, reset, enb,
        output logic [3:0] Q,
        output logic       carry
        );
  parameter COUNT_CEILING = 10;
 assign     carry = (Q == COUNT_CEILING-1) & enb;
 
 always_ff @( posedge clk )
   begin
  if (reset) Q <= 0;
  else if (enb) 
    begin
       if (carry) Q <= 0;
       else Q <= Q + 1;
    end
   end
endmodule
