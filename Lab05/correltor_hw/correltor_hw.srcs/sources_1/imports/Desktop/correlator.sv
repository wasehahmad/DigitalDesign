//-----------------------------------------------------------------------------
// Title         : Correlator
// Project       : ECE 491 Senior Design 1
//-----------------------------------------------------------------------------
// File          : correlator.sv
// Author        : John Nestor  <nestorj@nestorj-mbpro-15>
// Created       : 22.09.2016
// Last modified : 22.09.2016
//-----------------------------------------------------------------------------
// Description :
// Inputs a sequence of bits on d_in and computes the number matching bits a sequence
// of LEN most recent bits with a PATTERN of the same length.
// Asserts h_out true when the number of matching bits equals or exceeds
// threshold value HTHRESH.
// Asserts l_out true when the number of matching equals or is less than LTHRESH.
//-----------------------------------------------------------------------------
// Modification history :
// 22.09.2016 : created
//-----------------------------------------------------------------------------



module correlator #(parameter LEN=16, PATTERN=16'b0000000011111111, HTHRESH=13, LTHRESH=3, W=$clog2(LEN)+1)(
	      input logic 	   clk,
	      input logic 	   reset,
	      input logic 	   enb,
	      input logic 	   d_in,
	      output logic [W-1:0] csum,
	      output logic 	   h_out,  
	      output logic 	   l_out
	      );
    
    logic [LEN-1:0] shreg, it_matches;
   
    //my function that counts the ones in the input
    function int my_countones(input [LEN-1:0] num_matches);
        int i;
        int ones = 0;
        for(i = 0; i < LEN; i++) begin
            if(num_matches[i] == 1) begin
                ones = ones + 1;
            end
        end
        return ones;
    endfunction
   
    // shift register shifts from right to left so that oldest data is on
    // the left and newest data is on the right
    always_ff  @(posedge clk)
        if (reset) shreg <= '0;
        else if (enb) shreg <= { shreg[LEN-2:0], d_in };
    
        assign it_matches = shreg ^~ PATTERN;
        assign csum = my_countones(it_matches);
        assign h_out = csum >= HTHRESH;
        assign l_out = csum <= LTHRESH;

endmodule














			       ;