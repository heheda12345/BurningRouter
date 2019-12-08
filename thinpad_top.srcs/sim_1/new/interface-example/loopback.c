/**
 * A demo/test how to send and receive packet.
 */ 
#define PTR unsigned int
PTR receive_packet(int);
void send_packet(PTR addr);

int main() {
    PTR ptr;
    int sys_index = 0;
    while (1) {
        ptr = receive_packet(sys_index);
        sys_index ++;
        if (sys_index == (1<<7))  sys_index = 0;
        int len = *(int*)ptr;
        if (len < 40) continue;
        send_packet(ptr);
    }
    return 0;
}

PTR receive_packet(int sys_index) {
    const PTR BUFFER_TAIL_ADDRESS = 0xBFD00400;
    const PTR BUFFER_BASE_ADDRESS = 0x80600000;
    while (1) {
        if (*(int*)(BUFFER_TAIL_ADDRESS) != sys_index) break;
    }
    return BUFFER_BASE_ADDRESS + ((sys_index ++) << 11);
}
void send_packet(PTR addr) {
    const PTR SEND_CONTROL_ADDRESS = 0xBFD00408;
    const PTR SEND_STATE_ADDRESS = 0xBFD00404;
    while (1) {
        if (*(int*)(SEND_STATE_ADDRESS) == 0) break;
    }
    *(PTR*)SEND_CONTROL_ADDRESS = addr;
}