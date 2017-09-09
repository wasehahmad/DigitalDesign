//-----------------------------------------------------------------------------
// Title         : bcdcounter
// Project       : ECE 491 - Senior Design 1
//-----------------------------------------------------------------------------
// File          : bcdcounter.sv
// Author        : Waseh Ahmad & Geoff Watson
// Created       : 03.09.2009
// Last modified : 03.09.2009
//-----------------------------------------------------------------------------
// Description : A radix-10 counter with synchronous reset.
// Credit John Nestor
//-----------------------------------------------------------------------------
// Modification history :
// 03.09.2009 : created
// 09.06.2016 : ported to SystemVerilog
//-----------------------------------------------------------------------------

module bcdcounter(
		  input logic        clk, reset, enb,
		  output logic [3:0] Q,
		  output logic       carry
		  );
    parameter COUNT_CEILING = 10;
   assign 	carry = (Q == COUNT_CEILING-1) & enb;
   
   always_ff @( posedge clk )
     begin
	if (reset) Q <= 0;
	else if (enb) 
	  begin
	     if (carry) Q <= 0;
	     else Q <= Q + 1;
	  end
     end
endmodule

