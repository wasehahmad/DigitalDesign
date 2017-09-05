//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2017 09:16:13 AM
// Design Name: 
// Module Name: rtl_transmitter_bench
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


module rtl_transmitter_bench;

  // signals for connecting the counter
   logic        clk;
   logic        reset;
   logic        send;
   logic        [7:0] data;
   logic        txd;
   logic        rdy;
   
// instantiate device under verification (counter)
      rtl_transmitter #(.BAUD(10000000)) DUV(.clk_100mhz(clk),.reset(reset),.send(send),.data(data),
                          .txd(txd),.rdy(rdy));
   
     // clock generator with period=20 time units
     always
        begin
       clk = 0;
       #5 clk = 1;
       #5 ;
        end
   
   
      // initial block generates stimulus
      initial begin
         reset = 0;
         @(posedge clk);
         // do a reset and check that it worked
         reset = 1;
         send=0;
         @(posedge clk);
         
        #10 reset = 0;
        #10 data = 8'b01010101;
        #1 send = 1;
        #10 send = 0;
        
        repeat(200) @(posedge clk);
        #10 data = 8'b00110011;
        #10 send = 1;
        #10 send = 0;
        repeat(100) @(posedge clk);
        #10 data = 8'b00001111;
        #10 send = 1;
        #10 send = 0;
        repeat(100) @(posedge clk);
        #10 data = 8'b00000000;
        #10 send = 1;
        #10 send = 0;
        repeat(100) @(posedge clk);
        #10 data = 8'b11111111;
        #10 send = 1;
        #10 send = 0;
        repeat(100) @(posedge clk);
         
         $stop();  // all done - suspend simulation
      end // initial
   endmodule    

