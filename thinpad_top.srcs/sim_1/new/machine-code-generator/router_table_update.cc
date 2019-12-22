#include "rip.h"
#include "utility.h"
#include "bootloader.h"
#include "ta_hal.h"
#include "router.h"
#include "ta_table.h"

extern bool update(bool insert, RoutingTableEntry entry);

uint8_t output[2048];

int main()
{
    // 0: 10.0.0.1
    // 1: 10.0.1.1
    // 2: 10.0.2.1
    // 3: 10.0.3.1
    // 子网地址
    // 端序是小端序
    uint32_t addrs[N_IFACE_ON_BOARD] = {0x0a000001, 0x0a000101, 0x0a000201, 0x0a000301};

    Init(addrs);

    // Add direct routes
    // For example:
    // 10.0.0.0/24 if 0
    // 10.0.1.0/24 if 1
    // 10.0.2.0/24 if 2
    // 10.0.3.0/24 if 3
    for (uint32_t i = 0; i < N_IFACE_ON_BOARD; i++)
    {
        RoutingTableEntry entry = RoutingTableEntry(
            addrs[i] & 0x00FFFFFF, // big endian
            24,                    // small endian
            i,                     // small endian
            0,                     // big endian, means direct
            0x01000000             // big endian
        );
        InsertHardwareTable(ntohl(entry.addr), ntohl(entry.nexthop), entry.len, entry.if_index);
    }
}
