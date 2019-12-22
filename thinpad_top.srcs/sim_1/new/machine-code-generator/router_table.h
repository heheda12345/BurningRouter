#ifndef __ROUTER_TABLE_H__
#define __ROUTER_TABLE_H__

#include "router.h"

static RoutingTableEntry entries[MAX_ROUTER_NODE];
static int entryTot = 0;

struct Trie
{
    Trie();

    RoutingTableEntry *entry;
    Trie *lc, *rc;

    void insert(RoutingTableEntry entry);
    bool query(unsigned addr, unsigned *nexthop, unsigned *if_index);
    int getEntries(RoutingTableEntry *entries, int if_index);
    int getEntriesRec(int node, uint32_t addr, RoutingTableEntry *entries, int if_index);
} tries[32 * MAX_ROUTER_NODE];

#endif