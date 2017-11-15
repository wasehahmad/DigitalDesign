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
    
    logic [13:0] data = "THISISSOMEDATA";
                  
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    //------------------------------------------------------
    
    task send_one_byte;
        XDATA = "T";
        @(posedge clk) #1; 
        XWR = 1;
        @(posedge clk) #1;
        XWR = 0;
        @(posedge clk) #1;
        XSEND = 1;
        @(posedge clk) #1;
        XSEND = 0;
    endtask
    
    //------------------------------------------------------
    
    task send_multiple_bytes;
        integer i;
        for(i = 0; i < 10; i++) begin
            XDATA = data[i];
            @(posedge clk) #1; 
            XWR = 1;
            @(posedge clk) #1;
            XWR = 0;
            @(posedge clk) #1;
        end
        XSEND = 1;
        @(posedge clk) #1;
        XSEND = 0;
    endtask
    
    //------------------------------------------------------

    task 
    
    //=================================== TYPE 0 ===================================//
    
    task reset_case;
        reset = 1;
        repeat(10) @(posedge clk);
        reset = 0;
        check_ok("On reset, XRDY is high", XRDY, 1);
        check_ok("On reset, XSND is low", XSND, 0);
        check_ok("On reset, XWR is low", XWR, 0);
        check_ok("On reset, XERRCNT is set to 0", XERRCNT, 0);
    endtask
    
    initial begin
        reset = 1;
        repeat(10) @(posedge clk);
        reset = 0;
        send_one_byte;

        $stop;
    end
endmodule
