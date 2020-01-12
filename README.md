# Burning Router

'Burning Router' is a project of THU Computer Organization & Theroy of Computer Network course united experiment. 

## How to run

The verilog part is designed for 'Thinrouter', a experimental device designed for the aim of teaching. It runs with Artix-7 FPGA, KSZ8795 switch chip, IS61LV25616 SRAM and an UART series controller. The hardware design should be synthesized, implemented and generated into bitstream by Vivado 2018.3.

The C++ and C part is designed for our CPU and bus with designed MMIO addresses. Programs are compiled into simple MIPS and run upon our own CPU. 

## Directory Structure

- thinpad_top.srcs/sources_1/new: main verilog files for router and CPU. Some files are inherited from legacy Computer Organization project template (See [This Respository](https://github.com/z4yx/thinpad_top/tree/thinrouter.1))
- thinpad_top.srcs/sim_1/new: simulation files testing CPU, router data path, harware route table, etc.
  - thinpad_top.srcs/sim_1/new/interface-example(see branch 'myrouter.2'): softwares on CPU testing soft-hard interface
  - thinpad_top.srcs/sim_1/new/lookup-test-generator: router table test cases generator
  - thinpad_top.srcs/sim_1/new/machine-code-generator(see branch 'myrouter.2'): RIP programs and other network programs working on MIPS CPU. They were simply written for testing, and were not the actual programs running on CPU. 
- thinpad_top.runs/impl_1: backups of generated bitstreams and ila config

## Authors

- Chen Zhang
- Xingyu Xie
- Wenhou Sun
