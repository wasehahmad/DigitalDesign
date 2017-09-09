//-----------------------------------------------------------------------------
// Title         : transmitter_fsm
// Project       : Lab 2
//-----------------------------------------------------------------------------
// File          : transmitter_fsm.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 9/05/2017
//-----------------------------------------------------------------------------
// Description :
// This module provides a finite state machine to transmit data serially.
//-----------------------------------------------------------------------------


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
    
    typedef enum logic[1:0] {
        IDLE=2'd0, TRANSMITTING=2'd1, ENDED = 2'd2 
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
            IDLE: begin
                if (send) next = TRANSMITTING;
                else next = IDLE;
            end
            TRANSMITTING: begin
                rdy = 0;
                if(count == 0)begin
                    txd = 0;//start signal
                    next = TRANSMITTING;
                end
                else if (count == 4'd9)begin
                    txd = 1;
                    next = ENDED;
                end
                else begin
                    txd = data[count-1]; 
                    next = TRANSMITTING;
                end               
            end
            ENDED:begin
                rdy = 0;
                if(count ==0)next = IDLE;
                else next = ENDED;
            
            end 
            
        endcase
    end
endmodule
