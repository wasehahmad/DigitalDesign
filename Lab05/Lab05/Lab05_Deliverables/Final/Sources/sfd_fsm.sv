`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2017 09:34:02 PM
// Design Name: 
// Module Name: sfd_fsm
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


module sfd_fsm(
    input logic clk,
    input logic reset,
    input logic preamble_detected,
    input logic corroborating,
    input logic sfd_detected,
    input logic eof,
    input logic error,
    output logic cardet,
    output logic start_receiving
    );
    
    
    logic n_cardet;
    typedef enum logic[1:0] {
        CHK_PREAMBLE=2'd0, CHK_SFD=2'd1, RECEIVING=2'd2
    } states_t;
    
    states_t state, next;
    
    always_ff @(posedge clk) begin
        if (reset) begin 
            state <= CHK_PREAMBLE;
            cardet<=0;
        end
        else begin
            state <= next;
            cardet <= n_cardet;
        end
    end
    

    
    always_comb begin
    //defaults
    n_cardet = 0;
    next = CHK_PREAMBLE;    
    start_receiving = 0;
        
        unique case (state)       
            
            CHK_PREAMBLE: begin
                if (preamble_detected) begin 
                    next = CHK_SFD;
                    n_cardet = 1;
                end
                else next = CHK_PREAMBLE;
            end
            
            
            CHK_SFD: begin
                if (sfd_detected) begin 
                    next = RECEIVING;
                    n_cardet = 1;
                end
                else if (corroborating | preamble_detected) begin
                    next = CHK_SFD;
                    n_cardet = 1;
                end
                else begin
                    next = CHK_PREAMBLE;
                    n_cardet = 0;
                end
            end
           
            RECEIVING: begin
                if (error | eof) begin 
                    next = CHK_PREAMBLE;
                    n_cardet = 0;
                end
                else begin
                    next = RECEIVING;
                    n_cardet = 1;
                    start_receiving = 1;
                end
            end
           
        endcase
    end
endmodule
