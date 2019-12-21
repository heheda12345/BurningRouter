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

        uint8_t *packet;
        int res = ReceiveIPPacket(buffer_header, packet, src_mac, dst_mac, 1000, &if_index);

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

        SendIPPacket(if_index, packet, res, src_mac);
    }
}
