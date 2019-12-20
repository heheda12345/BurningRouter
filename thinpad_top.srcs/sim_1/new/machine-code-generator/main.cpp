// #include "bootloader.h"
// int main() {
//     puts("Hello the cruel world.");
// }

#include "utility.h"
#include "bootloader.h"
#include "ta_hal.h"

uint8_t packet[2048];

int main()
{
    int buffer_header = 0;
    while (1)
    {
        macaddr_t src_mac;
        macaddr_t dst_mac;
        int if_index;

        puts("Before a receive.");

        int res = ReceiveIPPacket(buffer_header, packet, src_mac, dst_mac, 1000, &if_index);

        puts("After a receive.");

        if (res == HAL_ERR_EOF)
        {
            break;
        }
        else if (res < 0)
        {
            return res;
        }
        else if (res == 0)
        {
            // Timeout
            continue;
        }
        else if (res > sizeof(packet))
        {
            // packet is truncated, ignore it
            continue;
        }

        for (int i = 0; i < res; ++i)
        {
            if (i % 16 == 0)
            {
                putc('\n');
            }
            putc(hextoch(packet[i] & 0xff));
            putc(hextoch(packet[i] & 0xff00));
            putc(' ');
        }
    }
}