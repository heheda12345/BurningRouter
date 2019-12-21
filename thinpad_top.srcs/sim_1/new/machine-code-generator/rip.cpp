#include "rip.h"

RipPacket::RipPacket() : numEntries(0), command(0)
{
    memset(entries, 0, sizeof(RipEntry) * RIP_MAX_ENTRY);
}