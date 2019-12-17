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
    volatile int * ptr = (int *) BUFFER_TAIL_ADDRESS;
    while (1) {
        if (*ptr != sys_index) break;
    }
    return BUFFER_BASE_ADDRESS + ((sys_index ++) << 11);
}
void send_packet(PTR addr) {
    const PTR SEND_CONTROL_ADDRESS = 0xBFD00408;
    const PTR SEND_STATE_ADDRESS = 0xBFD00404;
    volatile int * ptr = (int *) SEND_STATE_ADDRESS;
    while (1) {
        if (*ptr == 0) break;
    }
    *(PTR*)SEND_CONTROL_ADDRESS = addr;
}