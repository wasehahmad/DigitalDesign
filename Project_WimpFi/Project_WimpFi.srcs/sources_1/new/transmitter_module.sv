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
    logic[7:0] BRAM_DATA,FCS;
    logic man_txd_ready,man_txd_rdy_pulse;
    logic [7:0] read_addr_b,write_addr_b;
    logic write_source;
    logic start_transmitting;
    logic read_en,write_en;//sent from transmit_fsm to bram
    logic done_writing;
    
    logic [6:0] rand_count;//1-64
    //==========================RANDOM_NUM_COUNTER===============================================
    always_ff @(posedge clk)begin
        if(reset)rand_count <= 1;
        else begin
            if(rand_count==64)rand_count<=1;
            else rand_count<=rand_count+1;    
        end
    end
    //loads the BRAM with source
    //===========================LOAD_SOURCE INTO BRAM============================================
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
    
    //===========================STORE_PKT_TYPE================================================
    logic [7:0] pkt_type;
    always_ff @(posedge clk)begin
        if(reset) pkt_type = 8'd0;
        else if(read_addr_b ==8'd2/*The location of the type*/)begin
            pkt_type = BRAM_DATA;
        end
    end
    
    

    //block ram with different ports to write.to be able to write to both addr location at once
    //addr_b comes from the transmit_fsm data_count
    logic port_b_addr;
    assign port_b_addr = (txen)?read_addr_b:write_addr_b;
    
    blk_mem_gen_0 U_TXD_BRAM(.clka(clk),.addra(8'h01),.dina(MAC),.wea(write_source),
                                .addrb(port_b_addr),.clkb(clk),.dinb(XDATA),.doutb(BRAM_DATA),.enb(read_en),.web(write_en));
    
    
    logic [7:0] man_txd_data;
    //manchester transmitter
    rtl_transmitter #(.BAUD(BIT_RATE),.BAUD2(BIT_RATE*2)) U_MAN_TXD(.clk_100mhz(clk),.reset(reset),.send(start_man_txd),.data(man_txd_data),
                                   .txd(txd),.rdy(man_txd_ready),.txen(txen));
   
    single_pulser U_MAN_TXD_RDY_PULSE(.clk(clk), .din(man_txd_ready), .d_pulse(man_txd_rdy_pulse));
    
    //===========================CRC_GENERATOR============================================
    //make sure to only account for the max 255 bytes, destination,source,type and data
    //keep a counter which will disable further counting
    //keep a counter for max number of bytes
    //might have to transmit the crc from the receiver
    crc_generator U_FCS_FORMATION(.clk(clk),.reset(reset),.xData(BRAM_DATA),.newByte(read_en && man_txd_rdy_pulse),.crc_byte(FCS));
    
                                   
    //==========================WRITE TO BRAM===========================================                               
    //fsm to write to BRAM
    //make sure to check the write_en and write_addr_b signals for timing to ensure correct data is being loaded
    txd_write_fsm U_BRAM_WRITING(.clk(clk),.reset(reset),.XWR(XWR),.XSEND(XSEND),.wen(write_en),.w_addr(write_addr_b),.done_writing(done_writing));
    
    
    //==========================TRANSMIT===========================================
    //transmit fsm
    
    txd_transmit_fsm U_TRANSMIT_FSM(.clk(clk),.reset(reset),.start_transmission(start_transmitting),.man_txd_rdy(man_txd_rdy_pulse),
                    .max_data_count(write_addr_b/*the write address will be the last location*/),.FCS(FCS),.pkt_type(pkt_type),.BRAM_data(BRAM_DATA),
                    .data_count(read_addr_b),.man_txd_data(man_txd_data),.read_en(read_en));
    
    
    
endmodule
