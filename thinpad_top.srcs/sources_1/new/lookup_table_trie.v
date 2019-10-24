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
    TrieEntry(unsigned nextHop = 0, unsigned nextPort = 0, unsigned maskLen = 0, unsigned valid = 0) :
        nextHop(nextHop), nextPort(nextPort), maskLen(maskLen), valid(valid) {
            memset(child, 0, sizeof(child));
        }
    unsigned nextHop;
    unsigned nextPort, maskLen;
    unsigned valid;
    unsigned child[16];
    
    void outit() {
        printf("valid %u\tlen %u\thop %u\tchild ",
            (unsigned) valid,
            (unsigned) maskLen,
            (unsigned) nextHop);
        for (int i=0; i<4; i++) {
            printf("[%u\t%u\t%u\t%u]\t", child[4*i], child[4*i+1], child[4*i+2], child[4*i+3]);
        }
        printf("\n");
    }
};

const int root = 1;
enum State { INIT, INS_READ, INS_SET, INS_UPD_SELF, INS_UPD_ROOT, QUE_READ, PAUSE, WAIT_FOR_END};

void print_state(State state) {
    switch (state) {
        case INIT:
            printf("INIT");
            break;
        case INS_READ:
            printf("INS_READ");
            break;
        case INS_SET:
            printf("INS_SET");
            break;
        case INS_UPD_ROOT:
            printf("INS_UPD_ROOT");
            break;
        case INS_UPD_SELF:
            printf("INS_UPD_SELF");
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
        default:
            printf("UNSUPPORT STATE");
            break;
    }
    printf("\n");
}

struct Trie {
    TrieEntry tr[N];
    int node_cnt;

    void init() {
        node_cnt = 1;
    }

    void insert(unsigned addr, unsigned len, unsigned nexthop) {
        // printf("insert %x %u %d\n", addr, len, nexthop);
        // init
        State state = PAUSE;
        bool read_enable = 0, write_enable = 0;
        int upd_mask[4] = {8, 12, 14, 15};
        int upd_extend[4] = {7, 3, 1, 0};
        
        //init end
        int dep;
        int read_addr, write_addr, cur;
        TrieEntry entry, entry_read, entry_to_write;
        int upd_child, upd_last;

        // PAUSE
        dep = 28;
        read_addr = 1;
        read_enable = 1;
        if (len == 0) {
            state = INS_UPD_ROOT;
        } else {
            state = INS_READ;
        }

        while (state != PAUSE) {
            //syn
            if (read_enable) {
                entry_read = tr[read_addr];
                // printf("read  %d: ", read_addr);
                // entry_read.outit();
            }
            if (write_enable) {
                tr[write_addr] = entry_to_write;
                // printf("write %d: ", write_addr);
                // entry_to_write.outit();
            }
            read_enable = write_enable = 0;
            // printf("\n");
            // print_state(state);
            // printf("cur_read "); entry_read.outit();
            //syn end

            switch (state) {
                case INS_UPD_ROOT: {
                    entry_to_write = entry_read;
                    entry_to_write.nextHop = nexthop;
                    entry_to_write.valid = 1;
                    write_enable = true;
                    write_addr = 1;
                    state = WAIT_FOR_END;
                    break;
                }
                case INS_READ: {
                    if (len <= 4) {
                        upd_child = addr >> dep & upd_mask[len-1];
                        upd_last = upd_child | upd_extend[len-1];
                        entry = entry_read;
                        cur = read_addr;
                        // printf("cur %d upd_child %d upd_last %d\n", cur, upd_child, upd_last);
                        if (entry.child[upd_child] == 0) {
                            node_cnt++;
                            entry.child[upd_child] = node_cnt;
                            entry_read = TrieEntry();
                            read_addr = node_cnt; // 装作这是读出来的
                        } else {
                            read_addr = entry.child[upd_child];
                            read_enable = true;
                        }
                        state = INS_SET;
                    } else {
                        upd_child = addr >> dep & 15;
                        // printf("upd_child %d\n", upd_child);
                        entry = entry_read;
                        if (entry.child[upd_child] == 0) {
                            entry_to_write = entry_read;
                            node_cnt++;
                            // printf("node_cnt %d\n", node_cnt);
                            entry_to_write.child[upd_child] = node_cnt;
                            write_addr = read_addr;
                            write_enable = true;
                            entry_read = TrieEntry();
                            // printf("setentry "); entry_read.outit();
                            read_addr = node_cnt;
                        } else {
                            read_addr = entry.child[upd_child];
                            read_enable = true;
                        }
                        len -= 4;
                        dep -= 4;
                        state = INS_READ;
                    }
                    break;
                }
                case INS_SET: {
                    entry_to_write = entry_read;
                    if (!entry_to_write.valid || entry_to_write.maskLen < len-1) {
                        entry_to_write.maskLen = len-1;
                        entry_to_write.nextHop = nexthop;
                        entry_to_write.valid = 1;
                    }
                    write_enable = true;
                    write_addr = read_addr;
                    if (upd_child != upd_last) {
                        upd_child++;
                        if (entry.child[upd_child] == 0) {
                            node_cnt++;
                            // printf("node_cnt %d\n", node_cnt);
                            entry.child[upd_child] = node_cnt;
                            entry_read = TrieEntry();
                            read_addr = node_cnt; // 装作这是读出来的
                        } else {
                            read_addr = entry.child[upd_child];
                            read_enable = true;
                        }
                        state = INS_SET;
                    } else {
                        state = INS_UPD_SELF;
                    }
                    break;
                }
                case INS_UPD_SELF: {
                    entry_to_write = entry;
                    write_addr = cur;
                    write_enable = true;
                    state = WAIT_FOR_END;
                    break;
                }
                case WAIT_FOR_END: {
                    // no work, just wait...
                    state = PAUSE;
                    break;
                }
            }
        }
    }

    unsigned query(unsigned addr) {
        // printf("query %x\n", addr);
        State state;
        bool read_enable = 0;
        //init end
        int dep;
        int read_addr;
        int ans = 0;
        int upd_child;
        TrieEntry entry, entry_read;
        {
            // PAUSE
            dep = 28;
            read_addr = 1;
            read_enable = 1;
            state = QUE_READ;
        }
        while (state != PAUSE) {
            // print_state(state);
            //syn
            if (read_enable) {
                entry_read = tr[read_addr];
            }
            read_enable = 0;
            // state machine
            switch (state)
            {
                case QUE_READ:
                    if (entry_read.valid)
                        ans = entry_read.nextHop;
                    upd_child = addr >> dep & 15;
                    if (entry_read.child[upd_child] > 0) {
                        read_addr = entry_read.child[upd_child];
                        read_enable = true;
                        state = QUE_READ;
                        dep -= 4;
                    } else {
                        state = PAUSE;
                    }
                    break;
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
    delete[] b;
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
    // for (int i=1; i<=tr.node_cnt; i++) {
    //     printf("%d:\t", i);
    //     tr.tr[i].outit();
    // }
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
