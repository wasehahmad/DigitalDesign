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
    logic [7:0] XDATA,XDATA_PSEUDO,ACT_XDATA;
    logic XWR,XWR_PSEUDO,ACT_XWR;
    logic XSEND;
    logic cardet;
    logic type_2_seen;
    logic ACK_SEEN;
    logic [7:0] type_2_source;
    logic [7:0] MAC;
    logic XRDY;
    logic [7:0] XERRCNT;
    logic txen;
    logic txd;
    logic [7:0] MAN_DATA;
    logic MAN_RDY;
    logic writing_type_3;
    
    logic [7:0] type_data;
    
    //interface for sending acknowledge signals
    ack_interface U_ACK_INTERFACE(.clk(clk),.reset(reset),.send_to(type_2_source),.type_2_received(type_2_seen),.cardet(cardet),.data_out(XDATA_PSEUDO),
                                    .write_type_3(XWR_PSEUDO),.writing_type_3(writing_type_3));
    
    transmitter_module U_TXD_MOD(.clk(clk), .reset(reset), .XDATA(ACT_XDATA), .XWR(ACT_XWR), .XSEND(XSEND), 
                                 .cardet(cardet),.ACK_SEEN(ACK_SEEN),.type_2_seen(type_2_seen), .type_2_source(type_2_source),
                                 .MAC(MAC), .XRDY(XRDY), .ERRCNT(XERRCNT), .txen(txen), .txd(txd), .MAN_DATA(MAN_DATA), .MAN_RDY(MAN_RDY));
                                 
     assign XSEND = (XDATA ==8'h04 || (writing_type_3 && (XDATA_PSEUDO== 8'h04))) && (XWR || (XWR_PSEUDO && writing_type_3));//8'h04 is EOT or cntrl-D
     assign ACT_XWR = writing_type_3?XWR_PSEUDO:XWR;
     assign ACT_XDATA = writing_type_3?XDATA_PSEUDO:XDATA;
     
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
        XDATA = type_data;//type
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
        
        while(txen==0)@(posedge clk) #1;
         
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (preamble)", MAN_DATA, 8'haa);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (SFD)", MAN_DATA, 8'hd0);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (dest)", MAN_DATA, 8'h2a);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (src)", MAN_DATA, MAC);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (type)", MAN_DATA, type_data);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, 8'h54);
        if(type_data != "0")begin
            @(negedge MAN_RDY)
            check_ok("XDATA is put into the buffer (data)", MAN_DATA, 8'h54);//replace with fcs
        end
        while(txen==1)@(posedge clk);
        
    endtask
    
    //------------------------------------------------------
    
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
        XDATA = type_data;//type
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
        @(posedge clk) #1;
        @(posedge clk) #1;
        //for if called from cardet
        if(cardet)begin
            @(posedge clk);
            cardet = 0;
            //cause a network busy in the middle of DIFS
            check_ok("XRDY is low even though network is busy", XRDY, 0);
            check_ok("txen is low because network is busy", txen, 0);
            repeat(10) @(posedge clk);
            cardet = 1;
            repeat(10) @(posedge clk);
            cardet = 0;
        end
        
        //wait a clock cycle
        @(posedge clk) #1;
        while(txen==0)@(posedge clk) #1;
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (preamble)", MAN_DATA, 8'haa);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (SFD)", MAN_DATA, 8'hd0);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (dest)", MAN_DATA, 8'h2a);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (src)", MAN_DATA, MAC);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (type)", MAN_DATA, type_data);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "T");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "H");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "I");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "S");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "I");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "S");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "S");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "O");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "M");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "E");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "D");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "A");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "T");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "A");
        if(type_data != "0")begin
            @(negedge MAN_RDY)
            check_ok("FCS is also sent", MAN_DATA, type_data=="1"?8'hCB:(type_data=="2"?8'h52:8'h00));//replace with fcs
        end
        while(txen==1)@(posedge clk);

    endtask
    
//------------------------------------------------------
task send_multiple_bytes_specific_address;
        integer i;
        while(!XRDY)@(posedge clk);
        XDATA = "!";//dest
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XDATA = type_data;//type
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
        @(posedge clk) #1;
        @(posedge clk) #1;
        //for if called from cardet
        if(cardet)begin
            @(posedge clk);
            cardet = 0;
            //cause a network busy in the middle of DIFS
            check_ok("XRDY is low even though network is busy", XRDY, 0);
            check_ok("txen is low because network is busy", txen, 0);
            repeat(10) @(posedge clk);
            cardet = 1;
            repeat(10) @(posedge clk);
            cardet = 0;
        end

      
        //wait a clock cycle
        @(posedge clk) #1;
        while(txen==0)@(posedge clk) #1;
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (preamble)", MAN_DATA, 8'haa);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (SFD)", MAN_DATA, 8'hd0);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (dest)", MAN_DATA, "!");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (src)", MAN_DATA, MAC);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (type)", MAN_DATA, type_data);
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "T");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "H");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "I");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "S");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "I");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "S");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "S");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "O");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "M");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "E");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "D");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "A");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "T");
        @(negedge MAN_RDY)
        check_ok("XDATA is put into the buffer (data)", MAN_DATA, "A");
        if(type_data != "0")begin
            @(negedge MAN_RDY)
            check_ok("FCS is also sent", MAN_DATA, type_data=="1"?8'hDB:(type_data=="2"?8'h42:8'h00));//replace with fcs
        end
        while(txen==1)@(posedge clk);
        //if type 2, wait for one more transmission
        if(type_data =="2")begin
            while(!txen)@(posedge clk) #1;//wait for at least 256 bit periods 
            check_ok("Attempt transmission again since no ACK_SEEN", txen, 1);
            ACK_SEEN=1;
        end 
        while(txen==1)@(posedge clk);
    endtask
    
//--------------------------------------------------------------     
    task wait_for_cardet;
        cardet = 1;
        repeat(100) @(posedge clk);
        send_multiple_bytes;
    endtask
        
 //------------------------------------------------------
    task test_watchdog;
        integer i;
        $display("===================================WATCHDOG===================================");
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
        
//        for(i = 0; i < 600; i++) begin
//            XDATA = 600-i;
//            @(posedge clk) #1; 
//            XWR = 1;
//            @(posedge clk) #1;
//            XWR = 0;
//            @(posedge clk) #1;
//        end
        XDATA =8'h04;
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        //wait a clock cycle
        @(posedge clk) #1;
        while(!txen)@(posedge clk);
        while(txen)@(posedge clk);
        check_ok("System does not go back to IDLE after WATCHDOG times out", XRDY, 0);
        repeat(100000)@(posedge clk);
        reset = 1;
        repeat(100000)@(posedge clk);
        reset = 0;
        @(posedge clk);
        check_ok("System goes back to IDLE after reset", XRDY, 1);
        repeat(100000)@(posedge clk);
    endtask
    
    //type 1
    //all type 0 tests --> look if FCS is there
    
    //type 2
    //all type 1s + waiting to see an ack (requires 5 times waiting ACK_WAIT)
    
    //type 3
    //send type 3
    //type 2 seen
    
    //=================================== TYPE 0 ===================================//
    
    //When reset is asserted, amke sure the transmitter is in the correct state
    task reset_case;
        $display("===============Testing Simulation test 1==============");
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
        $display("===================Testing Simulation test 2================");
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
        check_ok("XRDY goes high after transmission", XRDY, 1);
        check_ok("TXEN goes low after sending a packet with one byte of data", txen, 0);
    endtask
    
    task correct_transmission_multiple_bytes;
        $display("==============Testing Simulation test 3===============");
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
        check_ok("XRDY goes high after transmission", XRDY, 1);
        check_ok("TXEN goes low after sending a packet with multiple bytes of data", txen, 0);
    endtask    
    
    task correct_transmission_mutliple_bytes_with_backoff;
        $display("=================Testing Simulation test 4==============");
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
        check_ok("XRDY goes high after transmission", XRDY, 1);
        check_ok("TXEN goes low after transmitting a packet with multiple bytes of data with backoff", txen, 0);
    endtask
    
    ///////////////////////////___TYPE_1___///////////////////////////////////////////////////////////////////////
    task correct_transmission_multiple_bytes_different_address;
        $display("===============Testing Simulation test 5=============");
        //wait 100 clock cycles
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        send_multiple_bytes_specific_address;
        //after transmission
        check_ok("XRDY goes high after transmission", XRDY, 1);
        check_ok("TXEN goes low after sending a packet with multiple bytes of data", txen, 0);
    endtask
    
    //========================================================================================
    task correct_type_3;
        $display("===========Testing Simulation test 6=================");
        //wait 100 clock cycles
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        @(posedge clk) #1;
        type_2_source = "@";
        type_2_seen = 1;
        @(posedge clk) #1;
        type_2_seen = 0;
        
        //test for correct transmission of type 3
        while(txen==0)@(posedge clk) #1;
            @(negedge MAN_RDY)
            check_ok("XDATA is put into the buffer (preamble)", MAN_DATA, 8'haa);
            @(negedge MAN_RDY)
            check_ok("XDATA is put into the buffer (SFD)", MAN_DATA, 8'hd0);
            @(negedge MAN_RDY)
            check_ok("XDATA is put into the buffer (dest)", MAN_DATA, type_2_source);
            @(negedge MAN_RDY)
            check_ok("XDATA is put into the buffer (src)", MAN_DATA, MAC);
            @(negedge MAN_RDY)
            check_ok("XDATA is put into the buffer (type)", MAN_DATA, "3");
            @(negedge MAN_RDY)
            check_ok("XDATA is put into the buffer (data)", MAN_DATA, 8'hEB);//replace with fcs
            while(txen==1)@(posedge clk);

        //after transmission
        check_ok("XRDY goes high after transmission", XRDY, 1);
        check_ok("TXEN goes low after sending a packet with multiple bytes of data", txen, 0);
    endtask
    
    
        
    initial begin
        reset = 1;
        cardet = 0;
        MAC = "@";
        XDATA = 8'h00;
        XWR = 0;
        ACK_SEEN = 0;
        type_2_seen = 0;
        type_2_source = 0;
        type_data = 0;
        
        repeat(10) @(posedge clk);
        reset = 0;
        reset_case;
        //Type_0
        $display("===============TYPE_0===============");
        type_data = "0";
        correct_transmission_one_byte;
        correct_transmission_multiple_bytes;
        correct_transmission_mutliple_bytes_with_backoff;
        //Type_1
        type_data = "1";
        repeat(1000)@(posedge clk);
        //change MAC for rest of simulation
        MAC = "n";
        $display("===============TYPE_1===============");
        correct_transmission_multiple_bytes;
        correct_transmission_multiple_bytes_different_address;
        correct_transmission_mutliple_bytes_with_backoff;
        
        type_data = "2";
        repeat(1000)@(posedge clk);
        $display("===============TYPE_2===============");
        correct_transmission_multiple_bytes;
        correct_transmission_multiple_bytes_different_address;
        correct_transmission_mutliple_bytes_with_backoff;

       type_data = "3";
       repeat(1000)@(posedge clk);
       $display("===============TYPE_3===============");
       correct_type_3;

        //test_watchdog;   ---------Already tested this     
        $stop;
    end
endmodule
