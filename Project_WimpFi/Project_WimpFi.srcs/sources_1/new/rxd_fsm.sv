`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 11/11/2017 06:58:35 PM
// Design Name: 
// Module Name: rxd_fsm
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
// FSM module for WimpFi System- Receiver Module
//////////////////////////////////////////////////////////////////////////////////


module rxd_fsm(
    input logic clk,
    input logic reset,
    input logic byte_seen,
    input logic cardet,
    input logic [7:0] destination,
    input logic [7:0] mac_addr,
    input logic [7:0] pkt_type,
    input logic FCS_verified,
    input logic all_bytes_read,
    output logic reset_receiver,
    output logic RRDY,
    output logic type_2_seen,
    output logic store_type,
    output logic store_dest,
    output logic store_src,
    output logic incr_error,
    output logic ACK_received
    );
    
    //global define for broadcast address (works similar to define in C)
    `define BROADCAST_ADDR 8'H2A
    `define TYPE_0 8'd0
    `define TYPE_1 8'd1
    `define TYPE_2 8'd2
    `define TYPE_3 8'd3
    
    typedef enum logic[3:0]{
        IDLE = 4'd0,STORE_DEST = 4'd1,STORE_SRC = 4'd2,STORE_TYPE = 4'd3,STORE_DATA = 4'd4,CHK_FCS = 4'd5,IGNORE = 4'd6,READING = 4'd7,DEST_CHK=4'd8
    } states_t;
    
    states_t state, next;
    
    logic n_rrdy;
    
    always_ff @(posedge clk) begin
        if(reset)begin
            RRDY <=0;
            state<=IDLE;
        end
        else begin
            state<= next;
            RRDY <=n_rrdy;
        end
    end
    
    always_comb begin
        reset_receiver = 0;
        n_rrdy=RRDY;
        type_2_seen = 0;
        store_type = 0;
        store_dest = 0;
        store_src = 0;
        incr_error = 0;
        ACK_received = 0;
        
        unique case (state) 
            IDLE:begin
                if(cardet)next=STORE_DEST;
                else next = IDLE;
            end
            
            STORE_DEST:begin
                if(byte_seen)begin
                    next = DEST_CHK;
                    store_dest = 1;
                end
                else next = STORE_DEST;
            end
            
            DEST_CHK:begin
                if(destination == mac_addr || destination == `BROADCAST_ADDR)next = STORE_SRC;
                else next = IGNORE;
            end
            
            STORE_SRC:begin
                if(byte_seen)begin
                    store_src = 1;
                    next = STORE_TYPE;
                end    
                else next= STORE_SRC;
            end
            
            STORE_TYPE:begin
                if(byte_seen)begin
                    store_type = 1;
                    next = STORE_DATA;
                end    
                else next= STORE_TYPE;
            end
            
            STORE_DATA:begin
                if(cardet) next = STORE_DATA;
                else begin
                    if(pkt_type == `TYPE_0)next=READING;
                    else next = CHK_FCS;
                end
            end
            
            CHK_FCS:begin
                if(!FCS_verified)begin
                    incr_error = 1;
                    next = IDLE;
                    reset_receiver = 1;
                end
                else begin
                    case (pkt_type)
                        `TYPE_2:if(destination !=`BROADCAST_ADDR)type_2_seen=1;
                        `TYPE_3:ACK_received = 1;
                    endcase
                    next = READING;
                end
            end
            
            READING:begin
                if(all_bytes_read)begin
                    n_rrdy = 0;
                    next = IDLE;
                end
                else begin
                    n_rrdy = 1;
                    next = READING;
                end
            end
            
            
            
        endcase
    
    
    end
    
    
    
    
    
endmodule
