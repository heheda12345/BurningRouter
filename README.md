ThinRouter v0.1
---------------

## Features

1. 接收、发送队列缓冲，CRC校验，坏帧丢弃
2. 基于Trie的硬件转发表，硬件查找与修改
3. 硬件实现ARP表，接收ARP协议的包，发送ARP协议的应答（reply）
4. 处理IPv4数据包，更新TTL、验证Checksum并进行查表转发
    - 如果ARP表查询失败，如何处理？——丢包+发送ARP request（待完成）
5. 流水线式的数据包处理，采用BRAM作为缓冲区

## Todos

1. 硬件——CPU接口
    - 网口接收的数据包转发至CPU
    - CPU欲发送的数据包经过查询转发表得以发送
    - CPU更新路由表
   对于发送数据包，需要通过专门信号来控制`ipv4_module`的转发行为，比如计算checksum和保持TTL
2. 程序结构优化，比如把pkg_classify精简一下
