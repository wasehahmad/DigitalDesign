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



module sfd_correl #(parameter LEN=16,RST_PAT= 16'h0000, PATTERN=16'b0000000011111111, HTHRESH=LEN-3, LTHRESH=3, W=$clog2(LEN)+1,DIGIT = PATTERN[LEN-1])(
	      input logic 	   clk,
	      input logic 	   reset,
	      input logic 	   enb,
	      input logic 	   d_in,
	      input logic      cardet,
	      output logic [W-1:0] csum,
	      output logic 	   h_out,  
	      output logic 	   l_out,
	      output logic     corroborating,
	      output logic     write
	      );
    
    logic [LEN-1:0] shreg, it_matches;
    logic pulsed,prev_pulsed;
    assign write = pulsed;
   
    //my function that counts the ones in the input
    function int my_countones(input [LEN-1:0] num_matches); 
        int i;
        int ones;
        ones = 0;
//        $display("num matches = %b", num_matches);
        for(i = 0; i < LEN; i++) begin
            if(num_matches[i] == 1) begin
                ones = ones + 1;
//                $display("ones = %d",ones);
            end
        end
        return ones;
    endfunction
    
   
    // shift register shifts from right to left so that oldest data is on
    // the left and newest data is on the right
    always_ff  @(posedge clk) begin
        if (reset) begin 
            prev_pulsed <= 0;
            pulsed <= 0;
            shreg <= RST_PAT;
        end
        else if (enb)begin
            shreg <= { shreg[LEN-2:0], d_in };
        end
        if(h_out && !prev_pulsed)begin
            pulsed <=1;//register pulsed until l_out mutually exclusive
            prev_pulsed <=1;
        end
        else if(l_out)  prev_pulsed <= 0;//register unpulsed until h_out

        //turn off the pulse after one clock cycle
        if(prev_pulsed)pulsed<=0;
    end
       
        assign it_matches = shreg ^~ PATTERN;
        assign csum = my_countones(it_matches);
        assign h_out = csum >= HTHRESH;
        assign l_out = csum <= LTHRESH;
        
        
        
    

endmodule