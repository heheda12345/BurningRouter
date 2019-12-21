#include "utility.h"
#include "router_table.h"
#include "router.h"

const int root = 1;
enum State
{
    INIT,
    INS_READ,
    INS_SET,
    INS_UPD_SELF,
    INS_UPD_ROOT,
    QUE_READ,
    PAUSE,
    WAIT_FOR_END
};

void print_state(State state)
{
    switch (state)
    {
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

TrieEntry::TrieEntry(unsigned nextHop = 0, unsigned if_index = 0, unsigned maskLen = 0, unsigned valid = 0, unsigned metric = 16) : nextHop(nextHop), if_index(if_index), maskLen(maskLen), valid(valid), metric(metric)
{
    memset(child, 0, sizeof(child));
}

TrieEntry &TrieEntry::operator=(TrieEntry r)
{
    nextHop = r.nextHop;
    if_index = r.if_index;
    maskLen = r.maskLen;
    valid = r.valid;
    metric = r.metric;
    memcpy(child, r.child, 4 * 16);
}

Trie::Trie() : node_cnt(1)
{
}

// 这里所有的参数均为小端序
bool Trie::insert(unsigned addr, unsigned len, unsigned nexthop, unsigned if_index, unsigned metric)
{
    // printf("insert %x %u %d\n", addr, len, nexthop);
    // init
    State state = PAUSE;
    bool read_enable = 0, write_enable = 0;
    int upd_mask[2] = {2, 3};
    int upd_extend[2] = {1, 0};

    //init end
    int dep;
    int read_addr, write_addr, cur;
    TrieEntry entry, entry_read, entry_to_write;
    int upd_child, upd_last;

    // PAUSE
    dep = 30;
    read_addr = 1;
    read_enable = 1;
    if (len == 0)
    {
        state = INS_UPD_ROOT;
    }
    else
    {
        state = INS_READ;
    }

    // Variables only used on CPU
    int plan_addition = 0;
    bool inserted = false;

    while (state != PAUSE)
    {
        //syn
        if (read_enable)
        {
            entry_read = tr[read_addr];
            // printf("read  %d: ", read_addr);
            // entry_read.outit();
        }
        if (write_enable)
        {
            tr[write_addr] = entry_to_write;
            // printf("write %d: ", write_addr);
            // entry_to_write.outit();
        }
        read_enable = write_enable = 0;
        // printf("\n");
        // print_state(state);
        // printf("cur_read "); entry_read.outit();
        //syn end

        switch (state)
        {
        case INS_UPD_ROOT:
        {
            inserted = true;

            entry_to_write = entry_read;

            entry_to_write.nextHop = nexthop;
            entry_to_write.if_index = if_index;
            entry_to_write.valid = 1;
            entry_to_write.metric = metric;

            write_enable = true;
            write_addr = 1;
            state = WAIT_FOR_END;
            break;
        }
        case INS_READ:
        {
            if (len <= 2)
            {
                upd_child = addr >> dep & upd_mask[len - 1];
                upd_last = upd_child | upd_extend[len - 1];
                entry = entry_read;
                cur = read_addr;
                // printf("cur %d upd_child %d upd_last %d\n", cur, upd_child, upd_last);
                if (entry.child[upd_child] == 0)
                {
                    plan_addition++;
                    entry.child[upd_child] = node_cnt + plan_addition;
                    entry_read = TrieEntry();
                    read_addr = node_cnt; // 装作这是读出来的
                }
                else
                {
                    read_addr = entry.child[upd_child];
                    read_enable = true;
                }
                state = INS_SET;
            }
            else
            {
                upd_child = addr >> dep & 3;
                // printf("upd_child %d\n", upd_child);
                entry = entry_read;
                if (entry.child[upd_child] == 0)
                {
                    entry_to_write = entry_read;
                    ++plan_addition;
                    // printf("node_cnt %d\n", node_cnt);
                    entry_to_write.child[upd_child] = node_cnt + plan_addition;
                    write_addr = read_addr;
                    write_enable = true;
                    entry_read = TrieEntry();
                    // printf("setentry "); entry_read.outit();
                    read_addr = node_cnt + plan_addition;
                }
                else
                {
                    read_addr = entry.child[upd_child];
                    read_enable = true;
                }
                len -= 2;
                dep -= 2;
                state = INS_READ;
            }
            break;
        }
        case INS_SET:
        {
            entry_to_write = entry_read;
            if (entry_read.valid == 0 || entry_to_write.maskLen < len - 1 || entry_to_write.maskLen == len && entry_to_write.metric > metric)
            {
                inserted = true;

                entry_to_write.maskLen = len - 1;
                entry_to_write.nextHop = nexthop;
                entry_to_write.if_index = if_index;
                entry_to_write.valid = 1;
            }
            write_enable = true;
            write_addr = read_addr;
            if (upd_child != upd_last)
            {
                upd_child++;
                if (entry.child[upd_child] == 0)
                {
                    ++plan_addition;
                    // printf("node_cnt %d\n", node_cnt);
                    entry.child[upd_child] = node_cnt + plan_addition;
                    entry_read = TrieEntry();
                    read_addr = node_cnt + plan_addition; // 装作这是读出来的
                }
                else
                {
                    read_addr = entry.child[upd_child];
                    read_enable = true;
                }
                state = INS_SET;
            }
            else
            {
                state = INS_UPD_SELF;
            }
            break;
        }
        case INS_UPD_SELF:
        {
            entry_to_write = entry;
            write_addr = cur;
            write_enable = true;
            state = WAIT_FOR_END;
            break;
        }
        case WAIT_FOR_END:
        {
            // no work, just wait...
            state = PAUSE;
            break;
        }
        }
    }
    if (node_cnt + plan_addition >= MAX_ROUTER_NODE)
    {
        return false;
    }
    else
    {
        node_cnt += plan_addition;
        return inserted;
    }
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
                return true;
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
    return false;
}

void Trie::output() {}