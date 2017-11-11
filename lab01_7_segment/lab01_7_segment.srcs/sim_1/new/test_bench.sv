`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2017 08:27:48 PM
// Design Name: 
// Module Name: test_bench
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


module test_bench;

    logic clk;
    logic rst;
    logic [7:0] read_addr,write_addr;
    logic [7:0] dout,din;
    logic wen,read_en;
    
    blk_mem_gen_0 U_BRAM(.clka(clk),.clkb(clk),.addra(write_addr),.addrb(read_addr),.doutb(dout),.dina(din),.wea(wen),.enb(read_en));
    
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    task write_bytes;
        integer i;
        for(i=0;i<10;i++)begin
            write_addr = i;
            @(posedge clk);#1;
            din = i;
            wen = 1;
            @(posedge clk);#1;
            wen = 0;
        end
    endtask
    
    task read_bytes;
        integer i;
        for(i=0;i<10;i++)begin
            read_addr = i;
            @(posedge clk);#1;
            read_en = 1;
            @(posedge clk);#1;
            read_en = 0; 
        end
    
    endtask;
    
    initial begin
        wen = 0;
        read_en=0;
        din = 8'h55;
        read_addr = 8'h00;
        write_addr = 8'h00;
        repeat(10) @(posedge clk);
        write_bytes;
        repeat(10) @(posedge clk);
        read_bytes;
        
        
    
        $stop;
    end

endmodule
