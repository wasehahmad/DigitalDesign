# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/ahmadw/Desktop/ECE491/DigitalDesign/Lab05/Lab05/Lab05.cache/wt [current_project]
set_property parent.project_path C:/Users/ahmadw/Desktop/ECE491/DigitalDesign/Lab05/Lab05/Lab05.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
read_verilog -library xil_defaultlib -sv {
  C:/Users/ahmadw/Desktop/ECE491/DigitalDesign/Lab05/Lab05/Lab05.srcs/sources_1/new/variable_sampler.sv
  C:/Users/ahmadw/Desktop/ECE491/DigitalDesign/Lab05/Lab05/Lab05.srcs/sources_1/new/correlator.sv
  C:/Users/ahmadw/Desktop/ECE491/DigitalDesign/Lab05/Lab05/Lab05.srcs/sources_1/new/man_receiver.sv
}
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc {{C:/Users/ahmadw/Desktop/ECE491/DigitalDesign/Lab05/Lab05/Lab05.srcs/constrs_1/imports/Lab 1 Reference Code + Requirements Checklist-20170829/nexys4DDR.xdc}}
set_property used_in_implementation false [get_files {{C:/Users/ahmadw/Desktop/ECE491/DigitalDesign/Lab05/Lab05/Lab05.srcs/constrs_1/imports/Lab 1 Reference Code + Requirements Checklist-20170829/nexys4DDR.xdc}}]


synth_design -top man_receiver -part xc7a100tcsg324-1


write_checkpoint -force -noxdef man_receiver.dcp

catch { report_utilization -file man_receiver_utilization_synth.rpt -pb man_receiver_utilization_synth.pb }
