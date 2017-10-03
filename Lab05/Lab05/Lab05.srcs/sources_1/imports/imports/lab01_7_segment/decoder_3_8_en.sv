//-----------------------------------------------------------------------------
// Title         : 3_8_decoder
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : decoder_3_8_en.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 21.08.2006
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description
// Multiplexer which converts a 3 bit input to a specific output.
// The output is based on the anode display of the FPGA board
// Credit to John Nestor for original Design
//
//-----------------------------------------------------------------------------

module decoder_3_8_en(
		      input logic [2:0] a,
		      input logic enb,
		      output logic [7:0] y
		      );
   
   always_comb begin
      if (enb) begin
	 case (a)
           3'd0 : y = 8'b11111110;
           3'd1 : y = 8'b11111101;
	       3'd2 : y = 8'b11111011;
           3'd3 : y = 8'b11110111;
           3'd4 : y = 8'b11101111;
           3'd5 : y = 8'b11011111;
           3'd6 : y = 8'b10111111;
           3'd7 : y = 8'b01111111;
	 endcase
      end // if (enb)
      else y = 8'b00000000;
   end // always_comb

endmodule // decoder_3_8_en

   
   