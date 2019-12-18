/**
 * A demo/test how to send and receive packet.
 */ 
#define PTR unsigned int
PTR receive_packet();
int send_packet(PTR addr);
const PTR BUFFER_TAIL_ADDRESS = 0xBFD00400;
const PTR BUFFER_BASE_ADDRESS = 0x80600000;
const PTR SEND_CONTROL_ADDRESS = 0xBFD00408;
const PTR SEND_STATE_ADDRESS = 0xBFD00404;
const int BUF_SIZE = 1<<7;

int sys_index = 0;
int overrun = 0;

int main() {
    sys_index = overrun = 0;
    PTR ptr;
    while (1) {
        ptr = receive_packet();
        int len = *(int*)ptr;
        if (40 - len != 0) continue;
        send_packet(ptr);
    }
    return 0;
}

PTR receive_packet() {
    volatile int * ptr = (int *) BUFFER_TAIL_ADDRESS;
    int tail;
    while (1) {
        tail = *ptr;
        if (tail != sys_index) break;
    }
    // overrun = tail <= sys_index;
    PTR ret = BUFFER_BASE_ADDRESS + (sys_index << 11);
    sys_index = (sys_index + 1) & ~BUF_SIZE;
    return ret;
}
int send_packet(PTR addr) {
    volatile int * ptr = (int *) SEND_STATE_ADDRESS;
    if (*ptr & 2 | overrun) {
        // if (sys_index <= *(int *) BUFFER_TAIL_ADDRESS)
            return 1;
    }
    while (1) {
        if ((*ptr & 1) == 0) break;
    }
    *(PTR*)SEND_CONTROL_ADDRESS = addr;
    return 0;
}