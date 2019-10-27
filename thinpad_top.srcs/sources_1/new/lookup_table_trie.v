module lookup_table_trie (
    input wire lku_clk, lku_rst, //rst not implement
    
    // interface for query
    input wire [31:0] query_in_addr,
    input wire query_in_ready,
    output reg [31:0] query_out_nexthop,
    output reg [1:0] query_out_nextport,
    output reg query_out_ready,

    // interface for insert/delete
    input wire [31:0] modify_in_addr,
    input wire modify_in_ready,
    input wire [31:0] modify_in_nexthop,
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

reg[ENTRY_ADDR_WIDTH-1: 0] write_addr, read_addr;
reg[ENTRY_WIDTH-1: 0] entry, entry_to_write, entry_read;
wire[ENTRY_WIDTH-1: 0] bram_entry_read;
reg read_enable = 0, write_enable = 0;
reg[2:0] state = STATE_PAUSE, next_state = STATE_PAUSE;
reg[31:0] lookup_addr;
reg[1:0] lookup_port;
reg[31:0] lookup_nexthop;
reg[6:0] len, dep;
reg[ENTRY_ADDR_WIDTH-1:0] cur, node_cnt;

reg[3:0] upd_child, upd_last;
wire[3:0] cur_child, cur_mask_child;
reg set_entry_upd_child = 0, set_entry_write_child = 0;

reg[3:0] upd_mask[3:0];
reg[3:0] upd_extend[3:0];

assign cur_child = lookup_addr >> dep & 15;
assign cur_mask_child = lookup_addr >> dep & upd_mask[(len-1)&3];

xpm_memory_sdpram #(
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
    .doutb(bram_entry_read)
);

initial begin
    node_cnt <= 1;
    upd_mask[0] <= 8;
    upd_mask[1] <= 12;
    upd_mask[2] <= 14;
    upd_mask[3] <= 15;
    upd_extend[0] <= 7;
    upd_extend[1] <= 3;
    upd_extend[2] <= 1;
    upd_extend[3] <= 0;
end

always @(posedge lku_clk) begin
    state <= next_state;
    // if (read_enable)
        // $display("read from %d: [%d %d]-hop %d-valid %d-len %d", read_addr, bram_entry_read[31:16], bram_entry_read[47:32], bram_entry_read[NXT_HOP_END:NXT_HOP_BEGIN], bram_entry_read[VALID_POS], bram_entry_read[LEN_END:LEN_BEGIN]);
    // if (write_enable)
        // $display("write to %d: [%d %d]-hop %d-valid %d-len %d", write_addr, entry_to_write[31:16], entry_to_write[47:32], entry_to_write[NXT_HOP_END:NXT_HOP_BEGIN], entry_to_write[VALID_POS],  bram_entry_read[LEN_END:LEN_BEGIN]);
    // $display("state: %d-%d", state, next_state);
end

