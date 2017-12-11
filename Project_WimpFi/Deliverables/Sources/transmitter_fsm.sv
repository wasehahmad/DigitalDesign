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
    output logic last_ready,
    output logic txen,
    output logic txd
    );
    parameter D = 8;
    parameter N = 4;
    parameter WAIT_BITS = 2;
    
    logic [3:0] max_count;
    //logic last_ready;
    assign max_count = 8;
    logic rdy;
    logic prev_txd;
    logic n_txen;
    
    typedef enum logic[3:0] {
        IDLE=4'd0, START=4'd1, DATA_HIGH_FIRST=4'd2, DATA_LOW_FIRST=4'd3, DATA_HIGH_SECOND=4'd4, DATA_LOW_SECOND=4'd5,
        ENDED = 4'd6,END_BIT_1 = 4'd7,END_BIT_2 = 4'd8 
    } states_t;
    
    states_t state, next, last, next_last;
    
    always_ff @(posedge clk) begin
        if (reset) begin 
            state <= IDLE;
            prev_txd<=1;
            txen <= 0;
            
        end
        else begin
            state <= next;
            last <= next_last;
            last_ready <= rdy;
            prev_txd<=txd;
            txen<=n_txen;
        end
    end
    
    always_comb begin
        sending = 1'b0;
        one_bit_sending = 1'b0;
        rdy = 1'b1; 
        txd = 1'b1;
        n_txen = 1'b0;
        next = IDLE;
        reset_counter = 0;
        next_last = ENDED;
        waiting = 0;
        
        unique case (state)
        
            IDLE: begin
                next_last = ENDED;
                if (send)begin
                    sending = 1;
                    one_bit_sending = 1;
                    next = data[count]==0? DATA_LOW_FIRST : DATA_HIGH_FIRST;
                end
                else next = IDLE;
            end
                       
            DATA_LOW_FIRST:begin 
                
                one_bit_sending = 1;
                sending = 1;
                txd = 0;
                n_txen = 1;
                
                next = bit_count == 1 ? DATA_LOW_SECOND : DATA_LOW_FIRST;
                
                if(count == max_count-1)begin
                    rdy = 1;
                    next_last = send ? ((data[0] ==0)?DATA_LOW_FIRST:DATA_HIGH_FIRST) : next_last;
                end
                else begin
                    rdy = 0;
                end
                
            end
            
            DATA_HIGH_FIRST:begin
            
                one_bit_sending = 1;
                sending = 1;
                txd = 1;
                n_txen = 1;
                
                next = bit_count == 1 ? DATA_HIGH_SECOND : DATA_HIGH_FIRST;
                
                if(count == max_count-1)begin
                    rdy=1;
                    next_last = send ? ((data[0] ==0)? DATA_LOW_FIRST : DATA_HIGH_FIRST) : next_last;
                end
                else begin
                    rdy = 0;
                end
            end
            
            DATA_LOW_SECOND:begin
                sending = 1;
                one_bit_sending = 1;
                txd = 1;
                n_txen = 1;
                
                if(count == max_count)begin
                    rdy=1;
                    next = last;    
                    reset_counter = 1;            
                    
//                    if(bit_count == 0) begin
//                        next = data[count]== 0? last:DATA_LOW_SECOND ;//check timing here to see if last has changed or not
//                    end
                end
//                else if(count == max_count -1)begin
//                    rdy = last_ready; //take previous value of ready. will only be high if previous state had it high
//                end
                else begin //read data and see where to go next
                    rdy = last_ready; 
                    next_last = send ? (END_BIT_1) : next_last;
                    if(bit_count == 0) begin
                        next = END_BIT_1;
                    end
                    else next = DATA_LOW_SECOND;
                end
            end
            
            DATA_HIGH_SECOND:begin
                sending = 1;
                one_bit_sending = 1;
                txd = 0;
                n_txen = 1;
                
                if(count == max_count)begin
                    rdy=1;                    
                    next = last ;
                    reset_counter = 1;
//                    if(bit_count == 0) begin
//                        next = data[count]== 0? last:DATA_HIGH_SECOND ;//check timing here to see if last has changed or not
//                    end
                end
//                else if(count == max_count -1)begin
//                    rdy = last_ready; //take previous value of ready. will only be high if previous state had it high
//                end
                else begin //read data and see where to go next
                    rdy = last_ready; 
                    next_last = send ? (END_BIT_1) : next_last;
                    if(bit_count == 0) begin
                        next = END_BIT_1;
                    end
                    else next = DATA_HIGH_SECOND;
                end
            end
            
            END_BIT_1:begin
                txd=prev_txd;
                rdy = 0;
                n_txen = 1;
                next = END_BIT_2;
            end
            END_BIT_2:begin
                txd = prev_txd;
                n_txen = 1;
                rdy = 0;
                next = data[count]==0?DATA_LOW_FIRST:DATA_HIGH_FIRST;
            end
            
            ENDED:begin
                
                n_txen =1 ;
                waiting = 1;
                one_bit_sending = 1;
                rdy = 1;
                if(wait_counter == WAIT_BITS*2)   next = IDLE;
                else                              next = ENDED;

            end 
            
        endcase
    end

    
endmodule
