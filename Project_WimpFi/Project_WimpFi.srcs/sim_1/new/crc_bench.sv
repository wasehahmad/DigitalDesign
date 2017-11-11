`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2017 04:52:40 PM
// Design Name: 
// Module Name: crc_bench
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


module crc_bench;

    import check_p ::*;

    logic clk,reset,newByte;
    
    logic [7:0] crc_byte,xData;
    
    crc_generator U_FCS(.clk(clk),.reset(reset),.xData(xData),.newByte(newByte),.crc_byte(crc_byte));
    
    task send_multiple_bytes;
        integer i;
        for(i=0;i<10;i++)begin
            xData=i;
            @(posedge clk);
            #1 newByte = 1;
            @(posedge clk);
            #1 newByte = 0;
            repeat(10) @(posedge clk);
        end
            xData = {crc_byte[0],crc_byte[1],crc_byte[2],crc_byte[3],crc_byte[4],crc_byte[5],crc_byte[6],crc_byte[7]};
            @(posedge clk);
            #1 newByte = 1;
            @(posedge clk);
            #1 newByte = 0;
            repeat(10) @(posedge clk);
            check_ok("CRC Correctly calculated",crc_byte,8'd0);
    endtask
    
    

    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    initial begin
        reset = 1;
        xData = 8'hFF;
        newByte = 0;
        repeat(100) @(posedge clk);
        reset = 0;
        repeat(100) @(posedge clk);
        #1 newByte = 1;
        @(posedge clk);
        #1 newByte = 0;
        repeat(10) @(posedge clk);
        send_multiple_bytes;
        $stop;
    end
    
endmodule
