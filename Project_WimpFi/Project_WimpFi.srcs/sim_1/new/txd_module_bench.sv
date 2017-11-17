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
    logic clk;
    logic reset;
    logic [7:0] XDATA;
    logic XWR;
    logic XSEND;
    logic cardet;
    logic type_2_seen;
    logic ACK_SEEN;
    logic [7:0] type_2_source;
    logic [7:0] MAC;
    logic XRDY;
    logic [7:0] ERRCNT;
    logic txen;
    logic txd;
    
    transmitter_module U_TXD_MOD(.clk(clk), .reset(reset), .XDATA(XDATA), .XWR(XWR), .XSEND(XSEND), 
                                 .cardet(cardet), .type_2_seen(type_2_seen), .ACK_SEEN(ACK_SEEN), 
                                 .MAC(MAC), .XRDY(XRDY), .ERRCNT(ERRCNT), .txen(txen), .txd(txd));
    
    logic [111:0] data = "THISISSOMEDATA";
                  
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    //------------------------------------------------------
    
    task send_one_byte;
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
        XSEND = 1;
        @(posedge clk) #1;
        XSEND = 0;
        //wait a clock cycle
        @(posedge clk) #1;
        check_ok("After send is asserted, txen goes high", txen, 1);
    endtask
    
    //------------------------------------------------------
    
    task send_multiple_bytes;
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
        integer i;
        for(i = 0; i < 10; i++) begin
            XDATA = data >> (i*8);
            @(posedge clk) #1; 
            XWR = 1;
            @(posedge clk) #1;
            XWR = 0;
            @(posedge clk) #1;
        end
        XSEND = 1;
        @(posedge clk) #1;
        XSEND = 0;
        //wait a clock cycle
        @(posedge clk) #1;
        check_ok("After send is asserted, txen goes high", txen, 1);
    endtask
    
    //------------------------------------------------------

    
    
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
        check_ok("On reset, XRDY is high", XRDY, 1);
        check_ok("On reset, XSND is low", XSND, 0);
        check_ok("On reset, XWR is low", XWR, 0);
        check_ok("On reset, XERRCNT is set to 0", XERRCNT, 0);
    endtask
    
    //When xrdy is high and xwr is asserted, a byte of data is sent to xdata
    task correct_transmission_one_byte;
        $display("===================================Testing Simulation test 2===================================");
        send_one_byte;
        check_ok();
    endtask
    
    initial begin
        reset = 1;
        repeat(10) @(posedge clk);
        reset = 0;
        send_one_byte;

        $stop;
    end
endmodule
