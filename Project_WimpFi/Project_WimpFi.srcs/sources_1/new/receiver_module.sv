`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 11/11/2017 02:31:20 PM
// Design Name: 
// Module Name: receiver_module
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


module receiver_module #(parameter BIT_RATE=50_000)(
    input clk,
    input reset,
    input RXD,
    input RRD,
    input [7:0] MAC,
    output cardet,
    output RDATA,
    output RRDY,
    output RERRCNT,
    output type_2_seen,
    output ack_seen,
    output [7:0] type_2_source
    );
    
    logic [7:0] data_received;
    logic data_byte_seen;
    logic rxd_error;
    logic read_en,write_en;
    logic [7:0] read_addr,write_addr;
    
    //manchester receiver
    man_receiver    #(.BIT_RATE(BIT_RATE))  U_MAN_RECEIVER(.clk(clk), .reset(reset), .rxd(RXD), .cardet(cardet), .data(data_received), .write(data_byte_seen), .error(error));
    
    //block RAM for RXD
    blk_mem_gen_0 U_RXD_BRAM(.clka(clk),.addra(write_addr),.dina(data_received),.wea(write_en),.addrb(read_addr),.clkb(clk),.doutb(RDATA),.enb(read_en));
    
    
    ///////////////////////////////////////////////////////////////////////////CONTROL UNIT
    
    
    
    
    
    
    
    
endmodule
