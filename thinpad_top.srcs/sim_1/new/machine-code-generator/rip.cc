#include "rip.h"
#include "router.h"
#include "ta_hal.h"
#include "utility.h"

extern bool validateIPChecksum(uint8_t *packet, size_t len);
extern bool update(bool insert, RoutingTableEntry entry);
extern bool query(uint32_t addr, uint32_t *nexthop, uint32_t *metric, uint32_t *if_index);
extern bool forward(uint8_t *packet, size_t len);
extern bool disassemble(const uint8_t *packet, uint32_t len, RipPacket *output);
extern uint32_t assemble(const RipPacket *rip, uint8_t *buffer);
// Some new functions are added here for convenience
extern RipPacket routingTable(uint32_t if_index);
extern void outputTable();

uint8_t output[1522];
// 0: 10.0.0.1
// 1: 10.0.1.1
// 2: 10.0.2.1
// 3: 10.0.3.1
// 子网地址
// 小端序
uint32_t addrs[N_IFACE_ON_BOARD] = {0x0a000001, 0x0a000101, 0x0a000201, 0x0a000301};

uint32_t packetAssemble(RipPacket rip, uint32_t srcIP, uint32_t dstIP)
{
    uint32_t len = assemble(&rip, output + IP_OFFSET + 20 + 8);

    // UDP
    *(uint16_t *)(output + IP_OFFSET + 20) = htons(520);     // src port: 520
    *(uint16_t *)(output + IP_OFFSET + 20 + 2) = htons(520); // dst port: 520
    *(uint16_t *)(output + IP_OFFSET + 20 + 4) = htons(len += 8);
    // TODO: calculate the checksum of UDP
    // checksum calculation for udp
    // if you don't want to calculate udp checksum, set it to zero
    *(uint16_t *)(output + IP_OFFSET + 20 + 6) = 0; // checksum: omitted as zero

    // IP
    *(uint8_t *)(output + IP_OFFSET + 0) = 0x45;                                    // Version & Header length
    *(uint8_t *)(output + IP_OFFSET + 1) = 0xc0;                                    // Differentiated Services Code Point (DSCP)
    *(uint16_t *)(output + IP_OFFSET + 2) = htons(len += 20);                       // Total Length
    *(uint16_t *)(output + IP_OFFSET + 4) = 0;                                      // ID
    *(uint16_t *)(output + IP_OFFSET + 6) = 0;                                      // FLAGS/OFF
    *(uint8_t *)(output + IP_OFFSET + 8) = 1;                                       // TTL
    *(uint8_t *)(output + IP_OFFSET + 9) = 0x11;                                    // Protocol: UDP:0x11 TCP:0x06 ICMP:0x01
    *(uint32_t *)(output + IP_OFFSET + 12) = srcIP;                                 // src ip
    *(uint32_t *)(output + IP_OFFSET + 16) = dstIP;                                 // dst ip
    *(uint16_t *)(output + IP_OFFSET + 10) = ntohs(IPChecksum(output + IP_OFFSET)); // checksum calculation for ip

    return len;
}

int main(int argc, char *argv[])
{
    uint8_t *eth_frame;

    printf("addrs = [");
    for (int i = 0; i < N_IFACE_ON_BOARD; ++i)
        printf("%u, ", (in_addr){addrs[i]}.s_addr);
    printf("]\n");

    // 0a.
    Init(addrs);

    // 0b. Add direct routes
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

        update(true, entry);
    }

    uint64_t last_time = 0;
    while (1)
    {
        uint64_t time = GetTicks();
        if (time > last_time + 30 * 1000)
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

                SendEthernetFrame(i, output + 4, len);
            }
            last_time = time;
        }

        int mask = (1 << N_IFACE_ON_BOARD) - 1;
        int if_index;

        int res = ReceiveEthernetFrame(eth_frame, 1000, &if_index);

        if (res < 0)
        {
            return res;
        }
        else if (res == 0)
        {
            // Timeout
            continue;
        }
        else if (res > 2047)
        {
            // packet is truncated, ignore it
            continue;
        }

        // 1. validate
        if (!validateIPChecksum(eth_frame + IP_OFFSET, res))
        {
            printf("Invalid IP Checksum\n");
            continue;
        }

        // big endian
        in_addr_t src_addr = read_addr(eth_frame + IP_OFFSET + 12);
        in_addr_t dst_addr = read_addr(eth_frame + IP_OFFSET + 16);

        // 2. check whether dst is me
        bool dst_is_me = false;
        for (int i = 0; i < N_IFACE_ON_BOARD; i++)
        {
            if (dst_addr == addrs[i])
            {
                dst_is_me = true;
                break;
            }
        }
        // DONE: Handle rip multicast address(224.0.0.9)
        if (dst_addr == (9u << 24 | 224))
        {
            dst_is_me = true;
        }

        if (dst_is_me)
        {
            // 3a.1
            RipPacket rip;

            printf("Receive an package from if %d\n", if_index);

            // check and validate
            if (disassemble(eth_frame + IP_OFFSET, res, &rip))
            {
                if (rip.command == 1)
                {
                    // 3a.3 request, ref. RFC2453 3.9.1
                    // only need to respond to whole table requests in the lab
                    // but horizontal split also needs considering here
                    printf("RIP request\n");
                    // send it back
                    SendEthernetFrame(if_index, output + 4, packetAssemble(routingTable(if_index), addrs[if_index], src_addr));
                }
                else
                {
                    // 3a.2 response, ref. RFC2453 3.9.2
                    // update routing table
                    // new metric = ?
                    // update metric, if_index, nexthop
                    // what is missing from RoutingTableEntry?

                    printf("RIP Response %d\n", rip.numEntries);

                    for (int i = 0; i < rip.numEntries; i++)
                    {
                        printf("rip.entries[%d] = ", i);
                        rip.entries[i].print();
                        printf("\n");

                        if (htonl(rip.entries[i].metric) < 16)
                        { // TODO: Poison reverse
                            if (update(true, RoutingTableEntry(
                                                 rip.entries[i].addr,
                                                 [](uint32_t mask) -> uint32_t {
                                                     mask = htonl(mask);
                                                     for (uint32_t i = 0; i <= 32; ++i)
                                                         if (mask << i == 0)
                                                             return i;
                                                 }(rip.entries[i].mask),
                                                 (uint32_t)if_index,
                                                 src_addr,
                                                 rip.entries[i].metric)))
                            {
                                outputTable();
                            }
                        }
                    }

                    // triggered updates? ref. RFC2453 3.10.1
                }
            }
        }
    }
    return 0;
}
