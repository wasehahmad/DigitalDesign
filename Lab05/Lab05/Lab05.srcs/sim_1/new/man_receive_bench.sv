`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2017 06:18:17 PM
// Design Name: 
// Module Name: man_receive_bench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module man_receive_bench;

    import check_p ::*;
    
    parameter BAUD = 50000;
    parameter TXD_BAUD = 49500;
    parameter NUM_SAMP = 16;
    parameter SAMP_WIDTH = $clog2(NUM_SAMP);
    parameter WAIT_TIME = 100_000_000/(TXD_BAUD*NUM_SAMP);
    parameter CONST_HIGH = 1600;
    
    logic clk,reset;
    logic rxd,cardet;
    logic [7:0] data;
    logic write, error;
    
    
    man_receiver DUV(.clk(clk),.reset(reset),.rxd(rxd),.cardet(cardet),.data(data),.write(write),.error(error));
    //===================================================
    task send_0;
        integer i;
        for(i=0;i<8;i++)begin
            rxd = 0;
            repeat(WAIT_TIME)@(posedge clk);
        end
        for(i=0;i<8;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
        
    endtask
    //===================================================
    task send_1;
        integer i;
        for(i=0;i<8;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
        for(i=0;i<8;i++)begin
            rxd = 0;
            repeat(WAIT_TIME)@(posedge clk);
        end
            
    endtask
    

    //=================================
    task send_preamble_8;
        //send one bit
        integer i;
        for(i=0;i<4;i++)begin
            send_0;
            send_1;
        end
    endtask
    
    
    //=================================
    task send_sfd;
        send_0;
        send_0;
        send_0;
        send_0;
        send_1;
        send_0;
        send_1;
        send_1;
    endtask
    
    //=================================
    task send_data_byte_10101010;
        send_0;
        send_1;
        send_0;
        send_1;
        send_0;
        send_1;
        send_0;
        send_1;    
    endtask
    
    //=================================
    task send_data_byte_11001100;
        send_0;
        send_0;
        send_1;
        send_1;
        send_0;
        send_0;
        send_1;
        send_1;    
    endtask
    
    //=================================
    task send_data_byte_00001111;
        send_1;
        send_1;
        send_1;
        send_1;
        send_0;
        send_0;
        send_0;
        send_0;    
    endtask


    //====================================
    task send_data_bad_bit;
        integer i;
        send_1;
        send_1;
        send_1;
        send_1;
        send_0;
        
        for(i=0;i<16;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
        send_0;
        send_0;	
    endtask
    
    //====================================
    task send_eof;
        integer i;
        for(i=0;i<32;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
    endtask
    //====================================
    task send_not_enough_data;
        send_1;
        send_1;
        send_1;
        send_1;
        send_0;    
    endtask

    //====================================
    task send_constant_high;
        integer i;
        for(i=0;i<CONST_HIGH;i++)begin
            rxd = 1;
            repeat(WAIT_TIME)@(posedge clk);
        end
    endtask
    
    
    //====================================
    // task to randomly generate rxd
    task random_rxd;
        if ($urandom_range(100,1) <= 50) rxd = 1;
           else rxd = 0;
        
    endtask
    
    
    //====================================
    // Randomly generate rxd for 10^6 bit periods
    task mil_rand_rxd;
        integer i;
        for (i = 0; i < CONST_HIGH; i++) begin
            random_rxd;
            repeat(WAIT_TIME)@(posedge clk);
        end
    endtask


	//=============================================
	task test_reset;
		$display("===================================Testing Simulation test 1===================================");
		//wait 100 clock cycles
		reset = 0;
		repeat(100)@(posedge clk);
		//assert reset for one clock cycle
		#1;
		reset = 1;
		@(posedge clk) #1;
		reset = 0;
		//check outputs right after
		check_ok("write is correct on reset",write,0);
		check_ok("error is correct on reset",error,0);

		check_ok("data is correct on reset",data,8'hxx);

		//check outputs 1000 clock cycles later
		check_ok("write is correct on reset",write,0);
		check_ok("error is correct on reset",error,0);

		check_ok("data is correct on reset",data,8'hxx);
	endtask


	//=============================================
	task test_16PRE_1SFD_1BYTE;

		$display("===================================Testing Simulation test 2===================================");
		reset = 0;
		repeat(100)@(posedge clk);
		//assert reset for one clock cycle
		#1;
		reset = 1;
		@(posedge clk) #1;
		reset = 0;
		rxd = 1; //data will be random  using random generator
		//hold data high at 1
		send_constant_high;

		//send preamble
		check_ok("Cardet is low before 8 bit preamble",cardet,0);
		send_preamble_8;
		@(posedge clk);
		check_ok("Cardet goes high after 8 bit preamble",cardet,1);
		send_preamble_8;
		check_ok("Cardet is still high after 16 bit preamble",cardet,1);
		send_sfd;
		check_ok("Cardet is still high after sfd",cardet,1);
		send_data_byte_11001100;
		check_ok("Write goes high after one byte",write,1);
		send_eof;
		check_ok("Data is as expected 00110011",data,8'b00110011);
		check_ok("Write goes low by EOF",write,0);

		check_ok("Cardet goes low after EOF",cardet,0);
		send_constant_high;

	endtask



	//=============================================
	task test_16PRE_1SFD_3BYTE;

		$display("===================================Testing Simulation test 3===================================");
		reset = 0;
		repeat(100)@(posedge clk);
		//assert reset for one clock cycle
		#1;
		reset = 1;
		@(posedge clk) #1;
		reset = 0;
		rxd = 1; //data will be random  using random generator
		//hold data high at 1
		send_constant_high;

		//send preamble
		check_ok("Cardet goes is low before 8 bit preamble",cardet,0);
		send_preamble_8;
		@(posedge clk);
		check_ok("Cardet goes high after 8 bit preamble",cardet,1);
		send_preamble_8;
		check_ok("Cardet is still high after 16 bit preamble",cardet,1);
		send_sfd;
		check_ok("Cardet is still high after sfd",cardet,1);
		send_data_byte_11001100;
		check_ok("Write goes high after one byte",write,1);
		check_ok("Data is as expected 00110011",data,8'b00110011);
		send_data_byte_10101010;
		check_ok("Write goes high after second byte",write,1);
		check_ok("Data is as expected 01010101",data,8'b01010101);
		send_data_byte_00001111;
		check_ok("Write goes high after third byte",write,1);
		check_ok("Data is as expected 11110000",data,8'b11110000);
		send_eof;
		check_ok("Write goes low by EOF",write,0);

		check_ok("Cardet goes low by EOF",cardet,0);
		send_constant_high;

	endtask
	
//=================================================================
    task test_16PRE_1SFD_RAND;
    
        $display("===================================Testing Simulation test 4===================================");
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        //send data randomly for 106 bits
        mil_rand_rxd; 
        check_ok("No preamble was detected during reception of random bits", cardet,0);
        //send preamble
        check_ok("Cardet goes is low before 8 bit preamble",cardet,0);
        send_preamble_8;
        @(posedge clk);
        check_ok("Cardet goes high after 8 bit preamble",cardet,1);
        send_preamble_8;
        check_ok("Cardet is still high after 16 bit preamble",cardet,1);
        send_sfd;
        check_ok("Cardet is still high after sfd",cardet,1);
        send_data_byte_11001100;
        check_ok("Write goes high after one byte",write,1);
        check_ok("Data is as expected 00110011",data,8'b00110011);
        send_eof;
        check_ok("Write goes low by EOF",write,0);

        check_ok("Cardet goes low after EOF",cardet,0);
        //send data randomly for 106 bits
        mil_rand_rxd; 
        check_ok("No preamble was detected during reception of random bits", cardet,0);
    endtask
    
    //=================================================================
    task test_16PRE_1SFD_BAD_BIT;
    
        $display("===================================Testing Simulation test 5===================================");
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        //send data randomly for 106 bits
        mil_rand_rxd; 
        check_ok("No preamble was detected during reception of random bits", cardet,0);
        //send preamble
        check_ok("Cardet goes is low before 8 bit preamble",cardet,0);
        send_preamble_8;
        @(posedge clk);
        check_ok("Cardet goes high after 8 bit preamble",cardet,1);
        send_preamble_8;
        check_ok("Cardet is still high after 16 bit preamble",cardet,1);
        send_sfd;
        check_ok("Cardet is still high after sfd",cardet,1);
        send_data_bad_bit;
        check_ok("Error goes high when the bad bit is seen",error,1);
        check_ok("Cardet has gone low after error", cardet,0);
        send_eof;
        check_ok("Write goes low by EOF",write,0);
        check_ok("Cardet goes low by EOF",cardet,0);

        check_ok("Error is still high after EOF",error,1);
        //send data randomly for 106 bits
        mil_rand_rxd; 
        check_ok("No preamble was detected during reception of random bits", cardet,0);
    endtask
    
    //==================================================================
    task test_16PRE_1SFD_NOT_ENOUGH_DATA;
    
        $display("===================================Testing Simulation test 6===================================");
        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        //send data randomly for 106 bits
        mil_rand_rxd; 
        check_ok("No preamble was detected during reception of random bits", cardet,0);
        //send preamble
        check_ok("Cardet goes is low before 8 bit preamble",cardet,0);
        send_preamble_8;
        @(posedge clk);
        check_ok("Cardet goes high after 8 bit preamble",cardet,1);
        send_preamble_8;
        check_ok("Cardet is still high after 16 bit preamble",cardet,1);
        send_sfd;
        check_ok("Cardet is still high after sfd",cardet,1);
        //send only 5 bits of data
        send_not_enough_data;
        send_eof;

        check_ok("Error goes high when the EOF is seen",error,1);
        //send data randomly for 106 bits
        mil_rand_rxd; 
        check_ok("No preamble was detected during reception of random bits", cardet,0);
    endtask


   
       // clock generator
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end
    
    initial begin
        reset = 1;
        repeat(1000)@(posedge clk); #1;
        reset = 0;
        
        test_reset;
        test_16PRE_1SFD_1BYTE;
        test_16PRE_1SFD_3BYTE;
        test_16PRE_1SFD_RAND;
        test_16PRE_1SFD_BAD_BIT;
        test_16PRE_1SFD_NOT_ENOUGH_DATA;
        
        $stop;

    end    
    

endmodule
