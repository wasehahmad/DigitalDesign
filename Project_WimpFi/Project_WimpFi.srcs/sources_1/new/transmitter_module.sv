`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2017 10:36:19 AM
// Design Name: 
// Module Name: transmitter_module
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


module transmitter_module #(parameter BIT_RATE = 50_000)(
    input logic clk,
    input logic reset,
    input logic [7:0] XDATA,
    input logic XWR,
    input logic XSEND,
    input logic cardet,
    input logic type_2_seen,
    input logic ACK_SEEN,
    input logic [7:0] type_2_source,
    input logic [7:0] MAC,
    output logic XRDY,
    output logic [7:0] ERRCNT,
    output logic txen,
    output logic txd
    );
    
    logic start_man_txd;
    logic[7:0] BRAM_DATA;
    logic man_txd_ready;
    logic [7:0] write_addr_a,addr_b;
    logic [7:0] pre_data;
    logic write_pre_data;
    
    always_ff @(posedge clk) begin
        if(reset)begin
            write_pre_data<=1;
            
        end
    end
    
    //block ram with different ports to write.to be able to write to both addr location at once
    blk_mem_gen_0 U_TXD_BRAM(.clka(clk),.addra(write_addr),.dina(pre_data),.wea(write_pre_data),.addrb(addr_b),.clkb(clk),.dinb(XDATA),.doutb(RDATA),.enb(RRD),.web(XWR));
    
    
    
    //manchester transmitter
    rtl_transmitter #(.BAUD(BIT_RATE),.BAUD2(BIT_RATE*2)) U_MAN_TXD(.clk_100mhz(clk),.reset(reset),.send(start_man_txd),.data(BRAM_DATA),
                                   .txd(txd),.rdy(man_txd_ready),.txen(txen));
    
    
endmodule
