@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xsim receiver_fsm_benc_behav -key {Behavioral:sim_1:Functional:receiver_fsm_benc} -tclbatch receiver_fsm_benc.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
