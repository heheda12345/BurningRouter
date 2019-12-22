#include <stdint.h>
#include "bootloader.h"

volatile uint32_t *UART_RX = (uint32_t *)0xBFD003F8;
volatile uint32_t *UART_TX = (uint32_t *)0xBFD003F8;
volatile uint32_t *UART_STAT = (uint32_t *)0xBFD003FC;

void putc(char ch)
{
    while (!(*UART_STAT & 0x1))
        ;
    *UART_TX = ch;
}

uint8_t getc()
{
    while (!(*UART_STAT & 0x2))
        ;
    return (uint8_t)*UART_RX;
}

uint32_t getlen()
{
    uint32_t len = 0;
    len |= getc();
    len = len << 8;
    len |= getc();
    len = len << 8;
    len |= getc();
    len = len << 8;
    len |= getc();
    return len;
}

void puts(const char *s, int len)
{
    for (int i = 0; i < len; ++i)
    {
        putc(*(s + i));
    }
    putc('\n');
}

void puthex(uint32_t num)
{
    int i, temp;
    for (i = 7; i >= 0; i--)
    {
        temp = (num >> (i * 4)) & 0xF;
        if (temp < 10)
        {
            putc('0' + temp);
        }
        else
            putc('A' + temp - 10);
    }
}

void bootloader()
{
    //   puts("NO BOOT FAIL\r\n");
    //   uint32_t len = getlen();
    //   puts("LEN ");
    //   puthex(len);
    //   puts("\r\n");
    //   volatile uint8_t *MEM = (uint8_t *)0x80000000;
    //   for (uint32_t i = 0; i < len; i++) {
    //     *MEM = getc();
    //     MEM++;
    //   }
    puts("BT", 2);
}

void halt(uint32_t epc)
{
    // puts("AL ", 3);
    puthex(epc);
}