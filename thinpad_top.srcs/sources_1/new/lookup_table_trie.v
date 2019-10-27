module lookup_table_trie (
    input wire lku_clk, lku_rst,
    input wire opt, // 1-query 2-insert 3-delete(not implement)
    output reg lku_ready,

    // interface for query
    input wire [31:0] query_in_addr,
    input wire query_in_ready,
    output reg [31:0] query_out_nexthop,
    output reg [1:0] query_out_nextport,
    output reg query_out_ready,

    // interface for insert/delete
    input wire [31:0] modify_in_addr,
    input wire modify_in_ready,
    input wire [1:0] modify_in_nexthop,
    input wire [1:0] modify_in_nextport,
    input wire [6:0] modify_in_len,
    output reg modify_finish,
    output reg modify_succ // not implement, assume there are enough space
);

parameter LOOKUP_OPT_QUERY = 1;
parameter LOOKUP_OPT_INSERT = 2;
parameter LOOKUP_OPT_DELETE = 3;
// state 
parameter STATE_PAUSE = 3'b000;
parameter STATE_INS_READ = 3'b001;
parameter STATE_INS_SET = 3'b010;
parameter STATE_INS_UPD_SELF = 3'b011;
parameter STATE_INS_UPD_ROOT = 3'b100;
parameter STATE_QUE_READ = 3'b101;
parameter STATE_WAIT_END = 3'b110;

parameter ENTRY_WIDTH = 293;
parameter ENTRY_ADDR_WIDTH = 16;
parameter ENTRY_ADDR_MAX = 1024;

//one trie node
parameter CHILD_BEGIN = 0;
parameter CHILD_END = 255;
parameter NXT_HOP_BEGIN = 256;
parameter NXT_HOP_END   = 287;
parameter NXT_PORT_BEGIN = 288;
parameter NXT_PORT_END = 289;
parameter LEN_BEGIN = 290;
parameter LEN_END = 291;
parameter VALID_POS = 292;

reg[ENTRY_ADDR_WIDTH-1: 0] read_addr, write_addr;
reg[ENTRY_WIDTH-1: 0] entry, entry_read, entry_to_write;
reg read_enable = 0, write_enable = 0;
reg[2:0] state = STATE_PAUSE, next_state = STATE_PAUSE;
reg[31:0] lookup_addr;
reg[1:0] lookup_port;
reg[31:0] lookup_nexthop;
reg[6:0] len, dep;
reg[ENTRY_ADDR_WIDTH-1:0] cur, node_cnt;

reg[3:0] upd_child;
reg set_entry_upd_child = 0, set_entry_write_child = 0;

parameter[3:0] upd_mask[4] = {8, 12, 14, 15};
parameter[3:0] upd_extend[4] = {7, 3, 1, 0};

assign cur_child = lookup_addr >> dep & 15;
assign cur_mask_child = lookup_addr >> dep & upd_mask[(len-1)&3];

