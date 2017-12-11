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
    
    task send_not_enough_data;
        send_0;
        send_0;
        send_1;
        send_0;
        send_0;
        send_0; 
    endtask
    
    
    task send_source;
        send_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_0; 
    endtask
    
    task send_broadcast;//*
        send_0;
        send_1;
        send_0;
        send_1;
        send_0;
        send_1;
        send_0;
        send_0; 
    endtask
    
    task send_our_MAC; //@
        send_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_0;
        send_1;
        send_0; 
    endtask
    
    task send_diff_MAC; //%
        send_1;
        send_0;
        send_1;
        send_0;
        send_0;
        send_1;
        send_0;
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
    
    task send_data_4_5s;
        send_1;
        send_0;
        send_1;
        send_0;
        
        send_0;
        send_0;
        send_0;
        send_0; 
        //---------1
        send_1;
        send_0;
        send_1;
        send_0;
        
        send_0;
        send_0;
        send_0;
        send_0; 
        //---------2
        send_1;
        send_0;
        send_1;
        send_0;
        
        send_0;
        send_0;
        send_0;
        send_0; 
        //---------3
        send_1;
        send_0;
        send_1;
        send_0;
        
        send_0;
        send_0;
        send_0;
        send_0; 
        //---------4
    endtask
    
    task send_data_2_5s;
        send_1;
        send_0;
        send_1;
        send_0;
        
        send_0;
        send_0;
        send_0;
        send_0; 
        //---------1
        send_1;
        send_0;
        send_1;
        send_0;
        
        send_0;
        send_0;
        send_0;
        send_0; 
        //---------2
    endtask
    
    task send_fcs_for_4_5s;
        send_0;
        send_1;
        send_0;
        send_1;
        
        send_1;
        send_1;
        send_1;
        send_1;
    endtask
    
    task send_fcs_for_2_5s;
        send_0;
        send_0;
        send_0;
        send_0;
        
        send_1;
        send_1;
        send_1;
        send_1;
    endtask
    
    task send_fcs_for_4_5s_2;
        send_0;
        send_0;
        send_1;
        send_0;
        
        send_1;
        send_1;
        send_0;
        send_1;
    endtask
    
    task send_fcs_for_2_5s_2;
        send_0;
        send_0;
        send_1;
        send_0;
        
        send_1;
        send_0;
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
    
