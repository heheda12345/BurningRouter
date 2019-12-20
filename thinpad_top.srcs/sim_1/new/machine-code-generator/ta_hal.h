#pragma once

#include "utility.h"
typedef uint8_t macaddr_t[6];
typedef uint32_t in_addr_t;
#define N_IFACE_ON_BOARD 4 // Default


enum HAL_ERROR_NUMBER {
  HAL_ERR_INVALID_PARAMETER = -1000,
  HAL_ERR_IP_NOT_EXIST,
  HAL_ERR_IFACE_NOT_EXIST,
  HAL_ERR_CALLED_BEFORE_INIT,
  HAL_ERR_EOF,
  HAL_ERR_NOT_SUPPORTED,
  HAL_ERR_UNKNOWN,
};

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief 初始化，在所有其他函数调用前调用且仅调用一次
 *
 * @param if_addrs IN，包含 N_IFACE_ON_BOARD 个 IPv4 地址，对应每个端口的 IPv4
 * 地址
 *
 * @return int 0 表示成功，非 0 表示失败
 */
int Init(in_addr_t if_addrs[N_IFACE_ON_BOARD]);

/**
 * @brief 获取从启动到当前时刻的毫秒数
 *
 * @return uint64_t 毫秒数
 */
uint64_t GetTicks();

/**
 * @brief 接收一个 IPv4
 * 报文，不保证不会收到自己发送的报文；报文可以多次读取
 *
 * @param sys_index CPU当前已完成处理并发送的缓冲区块编号。
 * @param buffer OUT，接收缓冲区，由调用者分配
 * @param src_mac OUT，IPv4 报文下层的源 MAC 地址
 * @param dst_mac OUT，IPv4 报文下层的目的 MAC 地址
 * @param timeout IN，设置接收超时时间（毫秒），传入-1 表示无限等待
 * @param if_index OUT，实际接收到的报文来源的接口号，不能为空指针。范围是0~3
 * @return int >0 表示实际接收的报文长度，=0 表示超时返回，<0 表示发生错误
 */
int ReceiveIPPacket(int sys_index, uint8_t *buffer,
                    macaddr_t src_mac, macaddr_t dst_mac, int64_t timeout,
                    int *if_index);

/**
 * @brief 发送一个 IP 报文，它的源 MAC 地址就是对应接口的 MAC 地址
 *        没有彻底解决套圈问题，i.e. 如果CPU在修改一个包，但是路由器“套圈”覆盖掉了，
 *        就会导致失去读写一致性。需要硬件记录自从上次取索引以后，路由器是否开始了新的计数。
 *
 * @param if_index IN，接口索引号，[0, N_IFACE_ON_BOARD-1]
 * @param buffer IN，发送缓冲区。缓冲区前要留有4字节的空间。
 * @param length IN，待发送报文的长度
 * @param dst_mac IN，IPv4 报文下层的目的 MAC 地址
 * @return int 0 表示成功，非 0 为失败
 */
int SendIPPacket(int if_index, uint8_t *buffer, size_t length,
                 macaddr_t dst_mac);

#ifdef __cplusplus
}
#endif
