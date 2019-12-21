#include "utility.h"
#include "bootloader.h"
#include "ta_hal.h"

#define IP_OFFSET 18

int main()
{
    int buffer_header = 0;
    while (1)
    {
        macaddr_t src_mac;
        macaddr_t dst_mac;
        int if_index;

        uint8_t *packet;
        int res = ReceiveEthernetFrame(buffer_header, packet, src_mac, dst_mac, 1000, &if_index);

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

        in_addr_t src_addr = *(uint32_t *)(packet + IP_OFFSET + 12), dst_addr = *(uint32_t *)(packet + IP_OFFSET + 16);
        *(uint32_t *)(packet + IP_OFFSET + 12) = dst_addr, src_addr = *(uint32_t *)(packet + IP_OFFSET + 16);

        SendEthernetFrame(if_index, packet, res);
    }
}
