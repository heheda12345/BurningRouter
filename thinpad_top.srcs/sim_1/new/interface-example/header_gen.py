import struct

# append additional instruction bin codes to header.bin

f = open('header.bin', 'wb')
instruction = 0x3C1D8080 # lui sp, 0x8080
f.write(struct.pack('<I', instruction))
instruction = 0x3C1F0000 # lui ra, 0x0
f.write(struct.pack('<I', instruction))
instruction = 0x3C1E0000 # lui fp, 0x0
f.write(struct.pack('<I', instruction))
instruction = 0x3C100000 # lui s0, 0x0
f.write(struct.pack('<I', instruction))
f.close()