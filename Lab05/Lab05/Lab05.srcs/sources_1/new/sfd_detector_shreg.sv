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
    parameter sfd = 8'b11010000;
    
    logic [7:0] shreg;
    logic [3:0] counter;
    logic half_sfd_seen;
      
    // shift register shifts from right to left so that oldest data is on
    // the left and newest data is on the right
    always_ff  @(posedge clk) begin
        if (reset) begin
//            shreg <= '0;
            counter <= '0;
            corroborating <= 0;
            half_sfd_seen <= 0;
            sfd_detected <= 0;
        end
        else if (write_0 || write_1) begin
            //shift the new bit into the shift register
           
            
            //increment the counter when cardet goes high
            if (cardet) begin
                if (sfd[counter] == shreg[0]) begin
                    counter <= counter + 1;
                    corroborating <= 1;                        
                end
                else if (counter == 4 && shreg[0] == 0 && half_sfd_seen == 0) begin
                    corroborating <= 1;
                    half_sfd_seen <= 1;
                end
                else if (counter == 1 && shreg[0]==1) begin
                    counter <= '0;
                    corroborating <= 0;
                    half_sfd_seen <= 0;
                end
                else begin
                    corroborating <= 0;
                    counter <= '0;
                    half_sfd_seen <= 0;
                end
            end
        end
        
        //LATCH HERE
        if (counter == 8) begin
            sfd_detected <= 1;                    
        end
    end  
    
    always_comb begin
        if (write_0 || write_1) begin
            shreg = { shreg[6:0], write_0?1'b0:1'b1 };
        end
        else shreg = shreg;
    end

endmodule