#ifndef __ROUTER_TABLE_H__
#define __ROUTER_TABLE_H__

const int MAX_ROUTER_NODE = 1024;

struct TrieEntry
{
    TrieEntry(unsigned nextHop, unsigned if_index, unsigned maskLen, unsigned valid, unsigned metric);
    TrieEntry &operator=(TrieEntry r);

    unsigned nextHop;
    unsigned if_index, maskLen;
    bool valid;
    unsigned metric;
    unsigned child[16];

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
    void output();
};

#endif