// state machine
always @(posedge lku_clk) begin
    case (next_state)
        STATE_PAUSE: begin
                // $display("state: pause");
                if (modify_in_ready) begin
                    $display("modify begin %h->%d", modify_in_addr, modify_in_nexthop);
                    dep <= 28;
                    read_addr <= 1;
                    lookup_addr <= modify_in_addr;
                    lookup_port <= modify_in_nextport;
                    lookup_nexthop <= modify_in_nexthop;
                    len <= modify_in_len;
                    if (modify_in_len == 0) begin
                        // $display("modify_in_len = 0");
                        next_state <= STATE_INS_UPD_ROOT;
                    end else begin
                        // $display("modify_in_len %d", modify_in_len);
                        next_state <= STATE_INS_READ;
                    end
                    write_enable <= 0;
                    read_enable <= 1;
                end else if (query_in_ready) begin
                    $display("query begin %h", query_in_addr);
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
            end
        STATE_INS_UPD_ROOT: begin
                // $display("state: insert-upd-root");
                entry_to_write <= {1'b1, 2'b00, lookup_port, lookup_nexthop, entry_read[CHILD_END:CHILD_BEGIN]};
                write_addr <= 1;
                write_enable <= 1;
                read_enable <= 0;
                next_state <= STATE_WAIT_END;
            end
        STATE_INS_READ: begin
                // $display("state: insert-read");
                if (len <= 4) begin
                    upd_child <= cur_mask_child;
                    upd_last <= cur_mask_child | upd_extend[len-1];
                    cur <= read_addr;
                    entry <= entry_read;
                    if (entry_read[(cur_mask_child<<4)+15-: 16] == 0) begin
                        node_cnt <= node_cnt + 1;
                        set_entry_upd_child <= 1;
                        read_addr <= node_cnt + 1;
                        read_enable <= 0;
                        write_enable <= 0;
                    end else begin
                        read_addr <= entry_read[(cur_mask_child<<4)+15-: 16];
                        read_enable <= 1;
                        write_enable <= 0;
                    end
                    next_state <= STATE_INS_SET;
                end else begin
                    upd_child <= cur_child;
                    entry <= entry_read;
                    // $display("check child: %d %d", cur_child, entry_read[(cur_child<<4)+15-: 16]);
                    if (entry_read[(cur_child<<4)+15-: 16] == 0) begin
                        entry_to_write <= entry_read;
                        set_entry_write_child <= 1;
                        write_addr <= read_addr;
                        write_enable <= 1;
                        read_enable <= 0;
                        read_addr <= node_cnt + 1;
                        node_cnt <= node_cnt + 1;
                        // do len-=4, dep-=4 in set_entry_write_child
                    end else begin
                        read_addr <= entry_read[(cur_child<<4)+15-: 16];
                        read_enable <= 1;
                        write_enable <= 0;
                        len <= len-4;
                        dep <= dep-4;
                    end
                    next_state <= STATE_INS_READ;
                end
            end
        STATE_INS_SET: begin
                if (entry_read[VALID_POS] == 0 || entry_read[LEN_END:LEN_BEGIN] < len-1)
                    entry_to_write <= {1'b1, (len[1:0]-1), lookup_port, lookup_nexthop, entry_read[CHILD_END: CHILD_BEGIN]};
                else
                    entry_to_write <= entry_read;
                write_enable <= 1;
                write_addr <= read_addr;
                if (upd_child != upd_last) begin
                    if (entry[((upd_child+1) << 4)+15-: 16] == 4'b0000) begin
                        entry <= entry_read;
                        set_entry_upd_child <= 1;
                        read_addr <= node_cnt + 1;
                        node_cnt <= node_cnt + 1;
                        read_enable <= 0;
                    end else begin
                        read_addr <= entry[((upd_child+1) << 4)+15-: 16];
                        read_enable <= 1;
                    end
                    upd_child <= upd_child + 1;
                    next_state <= STATE_INS_SET;
                end else begin
                    next_state <= STATE_INS_UPD_SELF;
                    read_enable <= 0;
                end
            end
        STATE_INS_UPD_SELF: begin
                entry_to_write <= entry;
                write_addr <= cur;
                write_enable <= 1;
                read_enable <= 0;
                next_state <= STATE_WAIT_END;
            end
        STATE_WAIT_END: begin
                next_state <= STATE_PAUSE;
                read_enable <= 0;
                write_enable <= 0;
            end
        STATE_QUE_READ: begin
            // $display("state query-read addr %d valid %d ans %d", read_addr, entry_read[VALID_POS], entry_read[NXT_HOP_END: NXT_HOP_BEGIN]);
            if (entry_read[VALID_POS] == 1) begin
                query_out_nexthop <= entry_read[NXT_HOP_END: NXT_HOP_BEGIN];
                query_out_nextport <= entry_read[NXT_PORT_END: NXT_PORT_BEGIN];
            end
            write_enable <= 0;
            if (entry_read[(cur_child<<4)+15-: 16] > 0) begin
                read_addr <= entry_read[(cur_child<<4)+15-: 16];
                read_enable <= 1;
                next_state <= STATE_QUE_READ;
                dep <= dep-4;
            end else begin
                next_state <= STATE_PAUSE;
                read_enable <= 0;
            end
        end
    endcase
end


// output
always @(posedge lku_clk) begin
    if (state == STATE_WAIT_END && next_state == STATE_PAUSE) begin
        modify_finish <= 1;
        modify_succ <= 1;
        $display("modify end");
    end else begin
        modify_finish <= 0;
        modify_succ <= 0;
    end
    if (state == STATE_QUE_READ && next_state == STATE_PAUSE) begin
        query_out_ready <= 1;
        $display("query end %d", query_out_nexthop);
    end else
        query_out_ready <= 0;
end

// simulate c++
always @(posedge set_entry_upd_child) begin
    set_entry_upd_child <= 0;
    entry[(upd_child<<4)+15-: 16] <= node_cnt;
end

always @(posedge set_entry_write_child) begin
    // $display("set entry write child %d: cnt %d", cur_child, node_cnt);
    set_entry_write_child <= 0;
    entry_to_write[(cur_child<<4)+15-: 16] <= node_cnt;
    len <= len-4;
    dep <= dep-4;
end

always @(bram_entry_read or read_enable) begin
    if (read_enable == 1)
        entry_read <= bram_entry_read;
    else
        entry_read <= 0;
end

endmodule