
# disable builtin rules
MAKEFLAGS += -r

TARGET = mipsel-linux-gnu# mips-mti-elf
PYTHON ?= python

# CC = $(TARGET)-gcc

CFLAGS = -ffreestanding -mips32r2 -EL -O2 -mno-abicalls -fno-pic

PROGRAM ?= loopback

.PHONY: clean all move
.SECONDARY: $(PROGRAM).s.o

all: $(PROGRAM).d move #

%.c.o: %.c
	$(TARGET)-gcc -c $^ -o $@ $(CFLAGS)

%.o: bootloader.o %.c.o run.lds 
	$(TARGET)-ld -EL $^ -T run.lds -o $@

bootloader.o: bootloader.s
	$(TARGET)-as -mips32 -EL $^ -o $@

# $(PROGRAM).o: $(PROGRAM).s
# 	$(TARGET)-as -mips32 -EL $^ -o $@

# routerio.d: routerio.o
# 	$(TARGET)-objdump -D $^ -M no-aliases,gpr-names=numeric > $@
header.bin: header_gen.py
	$(PYTHON) header_gen.py

%.bin: %.o
	$(TARGET)-objcopy -O binary $^ -j .text -j .rodata -j .data $@

%.d: %.o
	$(TARGET)-objdump -D $^ -M no-aliases,gpr-names=numeric > $@

baseram.mem: $(PROGRAM).bin
	cat $(PROGRAM).bin > baseram.mem 

move: baseram.mem
	cp baseram.mem ../

clean:
	rm -f *.o *.d *.p baseram.mem *.bin