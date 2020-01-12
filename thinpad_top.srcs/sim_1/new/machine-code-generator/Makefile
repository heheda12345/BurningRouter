########### Makefile of MIPS

BACKEND=MIPS

# disable builtin rules
MAKEFLAGS += --no-builtin-rules

TARGET = mips-linux-gnu
PYTHON = python3

PROGRAM = boilerplate

SOURCES=$(wildcard *.cpp)
# SOURCES = main.cpp bootloader.cpp utility.cpp ta_hal.cpp
# SOURCES = main.cpp bootloader.cpp
HEADERS=$(wildcard *.h)
OBJECTS=$(SOURCES:%.cpp=%.cpp.o)
DUMPS=$(SOURCES:%.cpp=%.d)
COMP_FLGAS= -msingle-float -nostdlib -ffunction-sections -fdata-sections -ffreestanding -mxgot -fno-builtin -fno-PIC -fno-PIE -mno-abicalls -g -EL -mhard-float -mips32
CXXFLAGS=$(COMP_FLGAS) -std=c++11 -DROUTER_BACKEND_$(BACKEND)
CFLAGS=$(COMP_FLGAS) -Wno-implicit-function-declaration
LDFLAGS= -static -EL -nostdlib --nmagic


.PHONY: clean all move

all: baseram.mem $(PROGRAM).d $(DUMPS)

	
bootloader.s.o: bootloader.s
	$(TARGET)-as -mips32 -EL -msingle-float $^ -o $@

%.cpp.o: %.cpp
	$(TARGET)-g++ $(CXXFLAGS) -c $^ -o $@

$(PROGRAM).o: $(OBJECTS) bootloader.s.o boot.lds
	$(TARGET)-ld $(LDFLAGS) $^ -T boot.lds -o $@

$(PROGRAM).bin: $(PROGRAM).o
	$(TARGET)-objcopy -O binary $^ -j .text -j .rodata -j .data $@

%.d: %.cpp.o
	$(TARGET)-objdump -D $^ -M no-aliases,gpr-names=numeric > $@

$(PROGRAM).d: $(PROGRAM).o
	$(TARGET)-objdump -D $^ -M no-aliases,gpr-names=numeric > $@

baseram.mem: $(PROGRAM).bin
	cat $(PROGRAM).bin > baseram.mem 

move: baseram.mem
	cp baseram.mem ../

clean:
	rm -f *.o *.d *.p baseram.mem *.bin