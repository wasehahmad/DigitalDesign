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
   
// instantiate device under verification (counter)
      rtl_transmitter #(.BAUD(50000),.BAUD2(100000)) DUV(.clk_100mhz(clk),.reset(reset),.send(send),.data(data),
                          .txd(txd),.rdy(rdy));

    // clock generator with period=20 time units
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end
    
    task check_reset;
          reset = 1;
          @(posedge clk) #1;
          check("reset clears txd",txd,1);
          check("reset clears rdy",txd,1);
          repeat (4) @(posedge clk); #1;
          check("reset holds txd", txd, 1);    
          repeat (3) @(posedge clk); #1;
          check("reset holds Q=0 when enb=1", Q, 0);
          reset = 0;
    endtask //
    
    //test steady state txd = 1, rdy = 1, txen = 0
    
    
    //test data = 8'b00000000
        //test rdy = 0;
        
    
    
        

endmodule
