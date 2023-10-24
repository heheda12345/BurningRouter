# Burning Router

Burning Router is a project of THU Computer Organization & Theroy of Computer Network course united experiment. 

## How to run

The verilog part is designed for 'Thinrouter', a experimental device designed for the aim of teaching. It runs with Artix-7 FPGA, KSZ8795 switch chip, IS61LV25616 SRAM and an UART series controller. The hardware design should be synthesized, implemented and generated into bitstream by Vivado 2018.3.

The C++ and C part is designed for our CPU and bus with designed MMIO addresses. Programs are compiled into simple MIPS and run upon our own CPU. 

## Directory Structure

- `thinpad_top.srcs/sources_1/new`: main verilog files for router and CPU. Some files are inherited from legacy Computer Organization project template (See [This Respository](https://github.com/z4yx/thinpad_top/tree/thinrouter.1))
- `thinpad_top.srcs/sim_1/new`: simulation files testing CPU, router data path, harware route table, etc.
  - `thinpad_top.srcs/sim_1/new/interface-example`(see branch 'myrouter.2'): softwares on CPU testing soft-hard interface
  - `thinpad_top.srcs/sim_1/new/lookup-test-generator`: router table test cases generator
  - `thinpad_top.srcs/sim_1/new/machine-code-generator`(see branch 'myrouter.2'): RIP programs and other network programs working on MIPS CPU. They were simply written for testing, and were not the actual programs running on CPU. 
- `thinpad_top.runs/impl_1`: backups of generated bitstreams and ila config

## Warning

**如果您是选报了硬件路由器实验的《计算机网络原理》选课同学，请立即关闭此页面，[禁止抄袭](https://lab.cs.tsinghua.edu.cn/router/doc/software/plagiarism/)，否则后果自负。**

**注：《学生纪律处分管理规定实施细则》节选：**

>**第六章 学术不端、违反学习纪律的行为与处分**
>
>**第二十一条 有下列违反课程学习纪律情形之一的，给予警告以上、留校察看以下处分：**
>
> **（一）课程作业抄袭严重的；**
>
> **（二）实验报告抄袭严重或者篡改实验数据的；**
>
> **（三）期中、期末课程论文抄袭严重的；**
>
> **（四）在课程学习过程中严重弄虚作假的其他情形。**

## Authors

- Chen Zhang
- Xingyu Xie
- Wenhou Sun
