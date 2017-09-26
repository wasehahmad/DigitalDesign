`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2017 08:24:26 AM
// Design Name: 
// Module Name: self_check_rxd
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
module self_check_rxd;

    import check_p ::*;
    
    // signals for connecting the counter
    logic        clk;
    logic        reset;
    logic        [7:0] data;
    logic        rxd;
    logic        rdy;
    logic        ferr;
    
    // instantiate device under verification (counter)
    receiver_top #(.BAUD(9600)) DUV(.clk(clk), .reset(reset), .rxd(rxd), .rdy(rdy), .data(data), .ferr(ferr));
    
    // clock generator with period=20 time units
    always begin
    clk = 0;
    #5 clk = 1;
    #5 ;
    end

    //===================================SIM TEST 1==========================================    
    //test initial stsrt state rdy = 0, ferr = 0, data = 8'b00000000
    task check_start_state;
        integer i;
        $display ("START: checking initial start state ---------------------------------------");
        reset = 1;
        rxd = 1;
        repeat(10)@(posedge clk); #1;
        reset = 0;
        for (i = 0; i <= 100; i++) begin
            check_ok("rdy start state check", rdy, 0);
            check_ok("ferr start state check", ferr, 0);
            check_ok("data start state check", data, 8'b11111111);
            repeat(10) @(posedge clk);
        end
        $display ("END: checking initial start state ------------------------------------------");
    endtask
    
    //===================================SIM TEST 2==========================================    
    //test that we ignore a spurious start and rdy and ferr stay low
    task check_spurious_start;
        $display ("START: checking spurious start ---------------------------------------------");
        reset = 1;
        repeat(10)@(posedge clk); #1;
        reset = 0;
        rxd = 1;
        repeat(100)@(posedge clk); #1;
        rxd = 0;
        repeat(4557)@(posedge clk); #1; // 4557 100MHZ clock cycles = 7 16BAUD cycles
        rxd = 1;
        repeat(100)@(posedge clk); #1;
        check_ok("rdy spurious start check", rdy, 0);
        check_ok("ferr spurious start check", ferr, 0);
        check_ok("data spurious start check", data, 8'b11111111);
        $display ("END: checking spurious start -----------------------------------------------");
    endtask
    
    //===================================SIM TEST 3==========================================    
    //test that we send a single byte correctly
    task check_single_byte_reception;
        integer i;
        $display ("START: single byte reception ---------------------------------------------");
        reset = 0;
        rxd = 1;
        repeat(100)@(posedge clk); #1;
        rxd = 0;
        repeat(10417)@(posedge clk); #1;//start bit
        rxd = 1;
        repeat(10417)@(posedge clk); #1;//bit 1
        rxd = 0;
        repeat(10417)@(posedge clk); #1;//bit 2
        rxd = 1;
        repeat(10417)@(posedge clk); #1;//bit 3
        rxd = 0;
        repeat(10417)@(posedge clk); #1;//bit 4
        rxd = 1;
        repeat(10417)@(posedge clk); #1;//bit 5
        rxd = 0;
        repeat(10417)@(posedge clk); #1;//bit 6
        rxd = 1;
        repeat(10417)@(posedge clk); #1;//bit 7
        rxd = 0;
        repeat(10417)@(posedge clk); #1;//bit 8
        rxd = 1;
        repeat(10417)@(posedge clk); #1;//stop bit
        check_ok("rdy spurious start check", rdy, 1);
        check_ok("ferr spurious start check", ferr, 0);
        check_ok("data spurious start check", data, 8'b01010101);
        $display ("END: single byte reception -----------------------------------------------");
    endtask
    
    //=======================================================================================   
    initial begin
        reset = 0;
        check_start_state;
        check_spurious_start;
        check_single_byte_reception
    end
endmodule