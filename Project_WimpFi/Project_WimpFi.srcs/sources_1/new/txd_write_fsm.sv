`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2017 09:01:40 AM
// Design Name: 
// Module Name: txd_write_fsm
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


module txd_write_fsm #(parameter MAX_BYTES=255,ADDR_WIDTH=9) (
    input logic clk,
    input logic reset,
    input logic XWR,
    input logic XRDY,
    input logic XSEND,
    input logic done_transmitting,
    output logic wen,
    output logic [ADDR_WIDTH-1:0] w_addr,
    output logic done_writing
    );
    
    logic dest_seen;
    logic max_written;
  //  logic already_sent;
    assign wen = XWR && w_addr<=MAX_BYTES;//have to and it with that as it will try to keep writing to the 256-255 position in the br
    
    
    always_ff @(posedge clk)begin
        if(reset | (done_transmitting))begin
            w_addr<=0;
            dest_seen<=0;
            done_writing<=0;
            max_written = 0;
    //        already_sent<=1;
        end
        else begin
            if(XWR & XRDY && !max_written)begin
             //   already_sent<=0;
                if(dest_seen)w_addr<=w_addr+1;
                else begin//if desitnation hasnt been recorded yet
                    dest_seen<=1;
                    w_addr<=w_addr+2;
                end
                if(w_addr==MAX_BYTES)max_written<=1;
            end
            else if(/*!already_sent &&*/ XSEND & XRDY)begin
                done_writing<=1;
                dest_seen<=0;
//                already_sent<=1;
            end
            else done_writing <=0;
        end
        
    end
    
/*    
    typedef enum logic[3:0]{
        IDLE = 4'd0, WRITE_BYTE = 4'd1
    }states_t;
    
    states_t state, next;
    always_ff @(posedge clk)begin
        if(reset)begin
            state<=IDLE;
            w_addr<= 0;
            write_count<=0;
        end
        else begin
            state <= next;
            w_addr <=n_addr;
            write_count <=n_count;
        end
    end
    
    always_comb begin
        n_addr = w_addr;
        next = IDLE;
        n_count = write_count;
        done_writing = 0;
        
        unique case (state)
            IDLE:begin
            //if told to write either write destination or data
                if(XWR)begin
                    if(write_count ==0)n_addr = 0;//write destination
                    else n_addr = write_count+1;//skip over source addr
                    next = WRITE_BYTE;
                end
                //if send, check if type 0 first
                else if(XSEND)begin
                    next = IDLE;
                    done_writing = 1;
                    n_count=0;
                end
                //else stay in idle
                else next = IDLE;
            end
            
            WRITE_BYTE:begin
                n_count = write_count+1;
                next = IDLE;
            end
            

        endcase
    end
    
 */   
    
    
endmodule
