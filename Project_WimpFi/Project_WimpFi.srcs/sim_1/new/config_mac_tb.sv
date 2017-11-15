`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2017 09:16:40 AM
// Design Name: 
// Module Name: config_mac_tb
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


module config_mac_tb;
    logic clk;
    logic reset;
    logic button_left;
    logic button_right;
    logic button_up;
    logic button_down;
    logic [7:0] src_mac;
    logic [6:0] current_seg;
    
    config_mac_fsm U_MAC_FSM(.clk(clk),.reset(reset), .button_left(button_left), .button_right(button_right),
                             .button_up(button_up), .button_down(button_down), .src_mac(src_mac), .current_seg(current_seg));
    
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    task press_up;
        button_up = 1;
        #11;
        button_up = 0;
    endtask
    
    task press_down;
        button_down = 1;
        #11;
        button_down = 0;
    endtask
    
    task press_left;
        button_left = 1;
        #11;
        button_left = 0;
    endtask
    
    task press_right;
        button_right = 1;
        #11;
        button_right = 0;
    endtask
    
    initial begin
        reset = 1;
        button_up = 0;
        button_left = 0;
        button_right = 0;
        button_down = 0;
        repeat(10) @(posedge clk);
        reset = 0;
        repeat(10) @(posedge clk);
        press_up;
        repeat(10) @(posedge clk);
        press_down;
        repeat(10) @(posedge clk);
        press_left;
        repeat(10) @(posedge clk);
        press_right;
        repeat(10) @(posedge clk);
        
        
    
        $stop;
    end


endmodule