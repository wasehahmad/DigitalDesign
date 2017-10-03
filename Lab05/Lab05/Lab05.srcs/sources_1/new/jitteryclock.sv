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


module jitteryclock(
    output clk
    );
    
    parameter PERIOD = 10; // ns
    parameter JITTER = 200; // ps
    parameter SEED = 1234;
    
    integer seed=SEED;
    logic q=0;
    
    always #( (PERIOD/2) + $dist_uniform(seed,-JITTER,JITTER)/1000.0) q=~q;  // jittery clock
    
    assign clk=q;
    
endmodule
