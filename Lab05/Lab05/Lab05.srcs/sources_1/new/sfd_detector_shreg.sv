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


module sfd_detector_shreg(
    input logic clk,
    input logic reset,
    input logic write_0,
    input logic write_1,
    input logic cardet,
    output logic sfd_detected,
    output logic corroborating
    );
    
    logic [7:0] shreg, it_matches;
      
    // shift register shifts from right to left so that oldest data is on
    // the left and newest data is on the right
    always_ff  @(posedge clk) begin
        if (reset) begin
            shreg <= '0;
            it_matches <= '0;
            sfd_detected <= 0;
            corroborating <= 0;
        end
        else if (cardet && write_0) begin
            //shift the new bit into the shift register
            shreg <= { shreg[6:0], 1'b0 };
            
            //check if shreg has a preamble
            it_matches <= shreg ^~ 8'b10101010;
            if (it_matches == 8'b00000000) begin
                sfd_detected <= 1;
            end
            if (it_matches == 8'b11111111) begin
                sfd_detected <= 1;
            end
            else begin
                sfd_detected <= 0;
            end
        end
        else if (cardet && write_1) begin
            //shift the new bit into the shift register
            shreg <= { shreg[6:0], 1'b1 };
            
            //check if shreg has a preamble
            it_matches <= shreg ^~ 8'b10101010;
            if (it_matches == 8'b00000000) begin
                sfd_detected <= 1;
            end
            if (it_matches == 8'b11111111) begin
                sfd_detected <= 1;
            end
            else begin
                sfd_detected <= 0;
            end
        end
    end    
endmodule