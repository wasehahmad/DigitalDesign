`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad and Geoff Watson
// 
// Create Date: 09/19/2017 08:25:45 AM
// Design Name: 
// Module Name: receiver_fsm
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


module receiver_fsm(
    input logic clk,
    input logic baud16_clk,
    input logic reset,
    input logic rxd,
    output logic rdy,
    output logic ferr,
    output logic [7:0] data,
    output logic restart_16_clk
    );
    
    
    logic [7:0] temp_data;
    logic [7:0] clear_bit;
    logic [4:0] count, ncount;
    logic [3:0] bit_count, n_bit_count;
    logic data_en;
    
    typedef enum logic[2:0] {
            IDLE=3'd0, SPUR_CHK=3'd1, RECEIVING=3'd2,  FERR_CHK=3'd3, FERR_SEEN=3'd4, START = 3'd5
        } states_t;
        
        states_t state, next, start_state,n_start_state;
        
        always_ff @(posedge clk) begin
            if (reset) begin 
                start_state <=START;
                state <= START;
                count <= 0;
                bit_count <= 0;
                data <=8'b11111111;
                
            end
            else begin
                start_state <= n_start_state;
                state <= next;
                count <= ncount;
                bit_count <= n_bit_count;
                data <= data_en ? {rxd,data[7:1]} : data;
            end
        end
        
        always_comb begin
            //defaults
            rdy = 1;
            ferr = 0;
            ncount = count;
            n_bit_count = bit_count;
            restart_16_clk = 0;
            temp_data = 0;
            data_en = 0;
            n_start_state = IDLE;


            
            unique case (state)
                START: begin
                    n_start_state = START;
                    rdy = 0; 
                    if (rxd == 0) begin 
                       next = SPUR_CHK;
                       restart_16_clk = 1;
                    end
                    else next = START;
                end
                
            
                IDLE: begin
                    if (rxd == 0) begin 
                        next = SPUR_CHK;
                        restart_16_clk = 1;
                    end
                    else next = IDLE;
                end
                
                SPUR_CHK: begin
                    if (baud16_clk) ncount = count + 1;
                    if(start_state == START)n_start_state = START;
                    
                    if (count == 8) begin
                        ncount = 0;
                        n_bit_count = 0;
                        restart_16_clk = 1;
                        if (rxd == 0) next = RECEIVING;
                        else if(start_state == START)next = START;
                        else next = IDLE;
                    end
                    else next = SPUR_CHK;
                end
                
                RECEIVING: begin
                    rdy=0;
                    if (baud16_clk) ncount = count + 1;
                    if (count == 16) begin
                        ncount = 0;
                        n_bit_count = bit_count + 1;
                        restart_16_clk = 1;
                        data_en = 1;
//                        temp_data[bit_count] = rxd;
//                        clear_bit[bit_count] = 1;
                    end
                    if (bit_count == 8) next = FERR_CHK;
                    else next = RECEIVING;
                end
                
                FERR_CHK: begin
                    rdy = 0;
                    if (baud16_clk) ncount = count + 1;
                    if (count == 16) begin
                        ncount = 0;
                        restart_16_clk = 1;
                        
                        if (rxd == 0) next = FERR_SEEN;
                        else  next = IDLE;
                    end
                end
                
                FERR_SEEN: begin
                    rdy = 0;
                    ferr = 1;
                    if (rxd == 0)next = FERR_SEEN;
                    else next = IDLE;
                end
                
            endcase
        end
endmodule
