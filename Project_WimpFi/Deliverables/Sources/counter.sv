`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
// Title         : Counter
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : counter.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 21.08.2006
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description
// Multiplexer with a parameter for the input width.
// Assigns a default of 8 values (3 bit width)
// Credit to : John Nestor  <johnnest@localhost>
//-----------------------------------------------------------------------------
module counter #(parameter W=4) (
		     input logic clk, rst, en,
		     output logic [W-1:0] Q,
		     output logic carry
		     );

   always_ff @(posedge clk)
     if (rst) Q <= '0;
     else if (en) Q <= Q + 1;

   assign carry = (Q == '1);  // fills to all 1's
      
endmodule // counter_parm