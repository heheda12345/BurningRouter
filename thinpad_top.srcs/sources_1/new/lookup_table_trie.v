#include "router.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <string>
#include <arpa/inet.h>
using namespace std;
const int N = 1e7;
struct TrieEntry {
    TrieEntry(uint32_t nextHop = 0, uint32_t child = 0, uint8_t nextPort = 0, uint8_t maskLen = 0, bool vaild = 0) :
        nextHop(nextHop), child(child), nextPort(nextPort), maskLen(maskLen), valid(valid) {}
    uint32_t nextHop;
    uint32_t child;
    uint8_t nextPort, maskLen;
    bool valid;
    void outit() {
        printf("valid %u\tlen %u\thop %u\tchild %u\n",
            (unsigned) valid,
            (unsigned) maskLen,
            (unsigned) nextHop,
            (unsigned) child);
    }
};

const int root = 1;
enum State { INIT, INS_READ, INS_ADDNODE, INS_UPDATE, QUE_READ, PAUSE, WAIT_FOR_END};

void print_state(State state) {
    switch (state) {
        case INIT:
            printf("INIT");
            break;
        case INS_READ:
            printf("INS_READ");
            break;
        case INS_ADDNODE:
            printf("INS_ADDNODE");
            break;
        case INS_UPDATE:
            printf("INS_UPDATE");
            break;
        case QUE_READ:
            printf("QUE_READ");
            break;
        case PAUSE:
            printf("PAUSE");
            break;
        case WAIT_FOR_END:
            printf("WAIT_FOR_END");
            break;
    }
    printf("\n");
}

struct Trie {
    TrieEntry rootInfo;
    TrieEntry tr[N][16];
    int node_cnt;

    void init() {
        node_cnt = 1;
    }

    void insert(unsigned addr, uint8_t len, unsigned nexthop) {
        // printf("insert %x %d %d\n", addr, len, nexthop);
        uint8_t dep;
        int cur = root, next_node, read_addr, write_addr;
        State nextState = INIT, state = PAUSE;
        bool read_enable = false, write_enable = false;
        TrieEntry entry, entry_to_write, entry_read;
        int read_child, write_child;
        int upd_child, upd_last;
        uint32_t ans = 0;
        while (nextState != PAUSE) {
            // syn
            if (read_enable) {
                entry_read = tr[read_addr][read_child];
                // printf("read from %d %d: ", read_addr, read_child);
                // entry_read.outit();
            }
            if (write_enable) {
                // printf("write to %d %d:", write_addr, write_child);
                // entry_to_write.outit();
                tr[write_addr][write_child] = entry_to_write;
            }
            if (nextState == INS_READ || nextState == INS_ADDNODE) {
                cur = next_node;
            }
            if ((state == INS_READ || state == INS_ADDNODE) &&
                (nextState == INS_READ || nextState == INS_ADDNODE)) {
                dep -= 4;
                len -= 4;
            } 
            
            state = nextState;
            read_enable = false;
            write_enable = false;
            // print_state(state);
            // printf("dep %d len %d\n", dep, len);
            // syn end

            switch (state) {
                case INIT: {
                    if (len == 0) {
                        rootInfo.nextHop = nexthop;
                        rootInfo.valid = 1;
                        rootInfo.maskLen = 0;
                        nextState = PAUSE;
                    } else {
                        nextState = INS_READ;
                        next_node = read_addr = root;
                        read_child = addr >> 28 & 15;
                        dep = 28;
                        read_enable = true;
                    }
                    break;
                }
                case INS_READ: {
                    next_node = entry_read.child;
                    entry = entry_read;
                    if (len <= 4) {
                        nextState = INS_UPDATE;
                        switch (len) {
                            case 4:
                                upd_child = addr >> dep & 15;
                                upd_last = upd_child;
                                break;
                            case 3:
                                upd_child = addr >> dep & 14;
                                upd_last = upd_child | 1;
                                break;
                            case 2:
                                upd_child = addr >> dep & 12;
                                upd_last = upd_child | 3;
                                break;
                            case 1:
                                upd_child = addr >> dep & 8;
                                upd_last = upd_child | 7;
                                break;
                            default:
                                break;
                        }
                        read_enable = true;
                        read_addr = cur;
                        read_child = upd_child;
                    } else if (next_node == 0) {
                        node_cnt += 1;
                        entry_to_write = entry_read;
                        entry_to_write.child = next_node = node_cnt;
                        write_addr = cur;
                        write_child = addr >> dep & 15;
                        write_enable = true;
                        nextState = INS_ADDNODE;
                    } else {
                        nextState = INS_READ;
                        read_addr = next_node;
                        read_child = addr >> (dep-4) & 15;
                        read_enable = true;
                    }
                    break;
                }
                case INS_ADDNODE: {
                    if (len <= 4) {
                        nextState = INS_UPDATE;
                        switch (len) {
                            case 4:
                                upd_child = addr >> dep & 15;
                                upd_last = upd_child;
                                break;
                            case 3:
                                upd_child = addr >> dep & 14;
                                upd_last = upd_child | 1;
                                break;
                            case 2:
                                upd_child = addr >> dep & 12;
                                upd_last = upd_child | 3;
                                break;
                            case 1:
                                upd_child = addr >> dep & 8;
                                upd_last = upd_child | 7;
                                break;
                            default:
                                break;
                        }
                        read_enable = true;
                        read_addr = cur;
                        read_child = upd_child;
                    } else {
                        node_cnt += 1;
                        entry_to_write = TrieEntry();
                        entry_to_write.child = next_node = node_cnt;
                        write_addr = cur;
                        write_child = addr >> dep & 15;
                        write_enable = true;
                        nextState = INS_ADDNODE;
                    }
                    break;
                }
                case INS_UPDATE: {
                    if (!entry_read.valid || len > entry_read.maskLen) {
                        write_enable = true;
                        entry_to_write = entry_read;
                        entry_to_write.maskLen = len;
                        entry_to_write.nextHop = nexthop;
                        entry_to_write.valid = true;
                        write_addr = cur;
                        write_child = upd_child;
                    }
                   
                    if (upd_child == upd_last) {
                        nextState = WAIT_FOR_END; // wait for end用来保证最后一次写入，在硬件上可删除
                    } else {
                        upd_child = upd_child + 1; //需要阻塞
                        read_enable = true;
                        read_addr = cur;
                        read_child = upd_child;
                        nextState = INS_UPDATE;
                    }
                    break;
                }
                case WAIT_FOR_END: {
                    nextState = PAUSE;
                    break;
                }
            }
        }
    }

