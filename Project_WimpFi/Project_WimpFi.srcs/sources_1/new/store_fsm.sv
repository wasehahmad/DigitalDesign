`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2017 01:44:11 PM
// Design Name: 
// Module Name: store_fsm
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


module store_fsm(
    input logic clk,
    input logic reset,
    input logic write,
    input logic cardet,
    input logic [7:0] pkt_type,
    input logic read,
    input logic RRDY,
    input logic fifo_empty,
    output logic done_reading
    );
    
    logic [7:0] data_written,n_data_written,data_read,n_data_read;
    
    typedef enum logic [3:0]{
        IDLE=4'd1,WRITING = 4'd2,READING=4'd3,DONE=4'd4
    }states_t;
    
    states_t state,next;
    
    always_ff @(posedge clk)begin
        if(reset)begin
            state<=IDLE;
            data_written <= 0;
            data_read <=0;
        end
        else begin
            data_written <=n_data_written; 
            state<=next;
            data_read<=n_data_read;
        end
    end
    
    always_comb begin
        done_reading = 0;
        next = IDLE;
        n_data_written = data_written;
        n_data_read = data_read;
        
        unique case (state)
            IDLE:begin
                if(cardet)next = WRITING;
                else begin 
                    n_data_read = 0;
                    n_data_written = 0;
                    next = IDLE;
                end
            end
            
            WRITING:begin
                if(cardet)begin
                    if(write) n_data_written = data_written+1;
                    next = WRITING;
                end
                else begin
                    next = READING;
                end
            end
            
            READING:begin
                if(fifo_empty || (data_written==8'd1 && pkt_type != "0"))begin
                    done_reading = 1;
                    next = DONE;
                end
                else next = READING;
                if(read)n_data_written = data_written-1;
                //if(read)n_data_read = data_read+1;
            end
            DONE:begin//needs to be reset
                done_reading=1;
                next = RRDY?DONE:IDLE;
            end
            
        endcase
    end
    
    
endmodule
