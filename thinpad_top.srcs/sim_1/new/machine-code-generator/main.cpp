#include "utility.h"
#include "bootloader.h"
#include "ta_hal.h"

#define IP_OFFSET 18

// 0: 10.0.1.1
// 1: 10.0.0.1
// 2: 10.0.2.1
// 3: 10.0.3.1
// 子网地址
// 端序是小端序
uint32_t addrs[N_IFACE_ON_BOARD] = {0x0a000101, 0x0a000001, 0x0a000201, 0x0a000301};

int main()
{
    Init(addrs);
    int buffer_header = 0;
    while (1)
    {
        macaddr_t src_mac;
        macaddr_t dst_mac;
        int if_index;

        uint8_t *packet;
        int res = ReceiveEthernetFrame(packet, 1000, &if_index);

        if (res < 0)
        {
            return res;
        }
        else if (res == 0)
        {
            // Timeout
            continue;
        }
        else if (res > 2047)
        {
            // packet is truncated, ignore it
            continue;
        }

        uint16_t src_addr_1 = *(uint16_t *)(packet + IP_OFFSET + 12);
        uint16_t src_addr_2 = *(uint16_t *)(packet + IP_OFFSET + 14);
        uint16_t dst_addr_1 = *(uint16_t *)(packet + IP_OFFSET + 16);
        uint16_t dst_addr_2 = *(uint16_t *)(packet + IP_OFFSET + 18);
        *(uint16_t *)(packet + IP_OFFSET + 12) = dst_addr_1;
        *(uint16_t *)(packet + IP_OFFSET + 14) = dst_addr_2;
        *(uint16_t *)(packet + IP_OFFSET + 16) = src_addr_1;
        *(uint16_t *)(packet + IP_OFFSET + 18) = src_addr_2;

        SendEthernetFrame(if_index, packet, res);
    }
}
