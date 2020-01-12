#pragma once
#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif
    void putc(char ch);
    uint8_t getc();
    uint32_t getlen();
    void puts(const char *s, int len);
    void puthex(uint32_t num);
    void bootloader();
    void halt(uint32_t epc);
#ifdef __cplusplus
}
#endif