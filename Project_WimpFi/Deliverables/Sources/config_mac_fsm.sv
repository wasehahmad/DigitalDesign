`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2017 08:15:13 AM
// Design Name: 
// Module Name: config_mac_fsm
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


module config_mac_fsm(
    input logic clk,
    input logic reset,
    input logic button_left,
    input logic button_right,
    input logic button_up,
    input logic button_down,
    output logic [7:0] src_mac,
    output logic [7:0] current_seg
    );
  
    logic [7:0] n_current_seg;
    logic [7:0] n_src_mac;
    
    typedef enum logic [2:0]{
        IDLE = 3'd0, DEC_SEG = 3'd1, INC_SEG = 3'd2, DEC_DIG = 3'd3, INC_DIG = 3'd4
    } states_t;
    
    states_t state, next;
    
    always_ff @(posedge clk) begin
        if(reset)begin
            state <= IDLE;
            // on reset, the current segment gets set position 4
            current_seg <= 8'b01000000;
            src_mac <= "@";
        end
        else begin
            state <= next;
            current_seg <= n_current_seg;
            src_mac   <= n_src_mac;
        end
    end    
    
    always_comb begin
        next = IDLE;
        n_current_seg = current_seg;
        n_src_mac = src_mac;
        
        unique case (state)
            IDLE: begin
                if (button_left) next = INC_SEG;
                else if (button_right) next = DEC_SEG;
                else if (button_up) next = INC_DIG;
                else if (button_down) next = DEC_DIG;
                else next = IDLE;
            end
            
            INC_SEG: begin
                //move the current segment to the left one
                //if seg is in leftmost position, wrap around
                if (current_seg == 8'b10000000) n_current_seg = 8'b01000000;
                else n_current_seg = 8'b10000000;
                next = IDLE;
            end
            
            DEC_SEG: begin
                //move the current segment to the right one
                //if seg is in rightmost position, wrap around
                if (current_seg == 8'b01000000) n_current_seg = 8'b10000000;
                else n_current_seg = 8'b01000000;
                next = IDLE;
            end
            
            INC_DIG: begin
                //increment the current segment by 1
                //if seg contains the highest value (F), wrap around
                if (current_seg == 8'b01000000) begin
                    if (src_mac[3:0] == 4'hf) begin
                        n_src_mac = {src_mac[7:4], 4'h0};
                    end
                    else n_src_mac = src_mac + 1;
                end
                else begin
                    if (src_mac[7:4] == 4'hf) begin
                        n_src_mac = {4'h0, src_mac[3:0]};        
                    end
                    else n_src_mac = {src_mac[7:4]+1, src_mac[3:0]};
                end
                next = IDLE;
            end
            
            DEC_DIG: begin
                //decrement the current segment by 1
                //if seg contains the lowest value (0), wrap around
                if (current_seg == 8'b01000000) begin
                    if (src_mac[3:0] == 4'h0) begin
                        n_src_mac = {src_mac[7:4],4'hf};
                    end
                    else n_src_mac = src_mac - 1;
                end
                else begin
                    if (src_mac[7:4] == 4'h0) begin
                        n_src_mac = {4'hf,src_mac[3:0]};        
                    end
                    else n_src_mac = {src_mac[7:4]-1,src_mac[3:0]};
                end
                next = IDLE;
            end                                    
        endcase    
    end
        
endmodule
