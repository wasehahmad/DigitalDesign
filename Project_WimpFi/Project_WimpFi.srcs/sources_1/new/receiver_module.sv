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
    input logic [7:0] mac_addr,
    output logic cardet,
    output logic [7:0] RDATA,
    output logic RRDY,
    output logic [7:0] RERRCNT,//might need to check the actual max err cnt
    output logic type_2_seen,
    output logic ack_seen,
    output logic [7:0] source
    );
    

    
    logic [7:0] data_received;
    logic data_byte_seen;
    logic rxd_error;
    logic [7:0] read_addr,write_addr;
    
    //manchester receiver
    man_receiver #(.BIT_RATE(BIT_RATE))  U_MAN_RECEIVER(.clk(clk), .reset(reset), .rxd(RXD), .cardet(cardet), .data(data_received), .write(data_byte_seen), .error(error));
    
    logic rxd_write_pulse;
    single_pulser U_WRITE_PULSE(.clk(clk),.din(data_byte_seen),.d_pulse(rxd_write_pulse));
    
    logic cardet_pulse;
    single_pulser U_CARDET_PULSE(.clk(clk),.din(cardet),.d_pulse(cardet_pulse));
    
   
    logic full,empty;
    logic done_reading;
    logic reset_receiver;
    //block RAM for RXD
    //blk_mem_gen_0 U_RXD_BRAM(.clka(clk),.addra(write_addr),.dina(data_received),.wea(rxd_write_pulse),.addrb(read_addr),.clkb(clk),.doutb(RDATA),.enb(RRD));
    sasc_fifo #(.FIFO_DEPTH(256)) U_RXD_FIFO(.clk(clk),.rst(reset | cardet_pulse |done_reading | reset_receiver),.din(data_received),.we(rxd_write_pulse),.re(RRD),.dout(RDATA),.full(full),.empty(empty));
    
    
    ///////////////////////////////////////////////////////////////////////////CONTROL UNIT

    logic [7:0] dest,pkt_type;
    logic fcs_correct;
    logic store_dest,store_type,store_src;
    logic incr_error;
    logic [7:0]crc_result;
    
    assign fcs_correct = crc_result ==8'd0;
    
    //FSM for the control unit
    rxd_fsm U_RXD_FSM(.clk(clk),.reset(reset),.byte_seen(rxd_write_pulse),.cardet(cardet),.destination(dest),.mac_addr(mac_addr),.pkt_type(pkt_type),.FCS_verified(fcs_correct),.all_bytes_read(done_reading),
                    .reset_receiver(reset_receiver),.RRDY(RRDY),.type_2_seen(type_2_seen),.store_type(store_type),.store_dest(store_dest),.store_src(store_src),.incr_error(incr_error),.ACK_received(ack_seen));
    
    //flip flop to store data for fsm and transmitter
    always_ff @(posedge clk)begin
        if(reset)begin
            RERRCNT <=0;
            source <= 8'h00;
            dest <=8'h00;
            pkt_type<=8'h00; 
        end
        else begin
            if(incr_error) RERRCNT<=RERRCNT+1;
            if(store_src)source <=data_received;
            if(store_dest)dest <=data_received;
            if(store_type)pkt_type <=data_received;
        end
    
    end
    
    //for the bram counter, only write dest,source,type,and data
    //check type and adjust max of read counter when the data is to be read.e.g. max for type 0 = write_addr, else write_addr-1 to not read the fcs
    store_fsm U_STORAGE_FSM(.clk(clk),.reset(reset | reset_receiver),.write(rxd_write_pulse),.read(RRD),.cardet(cardet),.pkt_type(pkt_type),.done_reading(done_reading));
    
    
    crc_generator U_FCS_VERIFICATION(.clk(clk),.reset(reset | reset_receiver | RRDY),.xData(data_received),.newByte(rxd_write_pulse),.crc_byte(crc_result));
    
    
   
    
endmodule
