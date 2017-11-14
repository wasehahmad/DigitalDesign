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


module transmitter_module #(parameter BIT_RATE = 50_000,PREAMBLE_SIZE = 2)(
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
    logic [7:0] addr_b;
    logic write_source;
    logic transmit_preamble,transmit_data,transmit_fcs;
    
    logic [6:0] rand_count;//1-64
    //==========================RANDOM_NUM_COUNTER===============================================
    always_ff @(posedge clk)begin
        if(reset)rand_count <= 1;
        else begin
            if(rand_count==64)rand_count<=1;
            else rand_count<=rand_count+1;    
        end
    end
    
    

    //block ram with different ports to write.to be able to write to both addr location at once
    blk_mem_gen_0 U_TXD_BRAM(.clka(clk),.addra(8'h01),.dina(MAC),.wea(write_source),.addrb(addr_b),.clkb(clk),.dinb(XDATA),.doutb(RDATA),.enb(RRD),.web(XWR));
    
    
    logic [7:0] man_txd_data;
    //manchester transmitter
    rtl_transmitter #(.BAUD(BIT_RATE),.BAUD2(BIT_RATE*2)) U_MAN_TXD(.clk_100mhz(clk),.reset(reset),.send(start_man_txd),.data(man_txd_data),
                                   .txd(txd),.rdy(man_txd_ready),.txen(txen));
    
    //===========================CRC_GENERATOR============================================
    //make sure to only account for the max 255 bytes, destination,source,type and data
    //keep a counter which will disable further counting
    //keep a counter for max number of bytes
    //might have to transmit the crc from the receiver
    
                                   
                                   
    //loads the BRAM with source
    //===========================LOAD_SOURCEBRAM============================================
    logic [7:0] prevMac;
    always_ff @(posedge clk) begin
       if(reset)begin
           prevMac <= MAC;
       end
       else begin
           if(MAC!=prevMac)write_source<=1;
           else write_source<=0;
           prevMac <= MAC;
       end
    end
    
    //==========================TRANSMIT===========================================
    //transmit fsm
    
    
    
endmodule
