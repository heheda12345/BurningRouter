#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <string>
using namespace std;
typedef struct {
    unsigned addr;
    unsigned len;
    unsigned nextPort;
    unsigned ty;
    unsigned nexthop;
} __attribute__((packed)) RoutingTableEntry;
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

    void insert(unsigned addr, unsigned len, unsigned nexthop, unsigned nextPort) {
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
                    entry_to_write.nextPort = nextPort;
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
                        entry_to_write.nextPort = nextPort;
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

    pair<unsigned, unsigned> query(unsigned addr) {
        // printf("query %x\n", addr);
        State state;
        bool read_enable = 0;
        //init end
        int dep;
        int read_addr;
        pair<unsigned, unsigned> ans;
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
                    if (entry_read.valid) {
                        ans = make_pair(entry_read.nextHop, entry_read.nextPort);
                    }
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
    tr.insert(entry.addr, entry.len, entry.nexthop, entry.nextPort);
}

void init() {
    tr.init();
}


int main() {
    srand(time(0));
    int n = 400;
    freopen("lookup.in", "w", stdout);
    printf("%d\n", n);
    int m = n >> 1;
    RoutingTableEntry* entry = new RoutingTableEntry[n]; 
    for (int i=0; i<m; i++) {
        entry[i].addr = rd();
        entry[i].len = rd() % 33;
        entry[i].nexthop = rd();
        entry[i].nextPort = rd() % 4;
        entry[i+m] = entry[i];
        entry[i].ty = 0;
        entry[i+m].ty = 1;
    }
    random_shuffle(entry, entry+n);
    init();
    for (int i=0; i<n; i++)
        if (entry[i].ty == 0) {
            insert(entry[i]);
        } else {
            auto ans = tr.query(entry[i].addr);
            entry[i].nexthop = ans.first;
            entry[i].nextPort = ans.second;
            entry[i].len = 0;
        }
    for (int i=0; i<n; i++)
        printf("%u %x %x %u %u\n", entry[i].ty, entry[i].addr, entry[i].nexthop, entry[i].nextPort, entry[i].len);
    delete[] entry;
    return 0;
}
