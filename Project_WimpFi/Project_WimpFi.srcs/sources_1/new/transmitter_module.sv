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


module transmitter_module #(parameter BIT_RATE = 50_000,PREAMBLE_SIZE = 2,DIFS =1,SLOT_TIME = 1,ACK_TIMEOUT=256,SIFS=40,MAX_FRAMES = 510)(
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
    output logic txd,
    output logic WATCHDOG_ERROR
    );
    
    logic[7:0] BRAM_DATA,FCS,BRAM_DATA_IN;
    logic man_txd_ready,man_txd_rdy_pulse;
    logic [7:0] read_addr_b,write_addr_b;
    logic write_source;
    logic start_transmitting;
    logic read_en,write_en;//sent from transmit_fsm to bram
    logic done_writing;
    
    logic [6:0] rand_count,curr_rand_count;//1-64
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
           write_source<=1;
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
    
    //========================WATCH_DOG_TIMER=====================================================
    logic [9:0] continuous_frames_sent;
    always_ff @(posedge clk)begin
        if(reset | txen)continuous_frames_sent<=0;
        else if(man_txd_rdy_pulse)continuous_frames_sent<=continuous_frames_sent+1;
    end
    always_ff @(posedge clk)begin
        if(reset)WATCHDOG_ERROR<=0;
        else if(continuous_frames_sent==MAX_FRAMES)WATCHDOG_ERROR<=1;
    end
    
    
    //=======================MAIN_TXD_FSM +COUNTERS===========================================================
    logic DIFS_DONE,CONT_WIND_DONE,ACK_TIME_DONE,SIFS_DONE;
    logic done_transmitting,incr_error,reset_counters;
    logic restart_addr;
    
    logic bit_done,txd_fsm_rdy;
    logic [10:0] bit_count;
    
    always_ff @(posedge clk)begin
        if(reset)ERRCNT<=0;
        else if(incr_error)ERRCNT<=ERRCNT+1;
    end
    
    assign done_transmitting = read_addr_b == write_addr_b;
    assign XRDY = txd_fsm_rdy && txen==0;
    txd_fsm U_TXD_FSM(.clk(clk),.reset(reset | WATCHDOG_ERROR),.network_busy(cardet/*might change this*/),.cardet(cardet),.done_writing(done_writing),.done_transmitting(done_transmitting),
                    .DIFS_DONE(DIFS_DONE),.CONT_WIND_DONE(CONT_WIND_DONE),.ACK_TIME_DONE(ACK_TIME_DONE),.reset_addr(restart_addr),
                    .XRDY(txd_fsm_rdy),.incr_error(incr_error),.reset_counters(reset_counters),.transmit(start_transmitting));
                    
    
    clkenb #(.DIVFREQ(BIT_RATE)) U_BIT_PERIOD_CLK(.clk(clk),.reset(reset | reset_counters),.enb(bit_done));
    
    always_ff @(posedge clk)begin
        if(reset | reset_counters)begin
            bit_count <=0;
            curr_rand_count<=rand_count; 
        end
        else if(bit_done)bit_count<=bit_count+1;
    end
    
    //assign count done conditions
    assign DIFS_DONE = bit_count==DIFS;
    assign CONT_WIND_DONE = bit_count == curr_rand_count<<3;//Slot time ==8 or 2^3
    assign SIFS_DONE = bit_count == SIFS;
    assign ACK_TIME_DONE = bit_count==ACK_TIMEOUT;
    
    //=====================BLOCK_RAM and manchester transmitter===================================================================

    //block ram with different ports to write.to be able to write to both addr location at once
    //addr_b comes from the transmit_fsm data_count
    logic [7:0] bram_addr;
    
    //mux for writing source and writing data
    always_comb begin
        if(write_source && XRDY && !write_en)begin
            bram_addr=8'h01;
            BRAM_DATA_IN = MAC;
        end
        else begin
            bram_addr = (txen)?read_addr_b:write_addr_b;
            BRAM_DATA_IN = XDATA;
        end
    end

    
    blk_mem_gen_0 U_TXD_BRAM(.clka(clk),.addra(bram_addr),.dina(BRAM_DATA_IN),.douta(BRAM_DATA),.wea(write_source|write_en));
    
    logic start_pulse;
    single_pulser U_MAN_TXD_START_PULSE(.clk(clk), .din(start_transmitting), .d_pulse(start_pulse));
    
    logic [7:0] man_txd_data;
    //manchester transmitter
    rtl_transmitter #(.BAUD(BIT_RATE),.BAUD2(BIT_RATE*2)) U_MAN_TXD(.clk_100mhz(clk),.reset(reset | WATCHDOG_ERROR),.send(start_transmitting & !done_transmitting  ),.data(man_txd_data),
                                   .txd(txd),.rdy(man_txd_ready),.txen(txen));
   
    single_pulser U_MAN_TXD_RDY_PULSE(.clk(clk), .din(man_txd_ready), .d_pulse(man_txd_rdy_pulse));
    
    //===========================CRC_GENERATOR============================================
    //make sure to only account for the max 255 bytes, destination,source,type and data
    //keep a counter which will disable further counting
    //keep a counter for max number of bytes
    //might have to transmit the crc from the receiver
    crc_generator U_FCS_FORMATION(.clk(clk),.reset(reset | WATCHDOG_ERROR),.xData(BRAM_DATA),.newByte(read_en && man_txd_rdy_pulse),.crc_byte(FCS));
    
                                   
    //==========================WRITE TO BRAM===========================================                               
    //fsm to write to BRAM
    //make sure to check the write_en and write_addr_b signals for timing to ensure correct data is being loaded

    
    txd_write_fsm U_BRAM_WRITING(.clk(clk),.reset(reset | WATCHDOG_ERROR),.XRDY(XRDY),.XWR(XWR),.XSEND(XSEND),.done_transmitting(restart_addr),.wen(write_en),.w_addr(write_addr_b),.done_writing(done_writing));
    
    
    //==========================TRANSMIT===========================================
    //transmit fsm
    
    txd_transmit_fsm U_TRANSMIT_FSM(.clk(clk),.reset(reset | WATCHDOG_ERROR),.start_transmission(start_transmitting),.man_txd_rdy(man_txd_rdy_pulse),
                    .max_data_count(write_addr_b/*the write address will be the last location*/),.FCS(FCS),.pkt_type(pkt_type),.BRAM_data(BRAM_DATA),
                    .data_count(read_addr_b),.man_txd_data(man_txd_data),.read_en(read_en));
    
    
    
endmodule
