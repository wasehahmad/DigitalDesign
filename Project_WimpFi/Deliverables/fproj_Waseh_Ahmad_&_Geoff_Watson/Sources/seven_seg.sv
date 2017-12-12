//-----------------------------------------------------------------------------
// Title         : Seven segment decoder for Hexadecimal
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : seven_seg.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 21.08.2006
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description
// BCD Seven Segement decoder adapted from David Harris' Verilog tutorial
// Outputs are active low.  Segments have been modified to follow the
// bit ordering of the Nexsys2 board segments[6]=g, segments[0]=a
// Credit to : John Nestor  <johnnest@localhost>
//-----------------------------------------------------------------------------

module seven_seg (
		 input logic [3:0]  data,
		 output logic [6:0] segments  // ordered g(6) - a(0)
		 );
   
   // Output patterns:  gfe_dcba
   parameter BLANK = 7'b111_1111;
   parameter ZERO  = 7'b100_0000;
   parameter ONE   = 7'b111_1001;
   parameter TWO   = 7'b010_0100;
   parameter THREE = 7'b011_0000;
   parameter FOUR  = 7'b001_1001;
   parameter FIVE  = 7'b001_0010;
   parameter SIX   = 7'b000_0010;
   parameter SEVEN = 7'b111_1000;
   parameter EIGHT = 7'b000_0000;
   parameter NINE  = 7'b001_0000;
   parameter A     = 7'b000_1000;
   parameter B     = 7'b000_0011;
   parameter C     = 7'b100_0110;
   parameter D     = 7'b010_0001;
   parameter E     = 7'b000_0110;
   parameter F     = 7'b000_1110;
   
   always_comb
     case (data)
       4'H0: segments = ZERO;
       4'H1: segments = ONE;
       4'H2: segments = TWO;
       4'H3: segments = THREE;
       4'H4: segments = FOUR;
       4'H5: segments = FIVE;
       4'H6: segments = SIX;
       4'H7: segments = SEVEN;
       4'H8: segments = EIGHT;
       4'H9: segments = NINE;
       4'HA: segments = A;
       4'HB: segments = B;
       4'HC: segments = C;
       4'HD: segments = D;
       4'HE: segments = E;
       4'HF: segments = F;
       default: segments = BLANK;
     endcase
endmodule
