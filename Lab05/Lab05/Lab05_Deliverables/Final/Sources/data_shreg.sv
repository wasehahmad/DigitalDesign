`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2017 09:36:17 AM
// Design Name: 
// Module Name: preamble_detector_shift_register
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


module data_shreg(
    input logic clk,
    input logic reset,
    input logic write_0,
    input logic write_1,
    input logic sfd_detected,
    output logic [7:0] data_out
    );
    
    logic [7:0] shreg;
    assign data_out = shreg;
    
    // shift register shifts from right to left so that oldest data is on
    // the left and newest data is on the right
    always_ff  @(posedge clk) begin
        if (reset | !sfd_detected) begin
            shreg <= '0;
        end
        else if (write_0 || write_1) begin
            //shift the new bit into the shift register
            shreg <= { write_0?1'b0:1'b1,shreg[7:1]};
        end
        else shreg <= shreg;
    end  
endmodule