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


module txd_fsm #(parameter W = 10)(
    input logic clk,
    input logic reset,
    input logic network_busy,
    input logic cardet,
    input logic DIFS_DONE,
    input logic done_writing,
    input logic done_transmitting,
    input logic CONT_WIND_DONE,//might need to parameterize the widths
    input logic ACK_TIME_DONE,
    output logic XRDY,
    output logic incr_error,
    output logic reset_counters,
    output logic transmit,
    output logic reset_addr
    );
    
    logic network_was_busy,n_network_was_busy;
    logic n_reset_counters,n_transmit;
   
    
    typedef enum logic[3:0]{
        IDLE = 4'd0, CARDET_WAIT=4'd1,DIFS=4'd2,CONT_WIND=4'd3,NET_IDLE_CHK =4'd4,TRANSMIT = 4'd5,ACK_WAIT =4'd6
    }states_t;
    
    states_t state,next;
    
    always_ff @(posedge clk)begin
        if(reset)begin
            state<=IDLE;
            network_was_busy <=0;
            reset_counters<=0;
            transmit<=0;
        end
        else begin
            transmit<=n_transmit;
            state<=next;
            network_was_busy<=n_network_was_busy;
            reset_counters<=n_reset_counters;
        end
    end
    
    
    always_comb begin
        n_transmit = 0;
        n_reset_counters = 0;
        incr_error = 0;
        XRDY = 0;
        n_network_was_busy = network_was_busy;
        n_reset_counters = 0;
        reset_addr = 0;
        
        unique case(state)
            IDLE:begin
                XRDY = 1;
                n_network_was_busy = 0;
                n_reset_counters = 1;
                if(done_writing)next = cardet?CARDET_WAIT:NET_IDLE_CHK;
                else next  = IDLE;
            end
            
            CARDET_WAIT:begin//wait until cardet is done
                n_reset_counters = 1;
                if(cardet)next = CARDET_WAIT;
                else next = NET_IDLE_CHK;
            end
            
            NET_IDLE_CHK:begin 
                if(network_busy)begin//if txen is high on the network or something similar
                    n_network_was_busy = 1;
                    n_reset_counters=1;
                    next =NET_IDLE_CHK;
                end
                else if(DIFS_DONE)begin
                    n_reset_counters = 1;
                    next = network_was_busy?CONT_WIND:TRANSMIT;
                end
                else next = NET_IDLE_CHK;
            end
            
            CONT_WIND:begin
                if(CONT_WIND_DONE)next = network_busy?NET_IDLE_CHK:TRANSMIT;
                else next = CONT_WIND;
            end
            
            TRANSMIT:begin
                if(done_transmitting)begin
                    next = IDLE;
                    n_transmit=0;
                    reset_addr = 1;/////////////////////////////Will need to only reset write signal after teh ACK is received
                end
                else begin 
                    n_transmit = 1;
                    next = TRANSMIT;
                end
            end
            
            
            
        endcase
    end
    
endmodule
