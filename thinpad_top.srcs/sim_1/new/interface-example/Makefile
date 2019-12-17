
# disable builtin rules
MAKEFLAGS += --no-builtin-rules

TARGET ?= mips-mti-elf
PYTHON ?= python

PROGRAM ?= clock

.PHONY: clean all move

all: $(PROGRAM).d move

$(PROGRAM).o: $(PROGRAM).s
	$(TARGET)-as -mips32 -EL $^ -o $@

# routerio.d: routerio.o
# 	$(TARGET)-objdump -D $^ -M no-aliases,gpr-names=numeric > $@
header.bin: header_gen.py
	$(PYTHON) header_gen.py

%.s.o: %.c
	$(TARGET)-gcc -c $^ -EL -o $@ -ffreestanding -mips32r2

%.o: %.s.o
	$(TARGET)-ld -EL $^ -o $@

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