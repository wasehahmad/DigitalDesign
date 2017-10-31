`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Lafayette College
// Engineer: Ian Miller, Peter Phelan
// 
// Create Date: 10/22/2017 11:35:25 PM
// Design Name: 
// Module Name: direct_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Test receiver directly.  Tests for error handling and other problems
//              Transmitter: BIT_RATE
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

import check_p::*;

module ian_peter_test_bench;
    //3125000 is the max bit rate
    parameter BIT_RATE = 50_000;
    parameter CLOCK_SPEED = 100_000_000;

    //DUT Inputs
    logic clk;
    logic reset;
    logic rxd;
    //DUT outputs
    logic cardet;
    logic write;
    logic error;
    logic [7:0] data;
    
    
    //DUT (running at clock speed)
    man_receiver #(.BIT_RATE(BIT_RATE)) DUT(.clk(clk), .reset(reset), .rxd(rxd), .cardet(cardet), .write(write), .error(error), .data(data));
    
    //Generate clock
    always begin
       clk = 0;
       #8 clk = 1;
       #8;
    end
    
    //Queues to keep track of sent and received data
    logic [7:0] send_queue[$];
    logic [7:0] recv_queue[$];
    int recv_cnt = 0;
    
    //Counter for number of errors recorded
    int error_cnt = 0;
    //number of cardet jumps.  Use this to effectively check that cardet didn't change
    int cardet_cnt = 0;
    
    //Read new data into queue when write goes high
    logic last_write = 0;
    logic last_error = 0;
    logic last_cardet = 0;
    logic rst_queues = 0;
    always @(posedge clk) begin
        if (rst_queues) begin
            error_cnt <= 0;
            recv_cnt <= 0;
            cardet_cnt <= 0;
            while (recv_queue.size > 0)
                recv_queue.pop_front();
            while (send_queue.size > 0)
                send_queue.pop_front();
        end else begin
            //Read data
            if (write && ~last_write) begin
                recv_queue.push_front(data);
                recv_cnt <= recv_cnt + 1;
            end
            last_write <= write;
            
            //Count errors
            if (error && ~last_error) begin
                error_cnt <= error_cnt + 1;
            end
            last_error <= error;
            
            //count cardets
            if (cardet && ~last_cardet) begin
                cardet_cnt <= cardet_cnt + 1;
            end
            last_cardet <= cardet;
        end
    end
    
    //Reset DUT so we start in known state
    task reset_dut;
        rxd = 1'b1;
        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        @(posedge clk) #1;
    endtask
    
    //Reset queues (variables for test purposes
    task reset_queues;
        rst_queues = 1;
        @(posedge clk);
        rst_queues = 0;
    endtask
    
    //Transmit single manchester encoded bit (like a boss)
    task tx_man_bit(input logic a);
        rxd = a;
        repeat ((CLOCK_SPEED/BIT_RATE)/2) @(posedge clk);
        rxd = ~a;
        repeat ((CLOCK_SPEED/BIT_RATE)/2) @(posedge clk);
    endtask
    
    //Transmit a stop bit for n periods
    task tx_stop(input int n);
        for (int i=0; i<n; i++) begin
            rxd = 1;
            repeat((CLOCK_SPEED/BIT_RATE)) @(posedge clk);
        end
    endtask
    
    //Transmit n bits of preamble
    task tx_preamble(input int n);
        for (int i=0; i<(n/2); i++) begin
            tx_man_bit(1'b1);
            tx_man_bit(1'b0);
        end
    endtask
    
    //Transmit 8 bit start frame delimeter
    task tx_sfd;
        tx_man_bit(1'b0);
        tx_man_bit(1'b0);
        tx_man_bit(1'b0);
        tx_man_bit(1'b0);
        tx_man_bit(1'b1);
        tx_man_bit(1'b0);
        tx_man_bit(1'b1);
        tx_man_bit(1'b1);
    endtask
    
    //Transmit 8 bits
    task tx_byte(input logic [7:0] d);
        send_queue.push_front(d);
        for (int i=0; i<8; i++) begin
            tx_man_bit(d[i]);
        end
    endtask
    
    //Verify data all received correctly
    task check_data;
        for (int i = send_queue.size-1; i >= 0; i--)
            check("Valid data", send_queue[i], recv_queue[i]);
    endtask
    
    //Generate random input for n bit periods
    task tx_random_input(input int n);
        //Iterate sending bits
        for (int bits=0; bits<n; bits++) begin
            //16 random values/bit
            for (int s=0; s<16; s++) begin
                rxd = $random;
                repeat((CLOCK_SPEED/BIT_RATE)/16) @(posedge clk);
            end
        end
    endtask
    
    task check_test_1();
        reset_queues();
        check_group_begin("Checking single byte transmission (test 1)");
        tx_preamble(16);
        check_ok("Verify carrier detected (test 1b)", cardet, 1);
        tx_sfd;
        //transmit data
        tx_byte(8'hAA);
        check_ok("Verify cardet still high (test 1c)", cardet, 1);
        //transmit EOF
        tx_stop(2);
        check_ok("Verify cardet low (test 1c)", cardet, 0);
        check_ok("Verify 1 byte received (test 1d)", recv_cnt, 1);
        check_ok("Verify data valid (test 1d)", recv_queue[0], 8'hAA);
        check_ok("Verify no errors (test 1e)", error_cnt, 0);
        check("Verify cardet only transitioned once", cardet_cnt, 1);
        check_group_end;
    endtask;
    
    task check_test_2();
        reset_queues();
        check_group_begin("Checking multiple byte transmission (test 2)");
        tx_preamble(16);
        check_ok("Verify carrier detected (test 2b)", cardet, 1);
        tx_sfd;  
        //transmit data
        tx_byte(8'hAA);
        tx_byte(8'hFF); 
        tx_byte(8'h55); 
        tx_byte(8'h00); 
        tx_byte(8'h0F); 
        tx_byte(8'hF0); 
        check_ok("Verify cardet still high (test 1c)", cardet, 1);
        //transmit EOF
        tx_stop(2);
        check_ok("Verify cardet low (test 1c)", cardet, 0);
        check_ok("Verify 1 byte received (test 1d)", recv_cnt, 6);
        //Check data valid
        check_data;
        check_ok("Verify no errors (test 1e)", error_cnt, 0);
        check("Verify cardet only transitioned once", cardet_cnt, 1);
        check_group_end;
    endtask
    
    task check_test_3();
        reset_queues();
        check_group_begin("Checking random input ignored (test 3)");
        tx_random_input(1000000);
        tx_preamble(16);
        check_ok("Verify carrier detected (test 3c)", cardet, 1);
        tx_sfd;
        //transmit data
        tx_byte(8'hAA);
        check_ok("Verify cardet still high (test 3d)", cardet, 1);
        //transmit EOF
        tx_stop(2);
        check_ok("Verify 1 byte received (test 3e)", recv_cnt, 1);
        tx_random_input(1000000);
        check_ok("Verify cardet low (test 3d)", cardet, 0);
        check_ok("Verify no other data (test 3f)", recv_cnt, 1);
        check_ok("Verify data valid (test 1d)", recv_queue[0], 8'hAA);
        check("Verify no errors", error_cnt, 0);
        check_ok("Verify cardet only transitioned once (test 3b)", cardet_cnt, 1);
        check_group_end;
    endtask
    
    task check_test_4();
        reset_queues();
        check_group_begin("Send low rxd for bit duration (test 4)");
        tx_preamble(16);
        check_ok("Verify carrier detected (test 4c)", cardet, 1);
        tx_sfd;  
        //transmit data
        tx_byte(8'hAA);
        tx_byte(8'hFF);
        rxd = 1'b0;
        repeat (CLOCK_SPEED/BIT_RATE) @(posedge clk);
        rxd = 1'b1;
        repeat ((CLOCK_SPEED/BIT_RATE)/2) @(posedge clk);
        check_ok("Error asserted (test 4b)", error, 1);
        check_ok("Cardet deasserted (test 4c)", cardet, 0);
        tx_random_input(20);
        check_ok("Error still asserted (test 4d)", error, 1);
        
        //Tx valid packet
        tx_preamble(16);
        check_ok("Verify carrier detected (test 4e)", cardet, 1);
        check_ok("Verify error cleared (test 4e)", cardet, 1);
        tx_sfd;
        //transmit data
        tx_byte(8'hAA);
        check("Verify cardet still high", cardet, 1);
        //transmit EOF
        tx_stop(2);
        check("Verify cardet low", cardet, 0);
        check("Verify 3 bytes received", recv_cnt, 3);
        check("Verify data valid", recv_queue[0], 8'hAA);
        check("Verify only 1 error", error_cnt, 1);
        check("Verify cardet only transitioned twice", cardet_cnt, 2);
        check_group_end;
    endtask
    
    task check_test_5();
        reset_queues();
        check_group_begin("Terminate transmission early (test 5)");
        tx_preamble(16);
        check_ok("Verify carrier detected (test 5c)", cardet, 1);
        tx_sfd;  
        //transmit data
        tx_byte(8'hAA);
        tx_man_bit(1'b1);
        tx_man_bit(1'b1);
        tx_man_bit(1'b1);
        tx_man_bit(1'b1);
        rxd = 1'b1;
        repeat (2*CLOCK_SPEED/BIT_RATE) @(posedge clk);
        check_ok("Error asserted (test 5b)", error, 1);
        check_ok("Cardet deasserted (test 5c)", cardet, 0);
        tx_random_input(20);
        check_ok("Error still asserted (test 5d)", error, 1);
        
        //Tx valid packet
        tx_preamble(16);
        check_ok("Verify carrier detected (test 5e)", cardet, 1);
        check_ok("Verify error cleared (test 5e)", cardet, 1);
        tx_sfd;
        //transmit data
        tx_byte(8'hAA);
        check("Verify cardet still high", cardet, 1);
        //transmit EOF
        tx_stop(2);
        check("Verify cardet low", cardet, 0);
        check("Verify 2 bytes received", recv_cnt, 2);
        check("Verify data valid", recv_queue[0], 8'hAA);
        check("Verify only 1 error", error_cnt, 1);
        check("Verify cardet only transitioned twice", cardet_cnt, 2);
        check_group_end;
    endtask
    
    task check_test_9();
        reset_queues();
        tx_random_input(5);
        check_group_begin("Send preamble with no SFD (test 9)");
        tx_preamble(13);
        check_ok("Verify carrier detected (test 9a)", cardet, 1);
        rxd = 1'b1;
        repeat (2*CLOCK_SPEED/BIT_RATE) @(posedge clk);
        check_ok("Verify carrier lost (test 9a)", cardet, 0);
        check("Verify cardet low", cardet, 0);
        check("Verify no data received", recv_cnt, 0);
        check("Verify no error", error_cnt, 0);
        check("Verify cardet only transitioned once", cardet_cnt, 1);
        
        reset_queues();
        tx_preamble(18);
        tx_sfd;
        check_ok("Verify carrier detected (test 9a)", cardet, 1);
        rxd = 1'b1;
        repeat (2*CLOCK_SPEED/BIT_RATE) @(posedge clk);
        check_ok("Verify carrier lost (test 9a)", cardet, 0);
        check("Verify cardet low", cardet, 0);
        check("Verify no data received", recv_cnt, 0);
        check("Verify no error", error_cnt, 0);
        check("Verify cardet only transitioned once", cardet_cnt, 1);
        tx_random_input(5);
        
        reset_queues();
        tx_preamble(18);
        tx_sfd;
        check_ok("Verify carrier detected (test 9a)", cardet, 1);
        rxd = 1'b0;
        repeat (2*CLOCK_SPEED/BIT_RATE) @(posedge clk);
        check_ok("Verify carrier lost (test 9a)", cardet, 0);
        check("Verify cardet low", cardet, 0);
        check("Verify no data received", recv_cnt, 0);
        check("Verify no error", error_cnt, 0);
        check("Verify cardet only transitioned once", cardet_cnt, 1);
        tx_random_input(5);
        check_group_end;
    endtask
    
    initial begin
        check_group_begin("Checking startup conditions");
        reset_dut;
        check("cardet low", cardet, 0);
        check("error low", reset, 0);
        check("write low", write, 0);
        check_group_end;
        
        check_test_1;
        check_test_2;
        //This test takes a long time, so normally comment it out if doing other things
        //check_test_3;
        check_test_4;
        check_test_5;
        check_test_9;
        check_test_1;
        
        check_summary_stop;
    end

endmodule
