#ifndef __UTILITY_H__
#define __UTILITY_H__

#include "bootloader.h"

typedef unsigned long size_t;

struct in_addr
{
    uint32_t s_addr;
};

int getData(const uint8_t *packet, size_t index);
void writeData(uint8_t *packet, size_t index, int x);
uint8_t reverse(uint8_t b);
uint32_t calc(uint32_t addr, int len);
uint16_t IPChecksum(uint8_t *packet);

uint32_t htonl(uint32_t hl);
uint32_t ntohl(uint32_t nl);
uint16_t htons(uint16_t hs);
uint16_t ntohs(uint16_t ns);

void putchar(char c);
void printf(const char *st);
template <typename T1>
void printf(const char *st, T1 a) {}
template <typename T1, typename T2>
void printf(const char *st, T1 a, T2 b) {}
template <typename T1, typename T2, typename T3>
void printf(const char *st, T1 a, T2 b, T3 c) {}

void memset(void *s, char c, size_t len);
void memcpy(void *dst, void *src, size_t len);

unsigned min(unsigned x, unsigned y);

// parameter [x] is required to be in [0, 16)
char hextoch(int x);

#endif