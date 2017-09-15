module bcdcounter_bench;

   logic [3:0] Q;
   logic       clk, reset, enb;
   logic       carry;

   bcdcounter DUV(.clk, .reset, .enb, .Q, .carry);  // example using ".name" port connections


   import check_p::*;
  
   // clock generator
   always
     begin
	clk = 0;
	#5 clk = 1;
	#5 ;
     end

   // check that a reset sets Q to zero and stays zero if asserted over multiple cycles
   task check_reset;
      reset = 1;
      enb = 0;
      @(posedge clk) #1;
      check("reset clears Q",Q,4'd0);
      check("carry after reset", carry, 0);
      repeat (4) @(posedge clk); #1;
      check("reset holds Q=0 when enb=0", Q, 0);    
      enb = 1;
      repeat (3) @(posedge clk); #1;
      check("reset holds Q=0 when enb=1", Q, 0);
      reset = 0;
   endtask //
   
   // exhaustively check that counter goes through the full sequence
   task  check_count_rollover;
     integer i;
     
     reset = 1;
     @(posedge clk) #1;
     reset = 0;
     for (i=0; i<=9; i++)
        begin
          check("count increment check", Q, i);
          @(posedge clk) #1;
        end
     check("count rollover check", Q, 0);
     @(posedge clk) #1;
     check("increment after rollover", Q, 1);
  endtask
     
  task check_enable;
    reset = 1;
    enb = 0;
    @(posedge clk) #1
    reset = 0;
    enb = 1; 
    repeat (5) @(posedge clk); #1;
    check("counter enable", Q, 5);
    check("counter enable - carry test 1", carry, 0);
    enb = 0;
    repeat (12) @(posedge clk); #1;
    check("counter disabled", Q, 5);
    check("counter enable - carry test 2", carry, 0);
    enb = 1;
    repeat(4) @(posedge clk); #1;
    check("counter enabled at rollover", Q, 9);
    check("carry enabled at rollover", carry, 1);
    #1;
    enb = 0;
    #1;
    check("carry disabled at rollover", carry, 0);
    #1;
    enb = 1;
    #1;
    check("carry enabled at rollover - test 2", carry, 1);
  endtask
     
   initial  begin
      reset = 0;
      enb = 0;
      check_reset;
      check_count_rollover;
      check_enable;
      check_summary_stop; 
   end
   
endmodule // bcdcounter_bench
