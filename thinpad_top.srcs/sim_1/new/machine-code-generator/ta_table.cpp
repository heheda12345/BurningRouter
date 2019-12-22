#include "ta_table.h"

#include "utility.h"

const uint32_t ROUTER_TABLE_BASE = 0xBFD00410u;
const uint32_t ROUTER_LOOKUP_CTRL = 0xBFD00420u;

bool InsertHardwareTable(uint32_t ip, uint32_t nexthop, uint8_t len, uint8_t interface)
{
    volatile uint32_t *state = (uint32_t *)ROUTER_LOOKUP_CTRL;
    bool full = *state & 2;

    if (full)
        return false;
    else
    {

        *(uint32_t *)(ROUTER_TABLE_BASE) = ip;
        *(uint32_t *)(ROUTER_TABLE_BASE + 4) = nexthop;
        *(uint32_t *)(ROUTER_TABLE_BASE + 8) = len;
        *(uint32_t *)(ROUTER_TABLE_BASE + 12) = interface;

        while ((*state & 1) != 0)
            ;
        *state = 1;

        return true;
    }
}
