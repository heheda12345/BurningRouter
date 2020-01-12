#include "router.h"
#include "utility.h"
#include "rip.h"
// #include "router_table.h"
#include "ta_table.h"
#include "router_table.h"

/*
  RoutingTable Entry 的定义如下：
  typedef struct {
    uint32_t addr; // 大端序，IPv4 地址
    uint32_t len; // 小端序，前缀长度
    uint32_t if_index; // 小端序，出端口编号
    uint32_t nexthop; // 大端序，下一跳的 IPv4 地址
    uint32_t metric; // 大端序，值域为[1, 16].
  } RoutingTableEntry;

  约定 addr 和 nexthop 以 **大端序** 存储。
  这意味着 1.2.3.4 对应 0x04030201 而不是 0x01020304。
  保证 addr 仅最低 len 位可能出现非零。
  当 nexthop 为零时这是一条直连路由。
  你可以在全局变量中把路由表以一定的数据结构格式保存下来。
*/

Trie root;

/**
 * @brief 插入/删除一条路由表表项
 * @param insert 如果要插入则为 true ，要删除则为 false
 * @param entry 要插入/删除的表项
 * @param return 路由表的结构是否发生改变
 *
 * 插入时有两种情况会导致插入失败：
 * 1) 如果已经存在一条 addr 和 len 都相同的表项且metric <= 新插入的表项。
 * 2) Trie的节点数量已达到上限。
 *
 * Return: 返回是否有更新发生。
 */
bool update(bool insert, RoutingTableEntry entry)
{
    if (insert)
    {
        if (isHardwareTableFull())
        {
            return false;
        }
        if (!root.insert(entry))
        {
            return false;
        }
        InsertHardwareTable(ntohl(entry.addr), ntohl(entry.nexthop), entry.len, entry.if_index);
        return true;
    }
    else
        return false;
}

/**
 * @brief 进行一次路由表的查询，按照最长前缀匹配原则
 * @param addr 需要查询的目标地址，大端序
 * @param nexthop 如果查询到目标，把表项的 nexthop 写入，大端序
 * @param metric 大端序
 * @param if_index 如果查询到目标，把表项的 if_index 写入，小端序
 * @return 查到则返回 true ，没查到则返回 false
 */
bool query(uint32_t addr, uint32_t *nexthop, uint32_t *metric, uint32_t *if_index)
{
    return root.query(addr, nexthop, metric, if_index);
}

int getEntries(RoutingTableEntry **entries, int if_index)
{
    return root.getEntries(entries, if_index);
}

void outputTable() {}