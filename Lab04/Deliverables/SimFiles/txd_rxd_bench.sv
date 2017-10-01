`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Waseh Ahmad & Geoff Watson
// 
// Create Date: 09/21/2017 10:06:58 PM
// Design Name: 
// Module Name: txd_rxd_bench
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
// Test bench to check the correct transmission of data from an asynchronous transmitter to an asynchronous receiver
//////////////////////////////////////////////////////////////////////////////////


module txd_rxd_bench;  // signals for connecting the counter
      logic clk;
      logic rxd;
      logic reset; 
      logic rdy;
      logic ferr;
      logic [7:0] rxd_data;
      logic send;
      logic [7:0] txd_data;
      logic txd_rdy;
     
   
// instantiate device under verification (counter)
      receiver_top  DUV(.clk(clk), .reset(reset), .rxd(rxd), .rdy(rdy), .data(rxd_data), .ferr(ferr));
      
      rtl_transmitter U_TXD(.clk_100mhz(clk),.reset(reset),.send(send),.data(txd_data),.txd(rxd),.rdy(txd_rdy));
   
     // clock generator with period=20 time units
     always
        begin
       clk = 0;
       #5 clk = 1;
       #5 ;
        end



    task check_rxd_txd;
        assert(rdy==1)$display("New data is ready to be received");
        assert (rxd_data == txd_data) $display ("Received Data is the same as Transmittd data %b",rxd_data);
        assert (ferr == 0)$display ("No Framing Error occurred at this transmission");

    endtask
    
    task check_reset_state;
        assert(rdy==0)$display("Ready is low at the very beginning when no data has been transferred");
        assert (rxd_data == 8'hff) $display ("Received data is high at 0xFF");
        assert (ferr == 0)$display ("No Framing Error occurred at the beginning");
    
    endtask
   
   
        // initial block generates stimulus
    initial begin
        reset = 0;
        @(posedge clk);
        // do a reset and check that it worked
        reset = 1;txd_data = 8'b00000000;
        repeat(1000)@(posedge clk);
        #1;
        reset = 0;
        @(posedge clk)check_reset_state;
        
        repeat(100000)@(posedge clk);
        
        //check one byte transfer
        txd_data = 8'h88;
        send = 1;
        
        repeat(10417*5)@(posedge clk);
        send = 0;
        repeat(10417*5)@(posedge clk);

        @(posedge clk);
        check_rxd_txd;
        
        //wait for a period of time before sending again
        repeat(10417*10)@(posedge clk);
        
        //check multiple byte transfer
        send = 1;
        txd_data = 8'b01010101;
        repeat(10417*10)@(posedge clk);
        @(posedge clk);check_rxd_txd;
        
        txd_data = 8'b00110011;       
        repeat(10417*10)@(posedge clk);
        @(posedge clk);check_rxd_txd;
        
        txd_data = 8'b00001111;                
        repeat(10417*10)@(posedge clk);
        @(posedge clk);check_rxd_txd;
        
        send = 0;
        
        
            
        
        
        
        
        
    end // initial
endmodule    

