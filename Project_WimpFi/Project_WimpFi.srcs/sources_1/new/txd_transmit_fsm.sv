`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2017 10:28:09 AM
// Design Name: 
// Module Name: txd_transmit_fsm
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


module txd_transmit_fsm #(parameter PREAMBLE_SIZE = 2)(
    input logic clk,
    input logic reset,
    input logic start_transmission,
    input logic man_txd_rdy,//get this signal single pulsed
    input logic [7:0] max_data_count,
    input logic [7:0] FCS,
    input logic [7:0] pkt_type,
    input logic [7:0] BRAM_data,
    output logic [7:0] data_count,
    output logic [7:0] man_txd_data,
    output logic read_en
    );
    
    logic [7:0] n_d_count,n_data;
    logic done_preamble,reset_counter;
    
    bcdcounter #(.LAST_VAL(PREAMBLE_SIZE+1)) U_PRE_COUNTER(.clk(clk),.reset(reset | reset_counter),.enb(man_txd_rdy),.carry(done_preamble));
    
    typedef enum logic [3:0]{
        IDLE = 4'd0, PREAMBLE= 4'd1,SFD = 4'd2,DATA = 4'd3,SEND_FCS = 4'd4
    }states_t;
    
    states_t state,next;
    
    always_ff @(posedge clk) begin
        if(reset)begin
            state<=IDLE;
            data_count<=0;
            man_txd_data<=8'hAA;
        end
        else begin
            state<=next;
            data_count<=n_d_count;
            man_txd_data<=n_data;
        end
    end
    
    always_comb begin
        next = IDLE;
        n_d_count = data_count;
        read_en = 0;
        reset_counter = 0;
        n_data = man_txd_data;
        
        unique case (state)
            IDLE:begin
                if(start_transmission)begin
                    next = PREAMBLE;
                    reset_counter = 1;
                end
                else next = IDLE;
            end 
            
            PREAMBLE:begin
                if(done_preamble)begin
                    next = SFD;
                    n_data = 8'b11010000;
                end
                else next = PREAMBLE;
            end
            
            SFD:begin
                if(man_txd_rdy)begin
                    read_en = 1;
                    next = DATA;
                    n_data = BRAM_data;////////////////////////////////////check if the man_txd loads new data at the beginning of read or end
                end
                else next = SFD;
            end
            
        endcase
    
    end
endmodule
