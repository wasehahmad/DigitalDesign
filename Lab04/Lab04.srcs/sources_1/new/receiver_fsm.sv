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
    logic [4:0] count, ncount;
    logic [3:0] bit_count, n_bit_count;
    
    typedef enum logic[2:0] {
            IDLE=3'd0, SPUR_CHK=3'd1, RECEIVING=3'd2,  FERR_CHK=3'd3, FERR_SEEN=3'd4
        } states_t;
        
        states_t state, next;
        
        always_ff @(posedge clk) begin
            if (reset) begin 
                state <= IDLE;
                count <= 0;
                bit_count <= 0;
            end
            else begin
                state <= next;
                count <= ncount;
                bit_count <= n_bit_count;
            end
        end
        
        always_comb begin
            //defaults
            rdy = 1;
            ferr = 0;
            ncount = count;
            n_bit_count = bit_count;
            restart_16_clk = 0;
            
            unique case (state)
            
                IDLE: begin
                    if (rxd == 0) begin 
                        next = SPUR_CHK;
                        restart_16_clk = 1;
                    end
                    else next = IDLE;
                end
                
                SPUR_CHK: begin
                    if (baud16_clk) ncount = count + 1;
                    
                    if (count == 8) begin
                        ncount = 0;
                        n_bit_count = 0;
                        restart_16_clk = 1;
                        if (rxd == 0) next = RECEIVING;
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
                        data[bit_count] = rxd;
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
