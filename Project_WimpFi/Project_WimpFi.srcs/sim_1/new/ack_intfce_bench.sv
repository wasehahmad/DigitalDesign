`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2017 07:48:49 PM
// Design Name: 
// Module Name: ack_intfce_bench
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


module ack_intfce_bench;

    logic clk;
    logic reset;
    logic [7:0] type_2_source;
    logic type_2_seen;
    logic cardet;
    logic [7:0] XDATA_PSEUDO;
    logic writing_type_3;
    logic XWR_PSEUDO;

    ack_interface DUV(.clk(clk),.reset(reset),.send_to(type_2_source),.type_2_received(type_2_seen),.cardet(cardet),.data_out(XDATA_PSEUDO),
                                .write_type_3(XWR_PSEUDO),.writing_type_3(writing_type_3));
                                
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    initial begin
        reset = 1;
        type_2_source = 8'd0;
        cardet = 1;
        type_2_seen = 0;
        
        repeat(100) @(posedge clk);
        #1; reset = 0;
        type_2_source = "!";
        type_2_seen = 1;
        @(posedge clk);
        #1type_2_seen = 0;
        repeat(100) @(posedge clk);
        #1; cardet = 0;
        repeat(100) @(posedge clk);
        
        $stop;
    end
    
    
endmodule
