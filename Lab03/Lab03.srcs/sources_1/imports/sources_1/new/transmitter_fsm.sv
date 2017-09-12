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
    input logic [N-1:0] bit_count,
    input logic [N-1:0] wait_counter,
    output logic sending,
    output logic one_bit_sending,
    output logic waiting,
    output logic rdy,
    output logic txen,
    output logic txd
    );
    parameter D = 8;
    parameter N = 4;
    
    logic max_count;
    assign max_count = 8;
    
    typedef enum logic[2:0] {
        IDLE=3'd0, START=3'd1, DATA_HIGH_FIRST=3'd2, DATA_LOW_FIRST=3'd3, DATA_HIGH_SECOND=3'd4, DATA_LOW_SECOND=3'd5, ENDED = 3'd6 
    } states_t;
    
    states_t state, next, last;
    
    always_ff @(posedge clk) begin
        if (reset) begin 
            state <= IDLE;
            last <= START;//assume that next byte is sent immediately
        end
        else state <= next;
    end
    
    always_comb begin
        sending = 1'b0;
        one_bit_sending = 1'b0;
        rdy = 1'b1; 
        txd = 1'b1;
        txen = 1'b0;
        next = IDLE;
        
        unique case (state)
        
            IDLE: begin
                if (send) next = START;
                else next = IDLE;
            end
            
            START: begin
                sending = 1;
                rdy = 0;
                txen = 1;
                
                if(data[count] == 0)begin
                    next = DATA_LOW_FIRST;
                end
                else begin
                    next = DATA_HIGH_FIRST;
                end  
                
            end

            DATA_LOW_FIRST:begin
                
                sending = 1;
                txd = 0;
                txen = 1;
                one_bit_sending = 1;
                if(count ==max_count-1)begin
                    rdy=1;
                    last = send?START:ENDED;
                end
                else begin
                    rdy = 0;
                end
                next = bit_count == 1 ? DATA_LOW_SECOND : DATA_LOW_FIRST;
            end
            
            DATA_HIGH_FIRST:begin
                sending = 1;
                txd = 1;
                txen = 1;
                one_bit_sending = 1;
                if(count ==max_count-1)begin
                    rdy=1;
                    last = send?START:ENDED;
                end
                else begin
                    rdy = 0;
                end
                next = bit_count == 1 ? DATA_HIGH_SECOND : DATA_HIGH_FIRST;

            end
            
            DATA_LOW_SECOND:begin
                sending = 1;
                txd = 1;
                txen = 1;
                one_bit_sending = 1;
                if(count == max_count-1)begin
                    rdy=1;
                    last = (last == ENDED || send)?START:ENDED;
                    next = last;
                end
                else begin
                    rdy = 0; 
                    next = bit_count == 0 ? START : DATA_LOW_SECOND;
                end
            end
            
            DATA_HIGH_SECOND:begin
                sending = 1;
                txd = 0;
                txen = 1;
                one_bit_sending = 1;
                if(count == max_count-1)begin
                    rdy=1;
                    last = (last == ENDED || send)?START:ENDED;
                    next = last;
                end
                else begin
                    rdy = 0;
                    next = bit_count == 0 ? START : DATA_HIGH_SECOND;
                end
            end
            
            ENDED:begin
                waiting = 1;
                one_bit_sending = 1;
                rdy = 1;
                if(wait_counter == 4)   next = IDLE;
                else                    next = ENDED;

            end 
            
        endcase
    end

    
endmodule
