//-----------------------------------------------------------------------------
// Title         : bcdcounter
// Project       : ECE 491 - Senior Design 1
//-----------------------------------------------------------------------------
// File          : bcdcounter.sv
// Author        : John Nestor
// Created       : 03.09.2009
// Last modified : 03.09.2009
//-----------------------------------------------------------------------------
// Description : A radix-10 counter with synchronous reset.
// 
//-----------------------------------------------------------------------------
// Modification history :
// 03.09.2009 : created
// 09.06.2016 : ported to SystemVerilog
//-----------------------------------------------------------------------------

module bcdcounter #(parameter LAST_VAL = 10, W =$clog2(LAST_VAL)+1 )(
		  input logic        clk, reset, enb,
		  output logic [W-1:0] Q,
		  output logic       carry
		  );

   assign 	carry = (Q == LAST_VAL-1) & enb;
   
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

