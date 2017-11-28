`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2017 08:29:43 PM
// Design Name: 
// Module Name: txd_module_bench
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


module txd_module_bench;

    import check_p::*;

    logic clk;
    logic reset;
    logic [7:0] XDATA;
    logic XWR;
    logic XSEND;
    logic cardet;
//    logic type_2_seen;
    logic ACK_SEEN;
//    logic [7:0] type_2_source;
    logic [7:0] MAC;
    logic XRDY;
    logic [7:0] XERRCNT;
    logic txen;
    logic txd;
    logic [7:0] MAN_DATA;
    logic MAN_RDY;
    
    transmitter_module U_TXD_MOD(.clk(clk), .reset(reset), .XDATA(XDATA), .XWR(XWR), .XSEND(XSEND), 
                                 .cardet(cardet),.ACK_SEEN(ACK_SEEN),/* .type_2_seen(type_2_seen), .type_2_source(type_2_source)*/ 
                                 .MAC(MAC), .XRDY(XRDY), .ERRCNT(XERRCNT), .txen(txen), .txd(txd), .MAN_DATA(MAN_DATA), .MAN_RDY(MAN_RDY));
                                 
     assign XSEND = (XDATA ==8'h04 )&& XWR;//8'h04 is EOT or cntrl-D
     
     //SHREG 256 * 8 (2048) size.  compare data as it comes out. Needs enable signal (single pulsed MAN_RDY)
    
    logic [111:0] data = "ATADEMOSSISIHT";
                  
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    //------------------------------------------------------
    
    task send_one_byte_0;
        while(!XRDY)@(posedge clk);
        XDATA = "*";//dest
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = "0";//type
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = "T";//data
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        //send the packet
        XDATA =8'h04;
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        //wait a clock cycle
        @(posedge clk) #1;
//        while(txen==0)@(posedge clk);
//        while(txen==1)@(posedge clk);
    endtask
    
    //------------------------------------------------------
        
    task send_one_byte_1;
        while(!XRDY)@(posedge clk);
        XDATA = "*";//dest
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = "1";//type
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = "T";//data
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        //send the packet
        XDATA =8'h04;
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        //wait a clock cycle
        @(posedge clk) #1;
        //check_ok("After send is asserted, txen goes high", txen, 1); txen doesnt go high immediately after
        while(txen==0)@(posedge clk);
        while(txen==1)@(posedge clk);
    endtask
    
    //------------------------------------------------------
    
    task send_multiple_bytes;
        integer i;
        while(!XRDY)@(posedge clk);
        XDATA = "*";//dest
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = "0";//type
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        
        for(i = 0; i < 14; i++) begin
            XDATA = data >> (i*8);
            @(posedge clk) #1; 
            XWR = 1;
            @(posedge clk) #1;
            XWR = 0;
            @(posedge clk) #1;
        end
        XDATA =8'h04;
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        //wait a clock cycle
        @(posedge clk) #1;
    endtask
    
//------------------------------------------------------
    
    task send_multiple_bytes_type_2;
        integer i;
        while(!XRDY)@(posedge clk);
        XDATA = "*";//dest
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = "2";//type
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;  
        for(i = 0; i < 14; i++) begin
            XDATA = data >> (i*8);
            @(posedge clk) #1; 
            XWR = 1;
            @(posedge clk) #1;
            XWR = 0;
            @(posedge clk) #1;
        end
        XDATA =8'h04;//send
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        //wait a clock cycle
        @(posedge clk) #1;
    endtask
    
    
//-----------------------------------------------
    
    //------------------------------------------------------
    task wait_for_cardet;
        cardet = 1;
        repeat(100) @(posedge clk);
        send_multiple_bytes;
        repeat(10) @(posedge clk);
        cardet = 0;
        //cause a network busy in the middle of DIFS
        repeat(10) @(posedge clk);
        cardet = 1;
        repeat(10) @(posedge clk);
        cardet = 0;
//        while(txen==0)@(posedge clk);
//        while(txen==1)@(posedge clk);
        
    endtask
        
     //------------------------------------------------------
    task test_watchdog;
        integer i;
        while(!XRDY)@(posedge clk);
        XDATA = "!";//dest
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = "0";//type
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        
        for(i = 0; i < 600; i++) begin
            XDATA = 600-i;
            @(posedge clk) #1; 
            XWR = 1;
            @(posedge clk) #1;
            XWR = 0;
            @(posedge clk) #1;
        end
        XDATA =8'h04;
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        //wait a clock cycle
        @(posedge clk) #1;
        while(txen==0)@(posedge clk);
        while(txen==1)@(posedge clk);
    endtask
    
    
    
    //=================================== TYPE 0 ===================================//
    
    //When reset is asserted, amke sure the transmitter is in the correct state
    task reset_case;
        $display("===================================Testing Simulation test 1===================================");
        //wait 100 clock cycles
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        //check outputs right after 
        @(posedge clk) #1;
        check_ok("On reset, XRDY is high", XRDY, 1);
        check_ok("On reset, XSEND is low", XSEND, 0);
        check_ok("On reset, XWR is low", XWR, 0);
        check_ok("On reset, XERRCNT is set to 0", XERRCNT, 0);
    endtask
    
    task correct_transmission_one_byte;
        $display("===================================Testing Simulation test 2===================================");
        //wait 100 clock cycles
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        send_one_byte_0;
        //after transmission
        while(XRDY)@(posedge clk);
        check_ok("XRDY goes low after transmission XSND is asserted", XRDY, 0);
        while(!txen)@(posedge clk);
        check_ok("TXEN goes high after sending a packet with one byte of data", txen, 1);
    endtask
    
    task correct_transmission_multiple_bytes;
        $display("===================================Testing Simulation test 3===================================");
        //wait 100 clock cycles
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        send_multiple_bytes;
        //after transmission
        while(XRDY)@(posedge clk);
        check_ok("XRDY goes low after transmission XSND is asserted", XRDY, 0);
        while(!txen)@(posedge clk);
        check_ok("TXEN goes high after sending a packet with multiple bytes of data", txen, 1);
    endtask    
    
    task correct_transmission_mutliple_bytes_with_backoff;
        $display("===================================Testing Simulation test 4===================================");
        //wait 100 clock cycles
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        wait_for_cardet;
        //after transmission
        while(XRDY)@(posedge clk);
        check_ok("XRDY goes low after transmission XSND is asserted", XRDY, 0);
        while(!txen)@(posedge clk);
        check_ok("TXEN goes high after sending a packet with multiple of data and a busy network", txen, 1);
    endtask
        
    initial begin
        reset = 1;
        cardet = 0;
        MAC = "@";
        XDATA = 8'h00;
        XWR = 0;
        ACK_SEEN = 0;
        
        repeat(10) @(posedge clk);
        reset = 0;
//        reset_case;
//        correct_transmission_one_byte;
//        correct_transmission_multiple_bytes;
//        correct_transmission_mutliple_bytes_with_backoff;
        repeat(1000)@(posedge clk);
//        $stop;
//        send_one_byte_0;
//        wait_for_cardet;
//        test_watchdog;
//        MAC="#";
//        send_one_byte_1;
//        repeat(1000)@(posedge clk);
//        send_one_byte_1;
        cardet = 1;
        send_multiple_bytes_type_2;
        while(XRDY)@(posedge clk);
        //ACK_SEEN = 1;
        while(!XRDY)@(posedge clk);
        $stop;
    end
endmodule
