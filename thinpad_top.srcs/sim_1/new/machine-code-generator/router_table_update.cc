#include "rip.h"
#include "utility.h"
#include "bootloader.h"
#include "ta_hal.h"
#include "router.h"
#include "ta_table.h"

int main()
{
    // 0: 10.0.0.1
    // 1: 10.0.1.1
    // 2: 10.0.2.1
    // 3: 10.0.3.1
    // 子网地址
    // 端序是小端序
    uint32_t addrs[N_IFACE_ON_BOARD] = {0x0a000001, 0x0a000101, 0x0a000201, 0x0a000301};

    uint32_t nexthop[N_IFACE_ON_BOARD] = {0x0a00000b, 0x0a000102, 0x0a000202, 0x0a00030c};

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
            htonl(addrs[i]) & 0x00FFFFFF, // addr: big endian
            24,                           // len: small endian
            i,                            // if_index: small endian
            htonl(nexthop[i]),            // nexthop: big endian, means direct
            0x01000000                    // metric: big endian
        );
        InsertHardwareTable(ntohl(entry.addr), ntohl(entry.nexthop), entry.len, entry.if_index);
    }
}
