`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2017 03:27:01 PM
// Design Name: 
// Module Name: crc_generator
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


module crc_generator(
    input clk,
    input reset,
    input [7:0] xData,
    input newByte,
    output [7:0] crc_byte
    );
    
    logic [3:0] count_8;
    logic byteRegistered;
    logic startCount;
    
    
    //latch the new byte seen and byte registered signal
    always_ff @(posedge clk)begin
        if(reset) startCount<=0;
        else begin
            if(newByte)startCount <=1;
            else if(byteRegistered) startCount <=0;
        end
    end

    
    
    bcdcounter #(.LAST_VAL(8)) U_COUNT_BYTE(.clk(clk),.reset(reset),.enb(startCount),.carry(byteRegistered));
    
    
    
    logic bit_out;
    logic [7:0]shreg;    
    assign bit_out = shreg[0];
    
    always_ff @(posedge clk)begin
        if(reset)shreg = 8'h00;
        else begin
            if(newByte) begin 
                shreg<=xData;
            end
            else shreg<= shreg>>1;
        end  
    end
     
    
    logic [8:0]x;
    assign x[0] = bit_out ^ x[8];
    always_ff @(posedge clk)begin
        if(reset) begin
            x[8:1] <= 8'd0;
        end
        else if(startCount) begin
            x[8] <= x[7];
            x[7] <= x[6];
            x[6] <= x[5] ^ x[0];
            x[5] <= x[4] ^ x[0];
            x[4] <= x[3];
            x[3] <= x[2];
            x[2] <= x[1];
            x[1] <= x[0];
        end
    end
    
    
    assign crc_byte = x[8:1];
    
    
    
endmodule
