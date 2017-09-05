`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2017 08:23:44 AM
// Design Name: 
// Module Name: transmitter_fsm
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


module transmitter_fsm(
    input logic clk,
    input logic reset,
    input logic send,
    input logic [D-1:0] data,
    input logic [N-1:0] count,
    output logic rdy,
    output logic txd
    );
    parameter D = 8;
    parameter N = 4;
    
    typedef enum logic {
        IDLE=1'b0, TRANSMITTING=1'b1 
    } states_t;
    
    states_t state, next;
    
    always_ff @(posedge clk) begin
        if (reset) state <= IDLE;
        else state <= next;
    end
    
    always_comb begin
        rdy = 1'b1;
        txd = 1'b1;
        next = IDLE;
        unique case (state)
            IDLE:
                if (send) next = TRANSMITTING;
                else next = IDLE;
            TRANSMITTING: begin
                rdy = 0;
                if(count == 0)begin
                    txd = 0;//start signal
                    next = TRANSMITTING;
                end
                else if (count == 4'd9)begin
                    txd = 1;
                    next = IDLE;
                end
                else begin
                    txd = data[count-1]; 
                    next = TRANSMITTING;
                end               
            end
        endcase
    end
endmodule
