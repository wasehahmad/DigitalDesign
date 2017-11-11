@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xelab  -wto 3239a38eb9f64ccc8145bf7e50f5bc92 -m64 --debug typical --relax --mt 2 -L blk_mem_gen_v8_3_3 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot test_bench_behav xil_defaultlib.test_bench xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
