@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xsim rtl_transmitter_bench_behav -key {Behavioral:sim_1:Functional:rtl_transmitter_bench} -tclbatch rtl_transmitter_bench.tcl -view C:/Users/watsongd/Desktop/491 Labs/DigitalDesign/Lab_2_Serial_Transmitter/rtl_transmitter_bench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
