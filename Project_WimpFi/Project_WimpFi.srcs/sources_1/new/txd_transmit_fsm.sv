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
    output logic read_en,
    output logic restart_addr
    );
    
    logic [7:0] n_d_count,n_data;
    logic done_preamble,reset_counter,n_read_en;
    
    bcdcounter #(.LAST_VAL(PREAMBLE_SIZE)) U_PRE_COUNTER(.clk(clk),.reset(reset | reset_counter),.enb(man_txd_rdy),.carry(done_preamble));
    
    typedef enum logic [3:0]{
        IDLE = 4'd0, PREAMBLE= 4'd1,SFD = 4'd2,DATA = 4'd3,SEND_FCS = 4'd4
    }states_t;
    
    states_t state,next;
    
    always_ff @(posedge clk) begin
        if(reset)begin
            state<=IDLE;
            data_count<=0;
            man_txd_data<=8'hAA;
            read_en<=0;
        end
        else begin
            state<=next;
            data_count<=n_d_count;
            man_txd_data<=n_data;
            read_en<=n_read_en;
        end
    end
    
    always_comb begin
        next = IDLE;
        n_d_count = data_count;
        n_read_en = 0;
        reset_counter = 0;
        n_data = man_txd_data;
        restart_addr = 0;
        
        unique case (state)
            IDLE:begin
                if(start_transmission)begin
                    next = PREAMBLE;
                    reset_counter = 1;
                    n_d_count = 0;
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
                    //n_read_en = 1;
                    next = DATA;
                    //n_data = BRAM_data;////////////////////////////////////check if the man_txd loads new data at the beginning of read or end
                end
                else next = SFD;
            end
            
            DATA:begin
                if(data_count>=max_data_count-1 && pkt_type=="0")n_read_en=0;
                else n_read_en = 1;
                n_data= BRAM_data;
                if(data_count<max_data_count)begin
                    n_data= BRAM_data;
                    if(man_txd_rdy)begin
                        n_d_count = data_count+1;
                        
                    end
                    next = DATA;
                end
                else begin
                    if(pkt_type=="0")begin
                        restart_addr=1;
                        next = IDLE;
                    end
                    else next = SEND_FCS;
                end
            end
            
            SEND_FCS:begin
                n_data = FCS;
                n_read_en = 1;
                if(man_txd_rdy)begin
                    restart_addr = 1;
                    next = IDLE;
                end
                else next = SEND_FCS;
            end
            
        endcase
    
    end
endmodule