pm_memory_sdpram #(
    .ADDR_WIDTH_A(ENTRY_ADDR_WIDTH),
    .ADDR_WIDTH_B(ENTRY_ADDR_WIDTH),
    .READ_DATA_WIDTH_B(ENTRY_WIDTH),
    .READ_LATENCY_B(0),
    .WRITE_DATA_WIDTH_A(ENTRY_WIDTH),
    .MEMORY_SiZE(ENTRY_ADDR_MAX * ENTRY_WIDTH),
    .USE_MEM_INIT(1)
) trie_sdpram (
    .addra(write_addr),
    .clka(lku_clk),
    .dina(entry_to_write),
    .ena(write_enable),
    .wea(8'b11111111),

    .addrb(read_addr),
    .clkb(lku_clk),
    .enb(read_enable),
    .doutb(entry_read)
);

initial begin
    node_cnt = 1;
end

always @(posedge lku_clk) begin
    state <= next_state;
end

// state machine
always @(posedge lku_clk) begin
    case (next_state)
        STATE_PAUSE:
            if (modify_in_ready) begin
                dep <= 28;
                read_addr <= 1;
                lookup_addr <= modify_in_addr;
                lookup_port <= modify_in_nextport;
                lookup_nexthop <= modify_in_nexthop;
                len <= modify_in_len;
                if (modify_in_len == 0)
                    next_state <= STATE_INS_UPD_ROOT;
                else
                    next_state <= STATE_INS_READ;
                write_enable <= 0;
                read_enable <= 1;
            end else if (query_in_ready) begin
                dep <= 28;
                read_addr <= 1;
                next_state <= STATE_QUE_READ;
                query_out_nexthop <= 0;
                query_out_nextport <= 0;
                read_enable <= 1;
                write_enable <= 0;
            end else begin
                next_state <= STATE_PAUSE;
                read_enable <= 0;
                write_enable <= 0;
            end
        STATE_INS_UPD_ROOT:
            entry_to_write <= {1'b1, 2'b00, lookup_port, lookup_nexthop, entry_read[CHILD_END:CHILD_BEGIN]};
            write_addr <= 1;
            write_enable <= 1;
            read_enable <= 0;
            next_state <= WAIT_FOR_END;
        STATE_INS_READ:
            if (len <= 4) begin
                upd_child <= cur_mask_child;
                upd_last <= cur_mask_child | upd_extend[len-1];
                cur <= read_addr;
                if (entry_read[(cur_mask_child<<4)+15:(cur_mask_child<<4)] == 0) begin
                    node_cnt <= node_cnt + 1;
                    entry <= entry_read;
                    set_entry_upd_child <= 1;
                    entry_read <= 0;
                    read_addr <= node_cnt + 1;
                    read_enable <= 0;
                    write_enable <= 0;
                end else begin
                    read_addr <= entry_read[(cur_mask_child<<4)+15:(cur_mask_child<<4)]
                    read_enable <= 1;
                    write_enable <= 0;
                end
                next_state <= STATE_INS_SET;
            end else begin
                upd_child <= cur_child;
                entry <= entry_read;
                if (entry_read[(cur_child<<4)+15 : cur_child<<4] == 0) begin
                    entry_to_write <= entry_read;
                    set_entry_write_child <= 1;
                    write_addr <= read_addr;
                    write_enable <= 1;
                    read_enable <= 0;
                    entry_read <= 0;
                    read_addr <= node_cnt + 1;
                    node_cnt <= node_cnt + 1;
                    // do len-=4, dep-=4 in set_entry_write_child
                end else begin
                    read_addr <= entry_read[(cur_child<<4)+15 : cur_child<<4];
                    read_enable <= 1;
                    write_enable <= 0;
                    len <= len-4;
                    dep <= dep-4;
                end
                next_state <= STATE_INS_READ;
            end
        STATE_INS_SET: 
            if (entry_read[VALID_POS] == 0 || entry_read[LEN_END:LEN_BEGIN] < len-1)
                entry_to_write <= {1'b1, len-1, lookup_port, lookup_nexthop, entry_read[CHILD_END: CHILD_BEGIN]}
            else
                entry_to_write <= entry_read;
            write_enable <= 1;
            write_addr <= read_addr;
            if (upd_child != upd_last) begin
                if (entry[((upd_child+1) << 4) + 15: ((upd_child+1) << 4)] == 4'b0000) begin
                    entry <= entry_read;
                    set_entry_upd_child <= 1;
                    entry_read <= 0;
                    read_addr <= node_cnt + 1;
                    node_cnt <= node_cnt + 1;
                    read_enable <= 0;
                end else begin
                    read_addr <= entry[((upd_child+1) << 4) + 15: ((upd_child+1) << 4)];
                    read_enable <= 1;
                end
                upd_child <= upd_child + 1;
                next_state <= STATE_INS_SET;
            end else begin
                next_state <= STATE_INS_UPD_SELF;
                read_enable <= 0;
                write_enable <= 0;
            end
        STATE_INS_UPD_SELF:
            entry_to_write <= entry;
            write_addr <= cur;
            write_enable <= 1;
            read_enable <= 0;
            next_state <= WAIT_FOR_END;
        WAIT_FOR_END:
            next_state <= STATE_PAUSE;
            read_enable <= 0;
            write_enable <= 0;
        
        STATE_QUE_READ:
            if (entry_read[VALID_POS] == 1) begin
                query_out_nexthop <= entry_read[NXT_HOP_END: NXT_HOP_BEGIN];
                query_out_nextport <= entry_read[NXT_PORT_END: NXT_PORT_BEGIN];
            end
            write_enable <= 0;
            if (entry_read[(cur_child<<4)+15 : cur_child<<4] > 0) begin
                read_addr <= entry_read[(cur_child<<4)+15 : cur_child<<4];
                read_enable <= 1;
                next_state <= STATE_QUE_READ;
                dep <= dep-4;
            end else begin
                next_state <= STATE_PAUSE;
                read_enable <= 0;
            end
    endcase
end

always @(posedge lku_clk) begin
    if (state == WAIT_FOR_END && next_state == STATE_PAUSE) begin
        modify_finish <= 1;
        modify_succ <= 1;
    end else begin
        modify_finish <= 0;
        modify_succ <= 0;
    end
    if (state == STATE_QUE_READ && next_state == STATE_PAUSE)
        query_out_ready <= 1;
    else
        query_out_ready <= 0;
end

always @(posedge set_entry_upd_child) begin
    set_entry_upd_child <= 0;
    entry[(upd_child<<4)+15 : upd_child<<4] <= node_cnt;
end

always @(posedge set_entry_write_child) begin
    set_entry_write_child <= 0;
    entry_to_write[(cur_child<<4)+15 : cur_child<<4] <= node_cnt;
    len <= len-4;
    dep <= dep-4;
end

endmodule