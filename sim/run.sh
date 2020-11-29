#!/bin/bash


#${PRJ_DIR}/srcs/file_handler.sv
#${PRJ_DIR}/srcs/serial_transmitter.sv
#${PRJ_DIR}/srcs/serial_receiver.sv

PRJ_DIR=`realpath ./../`
INCLUDES="-i ${PRJ_DIR}/sim/includes"
FILES="
${PRJ_DIR}/srcs/counter.sv
${PRJ_DIR}/srcs/seven_segs.sv
${PRJ_DIR}/srcs/file_handler.sv
${PRJ_DIR}/srcs/serial_receiver.sv
${PRJ_DIR}/srcs/serial_transmitter.sv
${PRJ_DIR}/srcs/serial_file_echo.sv
${PRJ_DIR}/sim/srcs/project_pkg.sv
${PRJ_DIR}/sim/srcs/clk_if.sv
${PRJ_DIR}/sim/srcs/reset_if.sv
${PRJ_DIR}/sim/srcs/sfe_if.sv
${PRJ_DIR}/sim/srcs/top.sv
${XILINX_VIVADO}/data/verilog/src/glbl.v
"

echo -e "\n\e[93mCompiling sources...............\e[0m"
echo "xvlog -sv -L uvm -L xpm ${INCLUDES} ${FILES}"
if ! xvlog -sv -L uvm -L xpm ${INCLUDES} ${FILES}; then
	echo -e "\e[91m[ERROR] Failing in Compilation!!!!\e[0m\n" >&2
	exit 1;
fi
echo -e "\n\e[93mElaborating testbench...........\e[0m"
echo "xelab --timescale 1ps/1ps --debug typical -L uvm -L xpm top glbl"
if ! xelab --timescale 1ps/1ps --debug typical -L uvm -L xpm top glbl; then
	echo -e "\e[91m[ERROR] Failing in Elaboration!!\e[0m\n" >&2
	exit 1;
fi
echo -e "\n\e[93mLaunching simulation............\e[0m"
RUN_ALL=""
if [ -z $@ ]; then
	RUN_ALL="-R"
fi
echo "xsim ${RUN_ALL} work.top#work.glbl $@"
if ! xsim ${RUN_ALL} work.top#work.glbl -view ${PRJ_DIR}/sim/srcs/top.wcfg $@; then
	echo -e "\e[91m[ERROR] Failing in Simulation!!\e[0m\n" >&2
	exit 1;
fi
echo -e "Finished!\n"
