`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 10/17/2017 09:54:51 AM
// Design Name: 
// Module Name: receive_fsm
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
// FSM of the receiving stage for the manchester receiver. This module is to be used when the SFD has been verified. It is used 
// in conjunction with two other counters and a correlator
//////////////////////////////////////////////////////////////////////////////////


module receive_fsm #(parameter BITS_IN_BYTE = 8)(
    input logic clk,
    input logic reset,
    input logic [3:0] count_8,
    input logic [1:0] bit_count,
    input logic error_condition,
    input logic consec_low,
    input logic start_receiving,
    input logic eof_seen,
    input logic preamble_detected,
    output logic error,
    output logic eof,
    output logic write,
    output logic reset_counters
    );
    
    logic n_eof,n_write,n_reset_counters,n_error;
    logic one_byte_seen,n_one_byte_seen;
    
    typedef enum logic [1:0]{
        IDLE = 2'd0,RECEIVING = 2'd1, ERROR_CHK = 2'd2
    } states_t;
    
    states_t state, next;
    
    
    always_ff @(posedge clk) begin
        if(reset)begin
            state <= IDLE;
            eof <= 0;
            write <= 0;
            error <= 0;
            reset_counters <= 0;
            one_byte_seen <= 0;
        end
        else begin
            state <= next;
            eof <= n_eof;
            write <= n_write;
            error <= n_error;
            reset_counters <= n_reset_counters;   
            one_byte_seen <= n_one_byte_seen;   
        end
    end
    
    
    always_comb begin
        next = IDLE;
        n_eof = 0;
        n_write = 0;
        n_reset_counters = 0;
        n_error = error;//latch from previous erro
        n_one_byte_seen = one_byte_seen; //latch
        
        unique case (state)
            IDLE: begin
                if(start_receiving)begin 
                    n_error = 0;
                    next = RECEIVING;   
                end
                else begin
                 if(preamble_detected)n_error = 0;
                    next = IDLE;    
                end
                n_reset_counters = 1;
            end
            
            RECEIVING: begin
                if(error_condition)begin
                    //if at least one byte has been seen and the stream is not in the middle of a byte
                    if(one_byte_seen && count_8 == 0 && !consec_low )next = ERROR_CHK;
                    //else it is an error (EOF too early or low bits)
                    else begin
                        n_error = 1;
                        next = IDLE;
                    end
                    
                end
                else begin
                    if(count_8== BITS_IN_BYTE)begin
                        n_one_byte_seen = 1;
                        n_write = 1;
                        n_reset_counters = 1;
                    end
                    else if(count_8 == 0)n_write = write;//latch the value till next bit
                    next = RECEIVING;
                end

            end
            
            ERROR_CHK: begin
                if(bit_count < 2)begin
                    if(consec_low)begin
                        n_error = 1;
                        next = IDLE;
                    end
                    else /*if(eof_seen)*/begin
                        n_eof = 1;
                        next = IDLE;
                    end
                    //else next = ERROR_CHK;
                end
                else begin
                    n_eof = 1;
                    next = IDLE;
                end
                   
            end
        
        endcase
        
    end
    
    
    
endmodule
