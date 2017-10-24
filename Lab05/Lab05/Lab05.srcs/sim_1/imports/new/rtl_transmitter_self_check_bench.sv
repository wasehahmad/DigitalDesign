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

    //=======================================================================================    
    //test steady state txd = 1, rdy = 1, txen = 0
    task check_no_transmission;
        integer i;
        
        reset = 1;
        repeat(10)@(posedge clk); #1;
        reset = 0;
        for (i = 0; i <= 100; i++) begin
            check_ok("txen no transmission check", txen, 0);
            check_ok("rdy no transmission check", rdy, 1);
            check_ok("txd no transmission check", txd, 1);
            repeat(10) @(posedge clk);
        end
    endtask

    //=======================================================================================    
    task check_ready;
        integer i;
        
        reset = 1;
        repeat(10)@(posedge clk); #1;
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
//=======================================================================================    
    task check_txen;
        integer i;
                
        reset = 1;
        repeat(10)@(posedge clk); #1;
        reset = 0;
        check_ok("TXEN is low before send is first asserted", txen, 0);  
        send = 1;
        data = 8'b00000000;
        @(posedge clk);
        #1;
        check_ok("TXEN goes high after send is asserted", txen, 1);
        send = 0;   
        //check that txen goes high 
        for(i=0;i<7;i++)begin //check that it remains high till the end of the last bit
            repeat(2000) @(posedge clk); #1;
            check_ok("TXEN stays high for all the bits", txen, 1);
        end
        do begin
            #1;
        end while(rdy==0);//move to the beginning of last bit
        for(i=0;i<3;i++)begin
            check_ok("TXEN stays high for last bit and EOF", txen, 1);
            repeat(2000) @(posedge clk); #1;
        end
        @(posedge clk) #1;
        check_ok("TXEN is low after EOF", txen, 0);
         
    endtask
//=======================================================================================   


    task check_txd;
        integer i;
                        
        reset = 1;
        repeat(10)@(posedge clk); #1;
        reset = 0;
        #1;
        data = 8'b10101010;
        send = 1;
        //check first half is low, second half is high
        @(posedge clk);
        #1; send =0; i=0;
        do begin
            @(posedge clk);i++;
            check("TXD is low first for a 0 bit",txd,0);             
        end while(i<=1000);
        @(posedge clk); #1;
        i=0;//reset i
        do begin
            @(posedge clk);i++;
            check("TXD is high second for a 0 bit",txd,1);             
        end while(i<=1000);
        i=0;//reset i
        do begin
            
            check("TXD is high First for a 1 bit",txd,1);
            @(posedge clk);i++;             
        end while(i<1000);
        i=0;//reset i
        do begin
            
            check("TXD is low second for a 1 bit",txd,0);  
            @(posedge clk);i++;           
        end while(i<1000);
        
    endtask
//=======================================================================================   

    task check_consecutive_bytes;
        integer count;
                        
        reset = 1;
        repeat(1000)@(posedge clk); #1;
        reset = 0;
        #1;
        data = 8'b10101010;
        send = 1;
        @(posedge clk);
        #1; count = 0;
        do begin
            count++;
            @(posedge clk);                
        end while(rdy == 0);
        do begin
            count++;
            @(posedge clk);                
        end while(rdy == 1);
        assert(count > 15990 && count <16010);$display ("OK. One byte transmission takes approximately 16000 clock cycles");//20 clock cycle error window
        do begin
            count++;
            @(posedge clk);                
        end while(rdy == 0);
        do begin
            count++;
            @(posedge clk);                
        end while(rdy == 1);
        @(posedge clk);
        assert(count > 31990 && count <32010);$display ("OK. Two byte transmission takes approximately 32000 clock cycles");//20 clock cycle error window

    
    endtask 
 
 
 
//=======================================================================================   
    initial begin
        reset = 0;
        send = 0;
        check_no_transmission;
        check_ready;
        check_txen;
        check_txd;
        check_consecutive_bytes;
    end
    
    
    
    //test data = 8'b00000000
        //test rdy = 0;
        
    
    
        

endmodule
