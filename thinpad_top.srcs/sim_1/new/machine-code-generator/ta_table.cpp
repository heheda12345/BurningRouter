#include "ta_table.h"

const uint32_t ROUTER_TABLE_BASE = 0xBFD00410;

int InsertHardwareTable(uint32_t ip, uint32_t nexthop, uint8_t len, uint8_t interface)
{
    *(uint32_t*)(ROUTER_TABLE_BASE) = ip;
    *(uint32_t*)(ROUTER_TABLE_BASE + 4) = nexthop;
    *(uint32_t*)(ROUTER_TABLE_BASE + 8) = len;
    *(uint32_t*)(ROUTER_TABLE_BASE + 12) = interface;
    volatile uint32_t * state = (uint32_t*)(ROUTER_TABLE_BASE + 16);
    while (*state != 0);
    *state = 1;
}
