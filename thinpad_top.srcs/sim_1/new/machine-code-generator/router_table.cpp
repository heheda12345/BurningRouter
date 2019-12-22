#include "utility.h"
#include "router_table.h"
#include "router.h"

Trie::Trie() : entry(nullptr), lc(nullptr), rc(nullptr) {}

// 这里所有的参数均为小端序
void Trie::insert(unsigned addr, unsigned len, unsigned nexthop, unsigned if_index, unsigned metric)
{
}

bool Trie::query(unsigned addr, unsigned *nexthop, unsigned *if_index)
{
    // printf("query %x\n", addr);
    State state;
    bool read_enable = 0;
    //init end
    int dep;
    int read_addr;
    int upd_child;
    TrieEntry entry, entry_read;
    {
        // PAUSE
        dep = 30;
        read_addr = 1;
        read_enable = 1;
        state = QUE_READ;
    }

    bool found = false;

    while (state != PAUSE)
    {
        // print_state(state);
        //syn
        if (read_enable)
        {
            entry_read = tr[read_addr];
        }
        read_enable = 0;
        // state machine
        switch (state)
        {
        case QUE_READ:
            if (entry_read.valid)
            {
                *nexthop = entry_read.nextHop;
                *if_index = entry_read.if_index;
                found = true;
            }
            upd_child = addr >> dep & 3;
            if (entry_read.child[upd_child] > 0)
            {
                read_addr = entry_read.child[upd_child];
                read_enable = true;
                state = QUE_READ;
                dep -= 2;
            }
            else
            {
                state = PAUSE;
            }
            break;
        }
    }
    return found;
}

int Trie::getEntries(RoutingTableEntry *entries, int if_index)
{
    int root_cnt = 0;
    if (tr[1].valid)
    {
        root_cnt = 1;
        entries[1] = tr[1].toRoutingTableEntry(0);
    }
    return root_cnt + getEntriesRec(0, 0, 31, entries + root_cnt, if_index);
}

int Trie::getEntriesRec(int node, uint32_t addr, RoutingTableEntry *entries, int if_index)
{
    int tot = 0, chtot;
    for (int i = 0; i < 4; ++i)
        if (tr[node].child[i])
        {
            if (tr[tr[node].child[i]].valid && tr[tr[node].child[i]].if_index != if_index && (i == 0 || tr[tr[node].child[i]] != tr[tr[node].child[i - 1]]))
            {
                entries[tot++] = tr[i].toRoutingTableEntry(addr);
            }
            chtot = getEntriesRec(tr[node].child[i], entries + tot, if_index);
            tot += chtot;
        }
    return tot;
}

void Trie::output() {}