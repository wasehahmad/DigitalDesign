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


module preamble_detector_shreg(
    input logic clk,
    input logic reset,
    input logic write_0,
    input logic write_1,
    output logic preamble_detected
    );
    
    logic [7:0] shreg, it_matches;
    
    assign it_matches =   shreg ^~ 8'b10101010;
    
    // shift register shifts from right to left so that oldest data is on
    // the left and newest data is on the right
    always_ff  @(posedge clk) begin
        if (reset) begin
            shreg <= '0;
        end
        else if (write_0 || write_1) begin
            //shift the new bit into the shift register
            shreg <= { shreg[6:0], write_0?1'b0:1'b1 };
        end
    end  
    
    always_comb begin
        //check if shreg has a preamble
        if ((it_matches == 8'b00000000) || (it_matches == 8'b11111111)) begin
            preamble_detected = 1;
        end
        else begin
            preamble_detected = 0;
        end
    end


endmodule