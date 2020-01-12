<<<<<<< HEAD
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

## Authors

- Chen Zhang
- Xingyu Xie
- Wenhou Sun
=======
ThinRouter v0.1
---------------

## Features

1. 接收、发送队列缓冲，CRC校验，坏帧丢弃
2. 基于Trie的硬件转发表，硬件查找与修改
3. 硬件实现ARP表，接收ARP协议的包，发送ARP协议的应答（reply）
4. 处理IPv4数据包，更新TTL、验证Checksum并进行查表转发
    - 如果ARP表查询失败，如何处理？——丢包+发送ARP request
5. 流水线式的数据包处理，采用BRAM作为缓冲区

## Todos

1. 硬件——CPU接口
2. ARP表项老化
3. 给不同的端口分配不同的IP地址（与不同的MAC？）

### 硬件——CPU接口

### 功能

- 网口接收的数据包转发至CPU
- CPU欲发送的数据包经过查询转发表得以发送
- CPU更新路由表

### 实现

对于发送数据包，需要通过专门信号来控制`ipv4_module`的转发行为，比如计算checksum和保持TTL

实现思路：

- 对于从CPU发来的包，我们用异步AXIS FIFO作为缓冲，将其与来自MAC的FIFO并联，轮流从两个队列中取出数据（如果队列为空，跳过就好），输出信号指示当前的包是否来自CPU。
- 对于发到CPU的包，我们同样用异步AXIS FIFO作为缓冲，由ipv4模块控制，直接发往CPU。

### 数据包格式规定

- CPU发包格式：不含Ethernet的MAC地址头部与校验码尾部；有VLAN Tag，如果是ARP包则`vlan port`可以为0。但是`vlan port`为0会导致ARP包不能正常发送，因此如果要直接发送ARP包，请指定`vlan port`。IPv4包的校验和、下一跳的VLAN port会被修改，TTL、净荷不变；其他类型的包完全不修改；不支持类型的包被丢弃。
- CPU收包格式：只会收到ipv4包，不含有Ethernet的MAC地址头部与校验码尾部，有VLAN Tag。TTL自然减一。

## Speed Estimation

- ARP包: 接收包需要处理不少于64个字节（含尾部CRC32校验码），然而ARP包实际上又没有这么长，由于尾部的0不需要处理，可以一边读取一边写入缓冲区，因此拆包修改转发并不会造成阻塞。
- IPv4包：只有在成功查到下一跳的ARP地址之后的修改包才会需要打断数据接收，共10个字节需要修改（也就是会暂停10个周期）；OVER和IDLE状态也不会接收数据，2个时钟周期。
  因此接收队列利用效率大约为L/(L+12)，L为数据包的平均长度。

这样看来，总体数据速率基本达到千兆的至少85%，考虑到百兆网口的限制，理论上应该可以满速。

## CPU指令集
```
['ADDIU', 'ADDU', 'AND', 'ANDI', 'BEQ', 'BGTZ', 'BNE', 'J', 'JAL', 'JR', 'LB', 'LUI', 'LW', 'OR', 'ORI', 'SB', 'SLL', 'SRL', 'SW', 'XOR', 'XORI', 'sra', 'lh', 'movz', 'lhu', 'sh', 'lbu', 'slti', 'sltiu', 'slt', 'sltu', 'subu', 'nor', 'sllv', 'srlv', 'bgezal', 'bgez', 'bltz']
```

## 路由表压测结果
1. 中等规模路由表压力测试 需要2579个Trie的节点
2. $2^13$个节点，可插入1600-2000条表项
>>>>>>> origin/myrouter.2
