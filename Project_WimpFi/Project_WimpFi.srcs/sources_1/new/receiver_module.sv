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
    input logic clk,
    input logic reset,
    input logic RXD,
    input logic RRD,
    input logic [7:0] MAC,
    output logic cardet,
    output logic RDATA,
    output logic RRDY,
    output logic [7:0] RERRCNT,//might need to check the actual max err cnt
    output logic type_2_seen,
    output logic ack_seen,
    output logic [7:0] type_2_source
    );
    

    
    logic [7:0] data_received;
    logic data_byte_seen;
    logic rxd_error;
    logic read_en,write_en;
    logic [7:0] read_addr,write_addr;
    
    //manchester receiver
    man_receiver    #(.BIT_RATE(BIT_RATE))  U_MAN_RECEIVER(.clk(clk), .reset(reset), .rxd(RXD), .cardet(cardet), .data(data_received), .write(data_byte_seen), .error(error));
    logic rxd_write_pulse;
    single_pulser U_WRITE_PULSE(.clk(clk),.din(data_byte_seen),.d_pulse(rxd_write_pulse));
    
    //block RAM for RXD
    assign write_en = rxd_write_pulse;
    blk_mem_gen_0 U_RXD_BRAM(.clka(clk),.addra(write_addr),.dina(data_received),.wea(write_en),.addrb(read_addr),.clkb(clk),.doutb(RDATA),.enb(read_en));
    
    
    ///////////////////////////////////////////////////////////////////////////CONTROL UNIT

    logic [7:0] dest,pkt_type;
    logic fcs_correct;
    logic done_reading;
    logic store_dest,store_type,store_src;
    logic reset_receiver,incr_error;
    

    
    //FSM for the control unit
    rxd_fsm U_RXD_FSM(.clk(clk),.reset(reset),.byte_seen(rxd_write_pulse),.cardet(cardet),.destination(dest),.MAC_Addr(MAC),.pkt_type(pkt_type),.FCS_verified(fcs_correct),.all_bytes_received(done_reading),
                    .reset_receiver(reset_receiver),.RRDY(RRDY),.type_2_seen(type_2_seen),.store_type(store_type),.store_dest(store_dest),.store_src(store_src),.incr_error(incr_error),.ACK_received(ack_seen));
    
    //flip flop to store data for fsm and transmitter
    always_ff @(posedge clk)begin
        if(reset)begin
            RERRCNT <=0;
            type_2_source <= 8'h00;
            dest <=8'h00;
            pkt_type<=8'h00; 
        end
        else begin
            if(incr_error) RERRCNT<=RERRCNT+1;
            if(store_src)type_2_source <=data_received;
            if(store_dest)dest <=data_received;
            if(store_type)pkt_type <=data_received;
        end
    
    end
    
    //for the bram counter, only write dest,source,type,and data
    //check type and adjust max of read counter when the data is to be read.e.g. max for type 0 = write_addr, else write_addr-1 to not read the fcs
    
    
    
    
    
    
    
    
    
endmodule
