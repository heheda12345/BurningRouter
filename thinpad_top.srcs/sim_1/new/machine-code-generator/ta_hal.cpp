#include "ta_hal.h"

#define N_IFACE_ON_BOARD 4

const uint32_t BUFFER_TAIL_ADDRESS = 0xBFD00400;
const uint32_t SEND_CONTROL_ADDRESS = 0xBFD00408;
const uint32_t SEND_STATE_ADDRESS = 0xBFD00404;
const uint32_t BUFFER_BASE_ADDRESS = 0x80600000;
const uint32_t ROUTER_TABLE_BASE = 0xBFD00410;
const uint32_t TIMER_POS = 0xBFD00440;

const int BUFFER_SIZE = 1 << 7;

int sys_index;
int overrun;

int Init(in_addr_t if_addrs[N_IFACE_ON_BOARD])
{
    sys_index = 0;
    overrun = 0;
    for (int i = 0; i < 4; i++)
    {
        *(uint32_t *)(ROUTER_TABLE_BASE) = if_addrs[i];
        *(uint32_t *)(ROUTER_TABLE_BASE + 12) = i;
        *(uint32_t *)(ROUTER_TABLE_BASE + 16) = 2; // send flag
    }
    return 0;
}

uint64_t GetTicks()
{
    volatile uint64_t time1 = *(uint32_t *)(TIMER_POS);
    volatile uint64_t time2 = *(uint32_t *)(TIMER_POS + 4);
    return time2 << 32 | time1;
}

int ReceiveEthernetFrame(uint8_t *&buffer, int64_t timeout, int *if_index)
{
    // volatile = could be changed by sb. outside this cpp program
    volatile uint32_t *BufferIndexPtr = (uint32_t *)BUFFER_TAIL_ADDRESS;
    uint64_t startTime = GetTicks();
    // 2^18 ms = 2^15 s \approx 2^9 days
    if (timeout == -1)
        timeout = ((uint64_t)timeout) >> 1;
    // 'tail': buffer queue tail - which is the position that the router is ready to write
    int tail;
    while (1)
    {
        tail = *BufferIndexPtr;
        // time out?
        if (GetTicks() - startTime >= timeout)
            return 0;
        // packet available?
        if (tail != sys_index)
            break;
    }
    // overrun: the tail counter had already restarted
    overrun = tail < sys_index;

    // cyclic queue
    if (sys_index == BUFFER_SIZE)
        sys_index = 0;

    // packet address
    buffer = (uint8_t *)(BUFFER_BASE_ADDRESS + ((sys_index++) << 11)) + 4;

    *(int *)if_index = *(uint8_t *)(buffer + 15) - 1;

    int res = *(int *)(buffer - 4);

    puts("[recv]", 6);

    // printf("sys_index = ", 11);
    // puthex(sys_index);
    // putc('\n');
    // printf("tail = ", 7);
    // puthex(tail);
    // putc('\n');

    for (int i = 0; i < res; ++i)
    {
        putc(hextoch(buffer[i] >> 4 & 0xf));
        putc(hextoch(buffer[i] & 0xf));

        if (i % 16 == 15)
        {
            putc('\n');
        }
        else
        {
            putc(' ');
        }
    }
    putc('\n');

    return res;
}

void SendEthernetFrame(int if_index, uint8_t *buffer, size_t length)
{
    // MAC Address of our router
    *(uint8_t *)(buffer + 0) = 0x02;
    *(uint8_t *)(buffer + 1) = 0x02;
    *(uint8_t *)(buffer + 2) = 0x03;
    *(uint8_t *)(buffer + 3) = 0x03;
    *(uint8_t *)(buffer + 4) = 0x00;
    *(uint8_t *)(buffer + 5) = 0x00;

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

    // puts("[send]");
    for (int i = 0; i < length; ++i)
    {
        putc(hextoch(buffer[i + 4] >> 4 & 0xf));
        putc(hextoch(buffer[i + 4] & 0xf));

        if (i % 16 == 15)
        {
            putc('\n');
        }
        else
        {
            putc(' ');
        }
    }
    putc('\n');
}