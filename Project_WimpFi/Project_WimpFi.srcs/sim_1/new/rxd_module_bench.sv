`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2017 02:30:57 PM
// Design Name: 
// Module Name: rxd_module_bench
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


module rxd_module_bench;

    parameter BAUD = 50_000;
    parameter TXD_BAUD = 50_000;
    parameter NUM_SAMP = 16;
    parameter SAMP_WIDTH = $clog2(NUM_SAMP);
    parameter WAIT_TIME = 100_000_000/(TXD_BAUD*NUM_SAMP);

    import check_p ::*;

    logic clk;
    logic reset;
    logic rxd;
    logic rrd;
    logic cardet;
    logic [7:0]RDATA;
    logic RRDY;
    logic [7:0] RERRCNT;
    logic type_2_seen;
    logic ack_seen;
    logic [7:0] source;
    
    receiver_module DUV(.clk(clk),.reset(reset),.RXD(rxd),.RRD(rrd),.mac_addr("@"),.cardet(cardet),.RDATA(RDATA),.RRDY(RRDY),
                        .RERRCNT(RERRCNT),.type_2_seen(type_2_seen),.ack_seen(ack_seen),.source(source));
                        
                        
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
//==================================    
    task send_data_byte_01000000;
        send_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_1;
        send_0; 
    endtask                       
//====================================
    task send_type_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_1;
        send_1;
        send_0;
        send_0; 
    endtask

//====================================
    task send_type_1;
        send_1;
        send_0;
        send_0;
        send_0;
        send_1;
        send_1;
        send_0;
        send_0;
    endtask
    
    task send_type_2;
        send_0;
        send_1;
        send_0;
        send_0;
        send_1;
        send_1;
        send_0;
        send_0; 
    endtask
    
    task send_type_3;
        send_1;
        send_1;
        send_0;
        send_0;
        send_1;
        send_1;
        send_0;
        send_0; 
    endtask
    
    task send_data_byte_01000100;
        send_0;
        send_0;
        send_1;
        send_0;
        send_0;
        send_0;
        send_1;
        send_0; 
    endtask
    
    task send_data_byte_11101111;
        send_1;
        send_1;
        send_1;
        send_1;
        send_0;
        send_1;
        send_1;
        send_1; 
    endtask
    
    task send_data_byte_01111110;
        send_0;
        send_1;
        send_1;
        send_1;
        send_1;
        send_1;
        send_1;
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
    
//=================================================================
    
    task test_16PRE_1SFD_TYPE_0;
    
        $display("===================================Testing Simulation test 3.5===================================");
//        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
//        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        rxd = 1; //data will be random  using random generator
    
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_data_byte_11001100/*01000000*/;//destination @
        repeat(3)@(posedge clk);
        send_data_byte_11001100;//source
        repeat(3)@(posedge clk);
        
        send_type_0;//type
        repeat(3)@(posedge clk);
        
        send_data_byte_00001111;//data
        repeat(3)@(posedge clk);
        
        send_data_byte_10101010;//data
        repeat(3)@(posedge clk);
        
        //send_data_byte_11101111;//FCS
        //repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
    
    endtask
    //=================================================================
    
    task test_16PRE_1SFD_TYPE_1;
    
        $display("===================================Testing Simulation test 3.5===================================");
    //        reset = 0;
        repeat(100)@(posedge clk);
        //assert reset for one clock cycle
        #1;
    //        reset = 1;
        @(posedge clk) #1;
        reset = 0;
        rxd = 1; //data will be random  using random generator
    
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_data_byte_01000000;//destination @
        repeat(3)@(posedge clk);
        send_data_byte_11001100;//source
        repeat(3)@(posedge clk);
        
        send_type_1;//type
        repeat(3)@(posedge clk);
        
        send_data_byte_00001111;//data
        repeat(3)@(posedge clk);
        
        send_data_byte_10101010;//data
        repeat(3)@(posedge clk);
        
        send_data_byte_01111110;//FCS
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
    
    endtask
    
    //=========================================================
    task read_all;
        while(RRDY)begin
            @(posedge clk);
            rrd = 1;
        end
        rrd=0;
    
    endtask
                        
    always begin
        clk = 0;
        #5 clk = 1;
        #5 ;
    end
    
    initial begin
        rrd = 0;
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        
        test_16PRE_1SFD_TYPE_0;
        test_16PRE_1SFD_TYPE_0;
        //read_all;
        repeat(100) @(posedge clk);
        test_16PRE_1SFD_TYPE_1;
        read_all;
        test_16PRE_1SFD_TYPE_1;
        
        //test correct reception of one
        //test sending two packets without reading, second packet should not be put into fifo
        //test sending to wrong destination
        $stop;
        
        
    end


endmodule
