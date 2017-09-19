//-----------------------------------------------------------------------------
// Title         : Variable Width register
// Project       : ECE 491 - Senior Design Project 1
//-----------------------------------------------------------------------------
// File          : reg_param.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 21.08.2006
// Last modified : 22.07.2016
//-----------------------------------------------------------------------------
// Description
// Register to store a value.
// Credit to : John Nestor  <johnnest@localhost>
//-----------------------------------------------------------------------------

module reg_param #(parameter W=4) (
		input logic          clk,
		input logic          reset,
		input logic          lden,
		input logic [W-1:0]  d,
		output logic [W-1:0] q
		);

  always_ff @(posedge clk)
    if (reset) q <= '0;
    else if (lden) q <= d;
	 
endmodule
