#ifndef __ROUTER_TABLE_H__
#define __ROUTER_TABLE_H__

#include "router.h"

struct Trie
{
    Trie();

    RoutingTableEntry *entry;
    Trie *lc, *rc;

    bool insert(RoutingTableEntry entry);
    bool query(uint32_t addr, uint32_t *nexthop, uint32_t *metric, uint32_t *if_index);
    int getEntries(RoutingTableEntry **entries, int if_index);
    int getEntriesRec(int node, uint32_t addr, RoutingTableEntry *entries, int if_index);
};

void Trie_Init();

#endif