#ifndef __ROUTER_TABLE_H__
#define __ROUTER_TABLE_H__

#include "router.h"

struct TrieEntry
{
    TrieEntry(unsigned nextHop, unsigned if_index, unsigned maskLen, unsigned valid, unsigned metric);
    TrieEntry &operator=(TrieEntry r);
    bool operator!=(TrieEntry r) const;

    /**
     * @param addr little endiness
     */
    RoutingTableEntry toRoutingTableEntry(uint32_t addr);

    unsigned nextHop;  // 小端序
    unsigned if_index; // 小端序
    unsigned maskLen;  // 小端序
    bool valid;
    unsigned metric; // 小端序
    unsigned child[4];

    void outit()
    {
        // printf("valid %u\tlen %u\thop %u\tchild ",
        //        (unsigned)valid,
        //        (unsigned)maskLen,
        //        (unsigned)nextHop);
        // for (int i = 0; i < 4; i++)
        // {
        //     printf("[%u\t%u\t%u\t%u]\t", child[4 * i], child[4 * i + 1], child[4 * i + 2], child[4 * i + 3]);
        // }
        // printf("\n");
    }
};

struct Trie
{
    Trie();

    TrieEntry tr[MAX_ROUTER_NODE];
    int node_cnt;

    bool insert(unsigned addr, unsigned len, unsigned nexthop, unsigned if_index, unsigned metric);
    bool query(unsigned addr, unsigned *nexthop, unsigned *if_index);
    int getEntries(RoutingTableEntry *entries, int if_index);
    int getEntriesRec(int node, uint32_t addr, RoutingTableEntry *entries, int if_index);
    void output();
};

#endif