    unsigned query(unsigned addr) {
        // printf("query %x\n", addr);
        int cur_dep = 28;
        State state, nextState = INIT;
        bool read_enable = false;
        unsigned read_addr;
        unsigned read_child;
        TrieEntry entry_read;
        int ans = rootInfo.nextHop; // 但可能为空
        while (nextState != PAUSE) {
            if (read_enable) {
                entry_read = tr[read_addr][read_child];
                // printf("read from %d %d: ", read_addr, read_child);
                // entry_read.outit();
            }
            if (nextState == QUE_READ) {
                cur_dep -= 4;
            }
            state = nextState;
            read_enable = false;
            // print_state(state);
            // printf("cur_dep %d child %d\n", cur_dep, addr >> cur_dep & 15);
            // sync end
            switch (state) {
                case INIT: {
                    read_addr = root;
                    read_child = addr >> cur_dep & 15;
                    read_enable = true;
                    nextState = QUE_READ;
                    break;
                }
                case QUE_READ: {
                    if (entry_read.valid) {
                        ans = entry_read.nextHop;
                    }
                    if (entry_read.child) {
                        read_addr = entry_read.child;
                        read_child = addr >> cur_dep & 15;
                        read_enable = true;
                    }
                    if (cur_dep == 0) {
                        nextState = WAIT_FOR_END;
                    } else if (entry_read.child) {
                        nextState = QUE_READ;
                    } else {
                        nextState = PAUSE;
                    }
                    break;
                }
                case WAIT_FOR_END: {
                    if (entry_read.valid) {
                        ans = entry_read.nextHop;
                    }
                    nextState = PAUSE;
                }
            }
        }
        return ans;
    }
} tr;

unsigned rd() {
    unsigned ret = 23;
    for (int i=0; i<5; i++)
        ret = ret * 23333 + rand();
    return ret;
}

void insert(const RoutingTableEntry &entry) {
    tr.insert(htonl(entry.addr), entry.len, entry.nexthop);
}

void init(int n, int q, const RoutingTableEntry *a) {
    int *b = new int[n];
    tr.init();
    for (int i=0; i<n; i++)
        b[i] = i;
    for (int i=2; i<n; i++)
        swap(b[rd()%i], b[i]);
    // for (int i=0; i<n; i++)
    //     printf("%d ", b[i]);
    // printf("\n");
    for (int i=0; i<n; i++)
        insert(a[b[i]]);
}

unsigned query(unsigned addr) {
    unsigned ans = tr.query(htonl(addr));
	return ans;
}

int main() {
    int n;
    scanf("%d", &n);
    RoutingTableEntry* entry = new RoutingTableEntry[n]; 
    for (int i=0; i<n; i++) {
        unsigned addr;
        int len, nexthop;
        scanf("%u%d%d", &addr, &len, &nexthop);
        entry[i].addr = addr;
        entry[i].len = len;
        entry[i].nexthop = nexthop;
    }
    init(n, 0, entry);
    uint32_t nextHop;
    uint32_t child;
    uint8_t nextPort, maskLen;
    tr.rootInfo.outit();
    for (int i=1; i<=tr.node_cnt; i++) {
        printf("%d:\t", i);
        for (int j=0; j<16; j++) {
            if (j)
                printf("\t");
            printf("[%02d] ", j);
            tr.tr[i][j].outit();
        }
        // tr.tr[i][1].outit();
        // printf("\t");
        // tr.tr[i][2].outit();
    }
    int m;
    scanf("%d", &m);
    for (int i=0; i<m; i++) {
        unsigned addr;
        scanf("%u", &addr);
        printf("%u\n", query(addr));
    }
    delete[] entry;
    return 0;
}
