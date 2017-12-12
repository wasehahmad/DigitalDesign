-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
<<<<<<< HEAD
-- Date        : Sun Dec 10 17:28:02 2017
-- Host        : ECE402-F6M8KB2 running 64-bit major release  (build 9200)
=======
-- Date        : Mon Dec 11 11:48:05 2017
-- Host        : ECE400-9SQXHH2 running 64-bit major release  (build 9200)
>>>>>>> 049554bf670cde6722eec8ad167bafcc3b3604e5
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/watsongd/Desktop/DigitalDesign/Project_WimpFi/Project_WimpFi.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_stub.vhdl
-- Design      : blk_mem_gen_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blk_mem_gen_0 is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 7 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 7 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end blk_mem_gen_0;

architecture stub of blk_mem_gen_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[7:0],dina[7:0],douta[7:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_3_3,Vivado 2016.2";
begin
end;
