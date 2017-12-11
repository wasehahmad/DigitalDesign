`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2017 07:19:23 PM
// Design Name: 
// Module Name: ack_interface
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


module ack_interface #(parameter NUM_BITS = 8*3)(
    input logic clk,
    input logic reset,
    input logic [7:0] send_to,
    input logic type_2_received,
    input logic cardet,
    output logic [7:0] data_out,
    output logic writing_type_3,
    output logic write_type_3
    );
    
    logic [NUM_BITS-1:0] final_data;//store the destination, type and send byte
    logic sending;
    logic [NUM_BITS-1:0] i;
    logic done_sending;
    assign done_sending = i==2'd3;
    
    assign final_data = {8'h04,"3",send_to};
    assign writing_type_3 = sending;
    
    //latch the signal from receiver
    always_ff @(posedge clk)begin
        if(reset | done_sending)sending <=0;
        else if(type_2_received)sending <=1;
    end
    
    always_ff @(posedge clk)begin
        if(reset | done_sending)begin
            data_out <=8'h0;
            write_type_3<=0;
            i<=0;
        end
        else if(sending & !cardet)begin  
            write_type_3 <=1;
            data_out <= final_data>>(i<<3);
            i<=i+1;
        end
    end
    
endmodule
