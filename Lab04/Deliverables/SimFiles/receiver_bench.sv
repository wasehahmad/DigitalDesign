`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2017 10:07:35 AM
// Design Name: 
// Module Name: receiver_bench
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


module receiver_bench;


  // signals for connecting the counter
      logic clk;
      logic rxd;
      logic reset; 
      logic rdy;
      logic ferr;
      logic [7:0] data;
      logic [7:0] not_data;
      assign not_data = ~data;
   
// instantiate device under verification (counter)
      receiver_top #(.BAUD(9600)) DUV(.clk(clk), .reset(reset), .rxd(rxd), .rdy(rdy), .data(data), .ferr(ferr));
   
     // clock generator with period=20 time units
     always
        begin
       clk = 0;
       #5 clk = 1;
       #5 ;
        end
        
    task send_data_task;
        integer i;
        
        for(i=0;i<5;i++)begin
            rxd = 0;//start
            repeat(10417) @(posedge clk);
            
            rxd = 0;
            repeat(10417) @(posedge clk);
            rxd = 0;
            repeat(10417) @(posedge clk);
            rxd = 0;
            repeat(10417) @(posedge clk);
            rxd = 0;
            repeat(10417) @(posedge clk);
            rxd = 1;
            repeat(10417) @(posedge clk);
            rxd = 1;
            repeat(10417) @(posedge clk);
            rxd = 1;
            repeat(10417) @(posedge clk);
            rxd = 1;
            repeat(10417) @(posedge clk);
            
            rxd = 1;//stop
            repeat(10417) @(posedge clk);
        end
    endtask
   
   
        // initial block generates stimulus
    initial begin
        rxd = 1;
        reset = 0;
        @(posedge clk);
        // do a reset and check that it worked
        reset = 1;
        repeat(1000)@(posedge clk);
        #1;
        reset = 0;
        
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(1000) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        
        
        
        
        //============================== ferr
        rxd = 0;
        #10000000;
        rxd = 1;
        repeat(20417) @(posedge clk);
        
        
        //==============================
        
        
        rxd = 0;//start
        repeat(10417) @(posedge clk);
        
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        
        rxd = 1;//stop
        repeat(10417) @(posedge clk);
        
        rxd = 0;//start
        repeat(10417) @(posedge clk);
        
        rxd = 1;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        
        rxd = 1;//stop
        repeat(20417) @(posedge clk);
        

        send_data_task;

        
        
        rxd = 0;//start
        repeat(10417) @(posedge clk);
        
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 0;
        repeat(10417) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        
        rxd = 0;//stop
        repeat(10417) @(posedge clk);
        rxd = 0;//stop
        repeat(10417) @(posedge clk);
        rxd = 0;//stop
        repeat(10417) @(posedge clk);
        rxd = 1;//stop
        repeat(10417) @(posedge clk);
        
        
        rxd = 0;
        repeat(1000) @(posedge clk);
        rxd = 1;
        repeat(10417) @(posedge clk);
        send_data_task;
        
            
        
        
        
        
        
    end // initial
endmodule    

