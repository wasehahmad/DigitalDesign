`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 11/14/2017 08:57:35 AM
// Design Name: 
// Module Name: txd_fsm
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


module txd_fsm #(parameter W = 10,MAX_ATTEMPTS = 5,ATT_W = $clog2(MAX_ATTEMPTS)+1)(
    input logic clk,
    input logic reset,
    input logic network_busy,
    input logic cardet,
    input logic DIFS_DONE,
    input logic done_writing,
    input logic done_transmitting,
    input logic CONT_WIND_DONE,//might need to parameterize the widths
    input logic ACK_TIME_DONE,
    input logic ACK_received,
    input logic SIFS_COUNT_DONE,
    input logic [7:0]pkt_type,
    input logic [7:0]destination,
    output logic txd_fsm_RDY,
    output logic incr_error,
    output logic reset_counters,
    output logic transmit,
    output logic reset_addr,
    output logic new_attempt
    );
    
    logic network_was_busy,n_network_was_busy;
    logic n_reset_counters,n_transmit;
    logic n_RDY;
    logic [ATT_W-1:0] attempts,n_attempts;
    
    typedef enum logic[3:0]{
        IDLE = 4'd0, CARDET_WAIT=4'd1,DIFS=4'd2,CONT_WIND=4'd3,NET_IDLE_CHK =4'd4,TRANSMIT = 4'd5,ACK_WAIT =4'd6,TYPE_3=4'd7
    }states_t;
    
    states_t state,next;
    
    always_ff @(posedge clk)begin
        if(reset)begin
            state<=IDLE;
            network_was_busy <=0;
            reset_counters<=0;
            transmit<=0;
            txd_fsm_RDY<=0;
            attempts<=0;
        end
        else begin
            attempts <=n_attempts;
            txd_fsm_RDY<=n_RDY;
            transmit<=n_transmit;
            state<=next;
            network_was_busy<=n_network_was_busy;
            reset_counters<=n_reset_counters;
        end
    end
    
    
    always_comb begin
        n_attempts = attempts;
        n_transmit = 0;
        n_reset_counters = 0;
        incr_error = 0;
        n_network_was_busy = network_was_busy;
        n_reset_counters = 0;
        reset_addr = 0;
        n_RDY=0;
        new_attempt = 0;
        
        unique case(state)
            IDLE:begin
                n_RDY = 1;
                n_network_was_busy = 0;
                n_reset_counters = 1;
                n_attempts = 0;
                if(done_writing)begin
                    if(pkt_type == "3") next = TYPE_3;
                    else next = cardet?CARDET_WAIT:NET_IDLE_CHK;
                end
                else next  = IDLE;
            end
            
            TYPE_3:begin
                if(SIFS_COUNT_DONE)begin
                    n_reset_counters = 1;
                    next = TRANSMIT;
                end
                else next = TYPE_3;
            end
            
            CARDET_WAIT:begin//wait until cardet is done
                n_reset_counters = 1;
//                if(cardet)next = CARDET_WAIT;
//                else next = NET_IDLE_CHK;
                next = NET_IDLE_CHK;
            end
            
            NET_IDLE_CHK:begin 
                if(network_busy)begin//if txen is high on the network or something similar
                    n_network_was_busy = 1;//need to reset when transmitting
                    //n_reset_counters=1;
                    //next =NET_IDLE_CHK;
                end
      /* else*/ if(DIFS_DONE)begin
                    n_reset_counters = 1;
                    next = network_was_busy?CONT_WIND:TRANSMIT;
                end
                else next = NET_IDLE_CHK;
            end
            
            CONT_WIND:begin
                if(CONT_WIND_DONE)begin
                    n_reset_counters = 1;
                    next = network_busy?NET_IDLE_CHK:TRANSMIT;
                end
                else next = CONT_WIND;
            end
            
            TRANSMIT:begin
                if(done_transmitting)begin
                    
                    n_transmit=0;
                    n_attempts = attempts+1;
                    if(pkt_type == "2" && destination != "*")begin//dont try to wait for ack if broadcast data
                        next = ACK_WAIT;
                        n_reset_counters = 1;
                    end
                    else begin
                        reset_addr = 1;/////////////////////////////Will need to only reset write signal after the ACK is received
                        next = IDLE;
                    end
                end
                else begin 
                    n_network_was_busy = 0;
                    n_transmit = 1;
                    next = TRANSMIT;
                end
            end
            
            ACK_WAIT:begin
                if(!ACK_received && ACK_TIME_DONE)begin
                    if(attempts==MAX_ATTEMPTS)begin
                        next = IDLE;
                        reset_addr = 1;
                        incr_error = 1;
                    end
                    else begin
                    next = CARDET_WAIT;//it will reset counters there
                    new_attempt = 1;
                end
                end
                else if(ACK_received)begin
                    next = IDLE;
                    reset_addr = 1;
                end  
                else next = ACK_WAIT;   
            
            end
            
            
            
        endcase
    end
    
endmodule
