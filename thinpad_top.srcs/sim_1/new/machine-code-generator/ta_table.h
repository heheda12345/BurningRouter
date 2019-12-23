#pragma once

#include "utility.h"

/**
 * @ip 小端序
 * @nexthop 小端序
 * @len 小端序
 * @interface 小端序：one onf {0, 1, 2, 3}
 */
void InsertHardwareTable(uint32_t ip, uint32_t nexthop, uint8_t len, uint8_t interface);

// Check if the routing table on the hardware is full.
bool isHardwareTableFull();