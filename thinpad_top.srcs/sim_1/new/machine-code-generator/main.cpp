#include "rip.h"
#include "utility.h"
#include "bootloader.h"
#include "ta_hal.h"
#include "router.h"

uint8_t output[2048];
extern uint32_t assemble(const RipPacket *rip, uint8_t *buffer);

// 0: 10.0.0.1
// 1: 10.0.1.1
// 2: 10.0.2.1
// 3: 10.0.3.1
// 子网地址
// 你可以按需进行修改，注意端序是大端序
uint32_t addrs[N_IFACE_ON_BOARD] = {0x203a8c0, 0x104a8c0, 0x102000a, 0x103000a};

uint32_t packetAssemble(RipPacket rip, uint32_t srcIP, uint32_t dstIP)
{
    uint32_t len = assemble(&rip, output + 20 + 8);

    // UDP
    *(uint16_t *)(output + 20) = htons(520);     // src port: 520
    *(uint16_t *)(output + 20 + 2) = htons(520); // dst port: 520
    *(uint16_t *)(output + 20 + 4) = htons(len += 8);
    // TODO: calculate the checksum of UDP
    // checksum calculation for udp
    // if you don't want to calculate udp checksum, set it to zero
    *(uint16_t *)(output + 20 + 6) = 0; // checksum: omitted as zero

    // IP
    *(uint8_t *)(output + 0) = 0x45;                        // Version & Header length
    *(uint8_t *)(output + 1) = 0xc0;                        // Differentiated Services Code Point (DSCP)
    *(uint16_t *)(output + 2) = htons(len += 20);           // Total Length
    *(uint16_t *)(output + 4) = 0;                          // ID
    *(uint16_t *)(output + 6) = 0;                          // FLAGS/OFF
    *(uint8_t *)(output + 8) = 1;                           // TTL
    *(uint8_t *)(output + 9) = 0x11;                        // Protocol: UDP:0x11 TCP:0x06 ICMP:0x01
    *(uint32_t *)(output + 12) = srcIP;                     // src ip
    *(uint32_t *)(output + 16) = dstIP;                     // dst ip
    *(uint16_t *)(output + 10) = ntohs(IPChecksum(output)); // checksum calculation for ip

    return len;
}

const int RIP_ENTRY_MAX = 5000;
RoutingTableEntry entries[RIP_ENTRY_MAX];
int entryTot = 0;
RipPacket routingTable(uint32_t if_index)
{
    RipPacket p = RipPacket();
    p.command = 0x2; // Command Response
    p.numEntries = 0;
    for (int i = 0; i < entryTot; ++i)
    {
        if (if_index != entries[i].if_index)
        {
            p.entries[p.numEntries++] = RipEntry(
                // The format of the routing entry
                // key: <addr, len>, value: <if_index, nexthop, metric>
                entries[i].addr,
                entries[i].len == 0 ? 0 : htonl(~((1 << 32 - entries[i].len) - 1)),
                entries[i].nexthop,
                htonl(min(ntohl(entries[i].metric) + 1, 16u)));
        }
    }
    return p;
}

int main()
{
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

        printf("entry = ");
        entry.print();
        printf("\n");

        entries[entryTot++] = entry;
    }

    uint64_t last_time = 0;
    int buffer_header = 0;
    while (1)
    {
        uint64_t time = GetTicks();
        if (time > last_time + 5 * 1000)
        { // 30s for standard
            printf("Regular RIP Broadcasting every 30s.\n");
            // if (time > last_time + 5 * 1000) { // 5s for test
            //   printf("Regular RIP Broadcasting every 5s.\n");

            // send complete routing table to every interface
            // ref. RFC2453 3.8
            // multicast MAC for 224.0.0.9 is 01:00:5e:00:00:09
            static uint32_t multicastingIP = 0x090000e0;
            static macaddr_t multicastingMAC = {0x01, 0x00, 0x5e, 0x00, 0x00, 0x09};
            for (uint32_t i = 0; i < N_IFACE_ON_BOARD; ++i)
            {
                size_t len = packetAssemble(routingTable(i), addrs[i], multicastingIP);
                SendIPPacket(i, output, len, multicastingMAC);
            }
            last_time = time;
        }
    }
}