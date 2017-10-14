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



module correlator #(parameter LEN=16, PATTERN=16'b0000000011111111, HTHRESH=13, LTHRESH=3, W=$clog2(LEN)+1,DIGIT = PATTERN[LEN-1])(
	      input logic 	   clk,
	      input logic 	   reset,
	      input logic 	   enb,
	      input logic 	   d_in,
	      output logic [W-1:0] csum,
	      output logic [W-1:0] diff,
	      output logic     speed_up,
	      output logic     slow_down,
	      output logic 	   h_out,  
	      output logic 	   l_out
	      );
    
    logic [LEN-1:0] shreg, it_matches;
    logic pulsed,prev_pulsed;
   
    //my function that counts the ones in the input
    function int my_countones(input [LEN-1:0] num_matches);
        int i;
        static int ones = 0;
        for(i = 0; i < LEN; i++) begin
            if(num_matches[i] == 1) begin
                ones = ones + 1;
            end
        end
        return ones;
    endfunction
    
    //function to get the phase difference 
    function logic [W-1:0] phase_diff(input [LEN-1:0] register);
        //xxx0000000011111 111
        //start in the center location i.e. after the 8th bit from LSB
        static int i;
        static int found = 0;
        logic [W-1:0] count;
        count = 0;
        //static int count;

        //try and find what the relative position of the edge is
        for(i=LEN/2;i>=0 && !found;i-- )begin
            if(register[i] != DIGIT)found = 1;//if edge hasnt been found
            else count++;  
        end
        return count; 
    endfunction
   
    // shift register shifts from right to left so that oldest data is on
    // the left and newest data is on the right
    always_ff  @(posedge clk) begin
        if (reset) begin 
            prev_pulsed <= 0;
            pulsed <= 0;
            shreg <= '0;
        end
        else if (enb)begin
            shreg <= { shreg[LEN-2:0], d_in };
            if(h_out && !prev_pulsed)begin
                pulsed <=1;//register pulsed until l_out mutually exclusive
                prev_pulsed <=1;
            end
            else if(l_out)  prev_pulsed <= 0;//register unpulsed until h_out
            else pulsed<=0;

        end
    end
        //get the diff value for one clock cycles
        assign diff = pulsed?phase_diff(shreg):0;
        assign speed_up  = diff > (LEN-HTHRESH) && pulsed;
        assign slow_down = diff < (LEN-HTHRESH) && pulsed;
        
        assign it_matches = shreg ^~ PATTERN;
        assign csum = my_countones(it_matches);
        assign h_out = csum >= HTHRESH;
        assign l_out = csum <= LTHRESH;
        
        
        
    

endmodule