#include "utility.h"
#include "bootloader.h"
#include "ta_hal.h"

int main()
{
    int buffer_header = 0;
    while (1)
    {
        macaddr_t src_mac;
        macaddr_t dst_mac;
        int if_index;
        uint8_t* packet;
        int res = ReceiveIPPacket(buffer_header, packet, src_mac, dst_mac, 1000, &if_index);

        if (res == HAL_ERR_EOF)
        {
            return res;
        }
        else if (res < 0)
        {
            return res;
        }
        else if (res == 0)
        {
            // Timeout
            return 1;
        }
        else if (res > 2047)
        {
            // packet is truncated, ignore it
            return 2;
        }

        for (int i = 0; i < res; ++i)
        {
            // if (i % 16 == 0)
            // {
            //     putc('\n');
            // }
            // if (packet[i] == 0)
            //     return 0;
            putc(packet[i]);
            // putc(hextoch(packet[i] & 0xff));
            // putc(hextoch(packet[i] & 0xff00));
            // putc(' ');
        }
    }
    return 0;
}