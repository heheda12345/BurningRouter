#ifndef __RIP_H__
#define __RIP_H__

#define RIP_MAX_ENTRY 25
#include "utility.h"
struct RipEntry
{
    RipEntry(uint32_t addr = 0, uint32_t mask = 0, uint32_t nexthop = 0, uint32_t metric = 16) : addr(addr), mask(mask), nexthop(nexthop), metric(metric) {}

    // all fields are big endian
    // we don't store 'family', as it is always 2(response) and 0(request)
    // we don't store 'tag', as it is always 0
    uint32_t addr;
    uint32_t mask;
    uint32_t nexthop;
    uint32_t metric;

    void print()
    {
        //   printf("RipEntry {addr = %s, mask = %s, nexthop = %s, metric = %s}",
        //     inet_ntoa(in_addr{addr}),
        //     inet_ntoa(in_addr{mask}),
        //     inet_ntoa(in_addr{nexthop}),
        //     inet_ntoa(in_addr{metric})regt
        // );
    }
};

struct RipPacket
{
    RipPacket();

    uint32_t numEntries;
    // all fields below are big endian
    uint8_t command;
    // we don't store 'version', as it is always 2
    // we don't store 'zero', as it is always 0
    RipEntry entries[RIP_MAX_ENTRY];
};

#endif