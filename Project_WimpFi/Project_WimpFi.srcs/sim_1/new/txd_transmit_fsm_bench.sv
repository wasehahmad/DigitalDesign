`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2017 10:34:29 AM
// Design Name: 
// Module Name: txd_transmit_fsm_bench
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


module txd_transmit_fsm_bench;
    
    logic clk;
    logic reset;
    logic start_transmission;
    logic man_txd_rdy;
    logic [7:0] write_addr_b;
    logic [7:0] FCS;
    logic [7:0] pkt_type;
    logic [7:0] BRAM_DATA;
    logic read_addr_b;
    logic [7:0] man_txd_data;
    logic read_en;

    
    txd_transmit_fsm U_TRANSMIT_FSM(.clk(clk),.reset(reset),.start_transmission(start_transmission),.man_txd_rdy(man_txd_rdy),
                                    .max_data_count(write_addr_b/*the write address will be the last location*/),.FCS(FCS),.pkt_type(pkt_type),.BRAM_data(BRAM_DATA),
                                    .data_count(read_addr_b),.man_txd_data(man_txd_data),.read_en(read_en));

    always begin
         clk = 0;
         #5 clk = 1;
         #5;
     end
     
     task transmit_data;
        integer i;
        for(i=0;i<25;i++)begin
            BRAM_DATA = i;
            repeat(10)@(posedge clk);
            #1 man_txd_rdy =1;
            @(posedge clk) #1;
            man_txd_rdy = 0;
               
        end
     
     endtask
     
     
     initial begin
        reset = 1;
        start_transmission = 0;
        man_txd_rdy = 1;
        FCS = 8'hAA;
        pkt_type = "0";
        write_addr_b = 8'd20;
        BRAM_DATA = 8'd1;
        repeat(10) @(posedge clk);
        reset = 0;
        repeat(10) @(posedge clk);
        man_txd_rdy = 0;
        #1;
        start_transmission = 1;
        
        transmit_data;
        $stop;
     
     end

endmodule
