`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2017 08:09:47 AM
// Design Name: 
// Module Name: man_txd_rxd_bench
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


module man_txd_rxd_bench_slow;

    parameter BAUD = 50000;
    parameter TXD_BAUD = 49500;
    parameter NUM_SAMP = 16;
    parameter SAMP_WIDTH = $clog2(NUM_SAMP);
    parameter WAIT_TIME = 100_000_000/(TXD_BAUD*NUM_SAMP);

    import check_p ::*;

    // signals for connecting the counter
    logic        clk;
    logic        reset;
    logic        send;
    logic        [7:0] data_txd;
    logic        txd;
    logic        rdy;
    logic        txen;
    logic rxd,cardet;
    logic [7:0] data_rxd;
    logic write, error;     


    // instantiate device under verification (counter)
    rtl_transmitter #(.BAUD(TXD_BAUD),.BAUD2(2*TXD_BAUD)) DUV_TXD(.clk_100mhz(clk),.reset(reset),.send(send),.data(data_txd),
                          .txd(txd),.rdy(rdy), .txen(txen));
                          
    man_receiver #(.BAUD(BAUD)) DUV_RXD(.clk(clk),.reset(reset),.rxd(data_txd),.cardet(cardet),.data(data_rxd),.write(write),.error(error));
                
    
          
    always begin
      clk = 0;
      #5 clk = 1;
      #5 ;
    end
    
    task send_preamble;
        reset = 0;
        @(posedge clk) #1;
        reset = 1;
        
        data_txd = 8'b10101010;
        send = 1;
        //send the preamble
        repeat(WAIT_TIME*16*8)@(posedge clk);
        repeat(WAIT_TIME*16*8)@(posedge clk);
        repeat(WAIT_TIME*16*8)@(posedge clk);
        repeat(WAIT_TIME*16*8)@(posedge clk);
        check_ok("Cardet is asserted high",cardet,1);
        data_txd = 8'b11010000;
        repeat(WAIT_TIME*16*8)@(posedge clk);
    
    endtask
    
    task send_one_byte;
      data_txd = 8'b11001100;
      repeat(WAIT_TIME*16*8)@(posedge clk);
      check_ok("Data transmitted is data received",data_rxd,data_rxd);
    
    endtask
    
    task send_multi_bytes;
        integer i;
        for(i=0;i<256;i++)begin
            data_txd = i[7:0];
            repeat(WAIT_TIME*16*8)@(posedge clk);
            check_ok("Data transmitted is data received",data_rxd,data_rxd);
        end
    endtask
    
    task send_ten_random_num_bytes;
        integer i,j,rand_num;
        for (i = 0; i < 10; i++) begin
            rand_num  = $urandom_range(255,2);
            for (j = 0; j < rand_num; j++) begin
                data_txd = j[7:0];
                repeat(WAIT_TIME*16*8)@(posedge clk);
                check_ok("Data transmitted is data received",data_rxd,data_rxd);
            end
        
            //check that rand number of bytes have been transmitted without an error
            repeat(100)@(posedge clk);
            check_ok("Check random number of bytes transmission without error",error,0);
            check_ok("Check random number of bytes transmission cardet low",cardet,0);
        end
    endtask    
    
    initial begin
        reset = 1;
        repeat(1000)@(posedge clk); #1;
        reset = 0;
        send_preamble;
        send_one_byte;
        
        reset = 1;
        repeat(1000)@(posedge clk); #1;
        reset = 0;
        send_preamble;
        send_multi_bytes;
        
        reset = 1;
        repeat(1000)@(posedge clk); #1;
        reset = 0;
        send_preamble;
        send_ten_random_num_bytes;
        
        
        $stop;
    
    end 
    
      

endmodule
