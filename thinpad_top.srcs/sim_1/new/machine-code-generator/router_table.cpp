#include "router_table.h"
#include "router.h"

RoutingTableEntry entries[MAX_ENTRY_NUM];
int entryTot;

Trie tries[32 * MAX_ENTRY_NUM];
int trieTot;

void Trie_Init()
{
    entryTot = trieTot = 0;
}

Trie::Trie() : entry(nullptr), lc(nullptr), rc(nullptr) {}

bool Trie::insert(RoutingTableEntry entry)
{
    uint32_t addr = ntohl(entry.addr);

    Trie *node = this;
    for (int i = 31; i >= 32 - (int)entry.len; --i)
    {
        if (~addr >> i & 1)
        {
            if (node->lc == nullptr)
            {
                node->lc = tries + trieTot++;
            }
            node = node->lc;
        }
        else
        {
            if (node->rc == nullptr)
            {
                node->rc = tries + trieTot++;
            }
            node = node->rc;
        }
    }

    if (node->entry == nullptr || node->entry->metric > entry.metric)
    {
        node->entry = entries + entryTot;
        entries[entryTot++] = entry;

        return true;
    }
    else
    {
        return false;
    }
}

/**
 * @param addr: big endiness
 * @return: if there's an entry being queried
 * 
 * Actually won't be used in our framework.
 */
bool Trie::query(uint32_t addr, uint32_t *nexthop, uint32_t *metric, uint32_t *if_index)
{
    addr = ntohl(addr);

    bool found = false;

    Trie *node = this;

    for (int i = 32; i--;)
    {
        if (node->entry)
        {
            *nexthop = node->entry->nexthop;
            *if_index = node->entry->if_index;
            *metric = node->entry->metric;

            found = true;
        }

        if (~addr >> i & 1)
        {
            if (node->lc == nullptr)
            {
                return found;
            }
            node = node->lc;
        }
        else
        {
            if (node->rc == nullptr)
            {
                return found;
            }
            node = node->rc;
        }
    }
    if (node->entry)
    {
        *nexthop = node->entry->nexthop;
        *if_index = node->entry->if_index;
        *metric = node->entry->metric;

        found = true;
    }

    return found;
}

int Trie::getEntries(RoutingTableEntry **entries, int if_index)
{
    int tot = 0;
    if (entry && entry->if_index != if_index)
    {
        *++entries = entry;
        ++tot;
    }
    if (lc)
    {
        int lcnt = getEntries(entries, if_index);
        tot += lcnt;
        entries += lcnt;
    }
    if (rc)
    {
        tot += getEntries(entries, if_index);
    }
    return tot;
}