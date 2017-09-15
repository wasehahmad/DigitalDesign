`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2017 10:34:47 AM
// Design Name: 
// Module Name: rtl_transmitter_self_check_bench
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


module rtl_transmitter_self_check_bench;

    import check_p ::*;

  // signals for connecting the counter
   logic        clk;
   logic        reset;
   logic        send;
   logic        [7:0] data;
   logic        txd;
   logic        rdy;
   logic        txen;
   
// instantiate device under verification (counter)
      rtl_transmitter #(.BAUD(50000),.BAUD2(100000)) DUV(.clk_100mhz(clk),.reset(reset),.send(send),.data(data),
                          .txd(txd),.rdy(rdy), .txen(txen));

    // clock generator with period=20 time units
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end
    
    //test steady state txd = 1, rdy = 1, txen = 0
    task check_no_transmission;
        integer i;
        
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        for (i = 0; i <= 100; i++) begin
            check_ok("txen no transmission check", txen, 0);
            check_ok("rdy no transmission check", rdy, 1);
            check_ok("txd no transmission check", txd, 1);
            repeat(10) @(posedge clk);
        end
    endtask
    
    task check_ready;
        integer i;
        
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        send = 1;
        data = 8'b01010101;
        @(posedge clk);
        #1;
        check_ok("Ready goes low on send", rdy, 0);
        for(i = 0; i <= 6; i++) begin
            check_ok("Ready is low during transmission of first 7 bits", rdy, 0);
            repeat(2000) @(posedge clk);
        end
        send = 0;
        // Wait one clock cycle to get past the edge between bit 7 and 8
        repeat(2000) @(posedge clk); #1;
        for(i = 0; i <= 1; i++) begin
            check_ok("Ready is high during transmission of the last bit", rdy, 1);
            repeat(1000) @(posedge clk);
        end
    endtask

    
    initial begin
        reset = 0;
        send = 0;
        check_no_transmission;
        check_ready;
    end
    
    
    
    //test data = 8'b00000000
        //test rdy = 0;
        
    
    
        

endmodule
