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
    output logic reset_counter,
    output logic rdy,
    output logic txen,
    output logic txd
    );
    parameter D = 8;
    parameter N = 4;
    parameter WAIT_BITS = 2;
    
    logic [3:0] max_count;
    assign max_count = 8;
    
    typedef enum logic[2:0] {
        IDLE=3'd0, START=3'd1, DATA_HIGH_FIRST=3'd2, DATA_LOW_FIRST=3'd3, DATA_HIGH_SECOND=3'd4, DATA_LOW_SECOND=3'd5, ENDED = 3'd6 
    } states_t;
    
    states_t state, next, last, next_last;
    
    always_ff @(posedge clk) begin
        if (reset) begin 
            state <= IDLE;
            
        end
        else begin
            state <= next;
            last <= next_last;
            
        end
    end
    
    always_comb begin
        sending = 1'b0;
        one_bit_sending = 1'b0;
        rdy = 1'b1; 
        txd = 1'b1;
        txen = 1'b0;
        next = IDLE;
        reset_counter = 0;
        
        unique case (state)
        
            IDLE: begin
                next_last = ENDED;
                if (send) next = START;
                else next = IDLE;
            end
            
            START: begin //transition to start sending the bits //dont come back to this state again //
                rdy = 0;
                txen = 1;
                if(data[count] == 0)begin
                    next = DATA_LOW_FIRST;
                end
                else begin
                    next = DATA_HIGH_FIRST;
                end
//                if(count == max_count)begin
//                    next = last;
//                    next_last = ENDED;
//                    reset_counter = 1;
//                end
//                else begin
//                    if(data[count] == 0)begin
//                        next = DATA_LOW_FIRST;
//                    end
//                    else begin
//                        next = DATA_HIGH_FIRST;
//                    end  
//                end
                
            end

            DATA_LOW_FIRST:begin 
                
                one_bit_sending = 1;
                sending = 1;
                txd = 0;
                txen = 1;
                
                next = bit_count == 1 ? DATA_LOW_SECOND : DATA_LOW_FIRST;
                
                if(count == max_count-1)begin
                    rdy = 1;
                    next_last = send ? START : next_last;
                end
                else begin
                    rdy = 0;
                end
                
            end
            
            DATA_HIGH_FIRST:begin
            
                one_bit_sending = 1;
                sending = 1;
                txd = 1;
                txen = 1;
                
                next = bit_count == 1 ? DATA_HIGH_SECOND : DATA_HIGH_FIRST;
                
                if(count == max_count-1)begin
                    rdy=1;
                    next_last = send ? START : next_last;
                end
                else begin
                    rdy = 0;
                end
            end
            
            DATA_LOW_SECOND:begin
                sending = 1;
                one_bit_sending = 1;
                txd = 1;
                txen = 1;
                
                if(count == max_count-1)begin
                    rdy=1;                    
                    next_last = send ? START : next_last;
                    if(bit_count == 0) begin
                        next = data[count]== 0? last:DATA_LOW_SECOND ;//check timing here to see if last has changed or not
                    end
                end
                else begin //read data and see where to go next
                    rdy = 0; 
                    if(bit_count == 0) begin
                        next = data[count]==0?DATA_LOW_FIRST:DATA_HIGH_FIRST;
                    end
                end
            end
            
            DATA_HIGH_SECOND:begin
                sending = 1;
                one_bit_sending = 1;
                txd = 0;
                txen = 1;
                
                if(count == max_count-1)begin
                    rdy=1;                    
                    next_last = send ? START : next_last;
                    if(bit_count == 0) begin
                        next = data[count]== 0? last:DATA_HIGH_SECOND ;//check timing here to see if last has changed or not
                    end
                end
                else begin //read data and see where to go next
                    rdy = 0; 
                    if(bit_count == 0) begin
                        next = data[count]==0?DATA_LOW_FIRST:DATA_HIGH_FIRST;
                    end
                end
            end
            
            ENDED:begin
            
                txen =1 ;
                waiting = 1;
                one_bit_sending = 1;
                rdy = 1;
                if(wait_counter == WAIT_BITS*2)   next = IDLE;
                else                              next = ENDED;

            end 
            
        endcase
    end

    
endmodule
