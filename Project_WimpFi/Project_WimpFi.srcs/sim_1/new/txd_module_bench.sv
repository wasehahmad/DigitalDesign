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


module txd_module_bench(
    input logic clk,
    input logic reset,
    input logic [7:0] XDATA,
    input logic XWR,
    input logic XSEND,
    input logic cardet,
    input logic type_2_seen,
    input logic ACK_SEEN,
    input logic [7:0] type_2_source,
    input logic [7:0] MAC,
    output logic XRDY,
    output logic [7:0] ERRCNT,
    output logic txen,
    output logic txd
    );
    
    transmitter_module U_TXD_MOD(.clk(clk), .reset(reset), .XDATA(XDATA), .XWR(XWR), .XSEND(XSEND), 
                                 .cardet(cardet), .type_2_seen(type_2_seen), .ACK_SEEN(ACK_SEEN), 
                                 .MAC(MAC), .XRDY(XRDY), .ERRCNT(ERRCNT), .txen(txen), .txd(txd));
                  
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    //=================================== TYPE 0 ===================================//
    task send_one_byte;
        
    endtask;
    
    initial begin
        reset = 1;
        repeat(10) @(posedge clk);
        reset = 0;

        $stop;
    end
endmodule