//=================================================================
    
    task test_16PRE_1SFD_TYPE_0;
    
        $display("===================================Testing Simulation test===================================");
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
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_0;//type
        repeat(3)@(posedge clk);
        
        send_data_byte_00001111;//data
        repeat(3)@(posedge clk);
        
        //send_data_byte_11101111;//FCS
        //repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
    
    endtask
    
    task test_16PRE_1SFD_TYPE_1;
    
    $display("===================================Testing Simulation test===================================");
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
    //=================================================================
    //type 0
    //receive broadcast
    //receive specific MAC
    //doenst receive other MAC
    
    //type 1
    //all type 0s
    //fcs 2 bytes
    //fcs 10 bytes
    //wrong fcs --> increment errcount & not receive (RRDY low)
    
    //type 2
    //all type 1
    //broadcast no ack
    //non brodcast ack
    
    //type 3
    //ack received goes high
    //wrong fcs, dont send ack rec
    
    
    
    //==========================TYPE 0===============================
    
    task receive_broadcast;
        $display("===================================Testing Simulation test 0.1===================================");
 
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_broadcast;//destination *
        repeat(3)@(posedge clk);
        
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_0;//type
        repeat(3)@(posedge clk);
        
        send_data_byte_00001111;//data
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
        
        while(RRDY) begin
            check_ok("RDATA is the broadcast address", RDATA, 8'h2A);
            rrd = 1;
            @(posedge clk);
            check_ok("RDATA is the source address", RDATA, 8'h00);
            @(posedge clk);
            check_ok("RDATA is the type", RDATA, "0");
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h0f);
            @(posedge clk) #1;
        end;
        rrd = 0;        
    endtask
    
    task receive_our_MAC_address;
        $display("===================================Testing Simulation test 0.2===================================");
 
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_our_MAC;//destination @
        repeat(3)@(posedge clk);
        
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_0;//type
        repeat(3)@(posedge clk);
        
        send_data_byte_00001111;//data
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
        
        while(RRDY) begin
            check_ok("RDATA is our MAC address", RDATA, 8'h40);
            rrd = 1;
            @(posedge clk);
            check_ok("RDATA is the source address", RDATA, 8'h00);
            @(posedge clk);
            check_ok("RDATA is the type", RDATA, "0");
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h0f);
            @(posedge clk) #1;
        end;
        rrd = 0;        
    endtask
    
    task dont_receive_diff_MAC_address;
        $display("===================================Testing Simulation test 0.3===================================");
 
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_diff_MAC;//destination %
        repeat(3)@(posedge clk);
        
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_0;//type
        repeat(3)@(posedge clk);
        
        send_data_byte_00001111;//data
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
        
        @(posedge clk);
        check_ok("RRDY doesn't go high, because data was sent to different MAC address", RRDY, 0);        
    endtask
    
    task receive_broadcast_with_fcs;
        $display("===================================Testing Simulation test 1.1===================================");
 
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_broadcast;//destination *
        repeat(3)@(posedge clk);
        
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_1;//type
        repeat(3)@(posedge clk);
        
        send_data_2_5s;//data
        repeat(3)@(posedge clk);
        
        send_fcs_for_2_5s; //fcs
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
        
        while(RRDY) begin
            check_ok("RDATA is broadcast address", RDATA, 8'h2a);
            rrd = 1;
            @(posedge clk);
            check_ok("RDATA is the source address", RDATA, 8'h00);
            @(posedge clk);
            check_ok("RDATA is the type", RDATA, "1");
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h05);
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h05);
            @(posedge clk);
            check_ok("RDATA is the checksum", RDATA, 8'hf0);
            @(posedge clk) #1;
        end;
        rrd = 0;       
    endtask
    
    task receive_on_our_address_with_fcs;
        $display("===================================Testing Simulation test 1.2===================================");
 
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_our_MAC;//destination @
        repeat(3)@(posedge clk);
        
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_1;//type
        repeat(3)@(posedge clk);
        
        send_data_4_5s;//data
        repeat(3)@(posedge clk);
        
        send_fcs_for_4_5s; //fcs
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
        
        while(RRDY) begin
            check_ok("RDATA is broadcast address", RDATA, 8'h40);
            rrd = 1;
            @(posedge clk);
            check_ok("RDATA is the source address", RDATA, 8'h00);
            @(posedge clk);
            check_ok("RDATA is the type", RDATA, "1");
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h05);
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h05);
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h05);
            @(posedge clk);
            check_ok("RDATA is the data", RDATA, 8'h05);
            @(posedge clk);
            check_ok("RDATA is the checksum", RDATA, 8'hfa);
            @(posedge clk) #1;
        end;
        rrd = 0;       
    endtask
    
        
    task no_receive_diff_MAC_with_fcs;
        $display("===================================Testing Simulation test 1.3===================================");
 
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_diff_MAC;//destination %
        repeat(3)@(posedge clk);
        
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_1;//type
        repeat(3)@(posedge clk);
        
        send_data_4_5s;//data
        repeat(3)@(posedge clk);
        
        send_fcs_for_4_5s;//data
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
        
        @(posedge clk);
        check_ok("RRDY doesn't go high, because data was sent to different MAC address", RRDY, 0);        
    endtask
        
    task no_receive_incorrect_fcs;
        $display("===================================Testing Simulation test 1.4===================================");
 
        //send preamble
        send_preamble_8;
        @(posedge clk);
        send_preamble_8;
        send_sfd;
        
        send_our_MAC;//destination @
        repeat(3)@(posedge clk);
        
        send_source;//source
        repeat(3)@(posedge clk);
        
        send_type_1;//type
        repeat(3)@(posedge clk);
        
        send_data_4_5s;//data
        repeat(3)@(posedge clk);
        
        send_type_0;//fcs
        repeat(3)@(posedge clk);
        
        send_eof;
        repeat(2)@(posedge clk);
        
        @(posedge clk);
        check_ok("RRDY doesn't go high because incorrect FCS", RRDY, 0);      
        check_ok("RERRCNT increments due to incorrect FCS", RERRCNT, 1);
    endtask
    
    //=========================================================
    
    task receive_broadcast_with_fcs_2;
            $display("===================================Testing Simulation test 2.1===================================");
     
            //send preamble
            send_preamble_8;
            @(posedge clk);
            send_preamble_8;
            send_sfd;
            
            send_broadcast;//destination *
            repeat(3)@(posedge clk);
            
            send_source;//source
            repeat(3)@(posedge clk);
            
            send_type_2;//type
            repeat(3)@(posedge clk);
            
            send_data_2_5s;//data
            repeat(3)@(posedge clk);
            
            send_fcs_for_2_5s_2; //fcs
            repeat(3)@(posedge clk);
            
            send_eof;
            repeat(2)@(posedge clk);
            
            while(RRDY) begin
                check_ok("RDATA is broadcast address", RDATA, 8'h2a);
                rrd = 1;
                @(posedge clk);
                check_ok("RDATA is the source address", RDATA, 8'h00);
                @(posedge clk);
                check_ok("RDATA is the type", RDATA, "2");
                @(posedge clk);
                check_ok("RDATA is the data", RDATA, 8'h05);
                @(posedge clk);
                check_ok("RDATA is the data", RDATA, 8'h05);
                @(posedge clk);
                check_ok("RDATA is the checksum", RDATA, 8'h14);
                @(posedge clk);
                check_ok("Type 2 seen does not go high for broadcast", type_2_seen, 0);
                @(posedge clk) #1;
            end;
            rrd = 0;       
        endtask
        
        task receive_on_our_address_with_fcs_2;
            $display("===================================Testing Simulation test 2.2===================================");
     
            //send preamble
            send_preamble_8;
            @(posedge clk);
            send_preamble_8;
            send_sfd;
            
            send_our_MAC;//destination @
            repeat(3)@(posedge clk);
            
            send_source;//source
            repeat(3)@(posedge clk);
            
            send_type_2;//type
            repeat(3)@(posedge clk);
            
            send_data_4_5s;//data
            repeat(3)@(posedge clk);
            
            send_fcs_for_4_5s_2; //fcs
            repeat(3)@(posedge clk);
            
            send_eof;
            repeat(2)@(posedge clk);
            
            while(RRDY) begin
                check_ok("RDATA is broadcast address", RDATA, 8'h40);
                rrd = 1;
                @(posedge clk);
                check_ok("RDATA is the source address", RDATA, 8'h00);
                @(posedge clk);
                check_ok("RDATA is the type", RDATA, "2");
                @(posedge clk);
                check_ok("RDATA is the data", RDATA, 8'h05);
                @(posedge clk);
                check_ok("RDATA is the data", RDATA, 8'h05);
                @(posedge clk);
                check_ok("RDATA is the data", RDATA, 8'h05);
                @(posedge clk);
                check_ok("RDATA is the data", RDATA, 8'h05);
                @(posedge clk);
                check_ok("RDATA is the checksum", RDATA, 8'hb4);
                @(posedge clk);
                check_ok("Type 2 seen does go high for our address", type_2_seen, 1);
                @(posedge clk);
                check_ok("Source from type 2 packet seen to send ack to is confirmed", source, 8'h00);
                @(posedge clk) #1;
            end;
            rrd = 0;       
        endtask
        
            
        task no_receive_diff_MAC_with_fcs_2;
            $display("===================================Testing Simulation test 2.3===================================");
     
            //send preamble
            send_preamble_8;
            @(posedge clk);
            send_preamble_8;
            send_sfd;
            
            send_diff_MAC;//destination %
            repeat(3)@(posedge clk);
            
            send_source;//source
            repeat(3)@(posedge clk);
            
            send_type_2;//type
            repeat(3)@(posedge clk);
            
            send_data_4_5s;//data
            repeat(3)@(posedge clk);
            
            send_fcs_for_4_5s_2;//data
            repeat(3)@(posedge clk);
            
            send_eof;
            repeat(2)@(posedge clk);
            
            @(posedge clk);
            check_ok("RRDY doesn't go high, because data was sent to different MAC address", RRDY, 0);        
        endtask
            
        task no_receive_incorrect_fcs_2;
            $display("===================================Testing Simulation test 2.4===================================");
     
            //send preamble
            send_preamble_8;
            @(posedge clk);
            send_preamble_8;
            send_sfd;
            
            send_our_MAC;//destination @
            repeat(3)@(posedge clk);
            
            send_source;//source
            repeat(3)@(posedge clk);
            
            send_type_2;//type
            repeat(3)@(posedge clk);
            
            send_data_4_5s;//data
            repeat(3)@(posedge clk);
            
            send_fcs_for_2_5s_2;//data
            repeat(3)@(posedge clk);
            
            send_eof;
            repeat(2)@(posedge clk);
            
            @(posedge clk);
            check_ok("RRDY doesn't go high because incorrect FCS", RRDY, 0);      
            check_ok("RERRCNT increments due to incorrect FCS", RERRCNT, 1);
            check_ok("Type 2 seen does not go high when a bad FCS is received", type_2_seen, 0);
        endtask
        
        task receive_ack;
            $display("===================================Testing Simulation test 3.1===================================");
     
            //send preamble
            send_preamble_8;
            @(posedge clk);
            send_preamble_8;
            send_sfd;
            
            send_our_MAC;//destination @
            repeat(3)@(posedge clk);
            
            send_source;//source
            repeat(3)@(posedge clk);
            
            send_type_3;//type
            repeat(3)@(posedge clk);
            
            send_fcs_for_2_5s_2;//fcs
            repeat(3)@(posedge clk);
            
            send_eof;
            repeat(2)@(posedge clk);
            
            @(posedge clk);
            check_ok("ack seen goes high because of type 3 packet", ack_seen, 1);
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
        rxd = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        receive_broadcast;              // type 0 test 1
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        receive_our_MAC_address;        // type 0 test 2
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        dont_receive_diff_MAC_address;  // type 0 test 3
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        receive_broadcast_with_fcs;     // type 1 test 1
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        receive_on_our_address_with_fcs;// type 1 test 2
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        no_receive_diff_MAC_with_fcs;   // type 1 test 3
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        no_receive_incorrect_fcs;       // type 1 test 4
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        receive_broadcast_with_fcs_2;     // type 2 test 1
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        receive_on_our_address_with_fcs_2;// type 2 test 2
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        no_receive_diff_MAC_with_fcs_2;   // type 2 test 3
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        no_receive_incorrect_fcs_2;       // type 2 test 4
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
        receive_ack;                      // type 3 test 1
        reset = 1;
        repeat(100)@(posedge clk);
        reset = 0;
        repeat(100)@(posedge clk);
//        test_16PRE_1SFD_TYPE_1;
//        read_all;
//        test_16PRE_1SFD_TYPE_1;
        
        //test correct reception of one
        //test sending two packets without reading, second packet should not be put into fifo
        //test sending to wrong destination
        $stop;
        
        
    end
endmodule
