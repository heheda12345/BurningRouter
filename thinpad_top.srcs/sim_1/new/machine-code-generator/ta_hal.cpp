#include "ta_hal.h"

#define N_IFACE_ON_BOARD 4

const uint32_t BUFFER_TAIL_ADDRESS = 0xBFD00400;
const uint32_t SEND_CONTROL_ADDRESS = 0xBFD00408;
const uint32_t SEND_STATE_ADDRESS = 0xBFD00404;
const uint32_t BUFFER_BASE_ADDRESS = 0x80600000;
const uint32_t ROUTER_TABLE_BASE = 0xBFD00410;
const uint32_t TIMER_POS = 0xBFD00440;

int Init(in_addr_t if_addrs[N_IFACE_ON_BOARD])
{
    return 0; // No IP binding routine now
}

uint64_t GetTicks()
{
    volatile uint64_t time1 = *(uint32_t *)(TIMER_POS);
    volatile uint64_t time2 = *(uint32_t *)(TIMER_POS + 4);
    return time2 << 32 | time1;
}

int ReceiveEthernetFrame(int sys_index, uint8_t *&buffer,
                         macaddr_t src_mac, macaddr_t dst_mac, int64_t timeout,
                         int *if_index)
{
    // volatile = could be changed by sb. outside this cpp program
    volatile uint32_t *BufferIndexPtr = (uint32_t *)BUFFER_TAIL_ADDRESS;
    uint64_t startTime = GetTicks();
    // 2^18 ms = 2^15 s \approx 2^9 days
    if (timeout == -1)
        timeout = ((uint64_t)timeout) >> 1;
    while (1)
    {
        if (GetTicks() - startTime >= timeout)
            return 0;
        if (*BufferIndexPtr != sys_index)
            break;
    }

    buffer = (uint8_t *)(BUFFER_BASE_ADDRESS + ((sys_index++) << 11)) + 4;
    // Note: the Ethernet header the cpu receives is different from that of a standard one.
    // In our implementation, src mac is ahead of dst mac.
    for (int i = 0; i < 6; ++i)
    {
        *(uint8_t *)(src_mac + i) = *(uint8_t *)(buffer + i);
        *(uint8_t *)(dst_mac + i) = *(uint8_t *)(buffer + 8 + i);
    }

    *(int *)if_index = *(uint8_t *)(buffer + 15) - 1;

    int res = *(int *)(buffer - 4);
    puts("[recv]");
    for (int i = 0; i < res; i += 4)
    {
        // putc(buffer[i]);
        for (int j = 3; j >= 0; j--)
        {
            if (i + j < res)
            {
                putc(hextoch(buffer[i + j] >> 4 & 0xf));
                putc(hextoch(buffer[i + j] & 0xf));
                putc(' ');
            }
        }
        if (i % 16 == 8)
        {
            putc('\n');
        }
    }
    puts("");
    return res;
}

void SendEthernetFrame(int if_index, uint8_t *buffer, size_t length)
{
    *(uint8_t *)(buffer + 0) = 0x02;
    *(uint8_t *)(buffer + 1) = 0x02;
    *(uint8_t *)(buffer + 2) = 0x03;
    *(uint8_t *)(buffer + 3) = 0x03;
    *(uint8_t *)(buffer + 4) = 0x03;
    *(uint8_t *)(buffer + 5) = 0x03;

    *(uint8_t *)(buffer + 15) = if_index + 1;
    buffer -= 4;
    *(int *)(buffer) = length;
    volatile uint32_t *SendStatePtr = (uint32_t *)SEND_STATE_ADDRESS;
    while (1)
    {
        if (((*(uint32_t *)SendStatePtr) & 1) == 0)
            break;
    }
    *(uint32_t *)SEND_CONTROL_ADDRESS = (uint32_t)buffer;
    puts("[send]");
    for (int i = 0; i < length; i += 4)
    {

        for (int j = 3; j >= 0; j--)
        {
            if (i + j < length)
            {
                putc(hextoch(buffer[i + j + 4] >> 4 & 0xf));
                putc(hextoch(buffer[i + j + 4] & 0xf));
                putc(' ');
            }
        }
        if (i % 16 == 8)
        {
            putc('\n');
        }
    }
    puts("");
}