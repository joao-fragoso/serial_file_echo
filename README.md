# Serial File Echo
A SystemVerilog serial file echo project to Xilinx Vivado

This project implements a serial receiver and a serial transmitir. The serial data is captured from STX (character 0x02) up to ETX (character 0x03). All received characters are stored and this file is echoed back after ETX. The file size is limited to 2048 characters.
