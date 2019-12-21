#include "rip.h"
#include "router.h"

#ifdef D
#include "router_hal.h"

// #include "ta_hal.h"
#include "utility.h"

extern bool validateIPChecksum(uint8_t *packet, size_t len);
extern bool update(bool insert, RoutingTableEntry entry);
extern bool query(uint32_t addr, uint32_t *nexthop, uint32_t *if_index);
extern bool forward(uint8_t *packet, size_t len);
extern bool disassemble(const uint8_t *packet, uint32_t len, RipPacket *output);
extern uint32_t assemble(const RipPacket *rip, uint8_t *buffer);
// Some new functions are added here for convenience
extern RipPacket routingTable(uint32_t if_index);
extern void outputTable();

uint8_t packet[2048];
uint8_t output[2048];
// 0: 10.0.0.1
// 1: 10.0.1.1
// 2: 10.0.2.1
// 3: 10.0.3.1
// 子网地址
// 你可以按需进行修改，注意端序是大端序
uint32_t addrs[N_IFACE_ON_BOARD] = {0x0a000101, 0x0a000001, 0x0a000201, 0x0a000301};

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

int main(int argc, char *argv[])
{
    printf("addrs = [");
    for (int i = 0; i < N_IFACE_ON_BOARD; ++i)
        printf("%u, ", (in_addr){addrs[i]}.s_addr);
    printf("]\n");

    // 0a.
    int res = HAL_Init(1, addrs);
    if (res < 0)
    {
        return res;
    }

    // 0b. Add direct routes
    // For example:
    // 10.0.0.0/24 if 0
    // 10.0.1.0/24 if 1
    // 10.0.2.0/24 if 2
    // 10.0.3.0/24 if 3
    for (uint32_t i = 2; i < N_IFACE_ON_BOARD; i++)
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

        update(true, entry);
    }

    uint64_t last_time = 0;
    int buffer_header = 0;
    while (1)
    {
        uint64_t time = HAL_GetTicks();
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
                HAL_SendIPPacket(i, output, len, multicastingMAC);
            }
            last_time = time;
        }

        int mask = (1 << N_IFACE_ON_BOARD) - 1;
        macaddr_t src_mac;
        macaddr_t dst_mac;
        int if_index;
        res = HAL_ReceiveIPPacket(buffer_header, packet, src_mac, dst_mac, 1000, &if_index);
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

        // 1. validate
        if (!validateIPChecksum(packet, res))
        {
            printf("Invalid IP Checksum\n");
            continue;
        }
        // DONE: extract src_addr and dst_addr from packet
        // big endian
        in_addr_t src_addr = *(uint32_t *)(packet + 12), dst_addr = *(uint32_t *)(packet + 16);

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
            if (disassemble(packet, res, &rip))
            {
                if (rip.command == 1)
                {
                    // 3a.3 request, ref. RFC2453 3.9.1
                    // only need to respond to whole table requests in the lab
                    // but horizontal split also needs considering here
                    printf("RIP request\n");
                    // send it back
                    HAL_SendIPPacket(if_index, output, packetAssemble(routingTable(if_index), addrs[if_index], src_addr), src_mac);
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
        else
        {
            // 3b.1 dst is not me
            // forward
            // beware of endianness
            uint32_t nexthop, dest_if;
            if (query(dst_addr, &nexthop, &dest_if))
            {
                // found
                macaddr_t dest_mac;
                // direct routing
                if (nexthop == 0)
                {
                    nexthop = dst_addr;
                }
                if (true)
                { // SOS
                    // if (HAL_ArpGetMacAddress(dest_if, nexthop, dest_mac) == 0) {
                    // found
                    for (int i = 0; i < res; i++)
                        output[i] = packet[i];
                    // update ttl and checksum
                    if (forward(output, res))
                    {
                        // DONE: you might want to check ttl=0 case
                        if (packet[8])
                        {
                            HAL_SendIPPacket(dest_if, output, res, dest_mac);
                        }
                        else
                        {
                            printf("TTL decreased to 0.\n");
                        }
                    }
                    else
                    {
                        printf("Checksum does not match.\n");
                    }
                }
                else
                {
                    // not found
                    // you can drop it
                    printf("ARP not found for %d\n", nexthop);
                }
            }
            else
            {
                // not found
                // optionally you can send ICMP Host Unreachable
                printf("IP not found for %x\n", src_addr);
            }
        }
    }
    return 0;
}
