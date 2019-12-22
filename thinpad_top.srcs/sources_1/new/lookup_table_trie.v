module lookup_table_trie (
    input wire lku_clk, lku_rst, //rst not implement
    
    // interface for query
    (*mark_Debug="true"*)input wire [31:0] query_in_addr,
    (*mark_Debug="true"*)input wire query_in_ready,
    (*mark_Debug="true"*)output reg [31:0] query_out_nexthop,
    (*mark_Debug="true"*)output reg [1:0] query_out_nextport,
    (*mark_Debug="true"*)output reg query_out_ready,

    // interface for insert/delete
    input wire [31:0] modify_in_addr,
    input wire modify_in_ready,
    input wire [31:0] modify_in_nexthop,
    input wire [1:0] modify_in_nextport,
    input wire [6:0] modify_in_len,
    output reg modify_finish,
    output reg full
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

parameter ENTRY_ADDR_WIDTH = 8;
parameter ENTRY_ADDR_MAX = (1<<ENTRY_ADDR_WIDTH);

//one trie node
parameter CHILD_BEGIN = 0;
parameter CHILD_END = (ENTRY_ADDR_WIDTH << 2)-1;
parameter NXT_HOP_BEGIN = CHILD_END + 1;
parameter NXT_HOP_END   = CHILD_END + 32;
parameter NXT_PORT_BEGIN = CHILD_END + 33;
parameter NXT_PORT_END = CHILD_END + 34;
parameter LEN_BEGIN = CHILD_END + 35;
parameter LEN_END = CHILD_END + 36;
parameter VALID_POS = CHILD_END + 37;

parameter ENTRY_WIDTH = VALID_POS + 1;
reg[ENTRY_ADDR_WIDTH-1: 0] write_addr, read_addr, new_read_addr;
reg[ENTRY_WIDTH-1: 0] entry, entry_to_write, entry_read;

wire[ENTRY_ADDR_WIDTH-1: 0] entry_child[3:0];
assign entry_child[0] = entry[ENTRY_ADDR_WIDTH-1: 0];
assign entry_child[1] = entry[ENTRY_ADDR_WIDTH*2-1: ENTRY_ADDR_WIDTH];
assign entry_child[2] = entry[ENTRY_ADDR_WIDTH*3-1: ENTRY_ADDR_WIDTH*2];
assign entry_child[3] = entry[ENTRY_ADDR_WIDTH*4-1: ENTRY_ADDR_WIDTH*3];
// assign entry_child[4] = entry[ENTRY_ADDR_WIDTH*5-1: ENTRY_ADDR_WIDTH*4];
// assign entry_child[5] = entry[ENTRY_ADDR_WIDTH*6-1: ENTRY_ADDR_WIDTH*5];
// assign entry_child[6] = entry[ENTRY_ADDR_WIDTH*7-1: ENTRY_ADDR_WIDTH*6];
// assign entry_child[7] = entry[ENTRY_ADDR_WIDTH*8-1: ENTRY_ADDR_WIDTH*7];
// assign entry_child[8] = entry[ENTRY_ADDR_WIDTH*9-1: ENTRY_ADDR_WIDTH*8];
// assign entry_child[9] = entry[ENTRY_ADDR_WIDTH*10-1: ENTRY_ADDR_WIDTH*9];
// assign entry_child[10] = entry[ENTRY_ADDR_WIDTH*11-1: ENTRY_ADDR_WIDTH*10];
// assign entry_child[11] = entry[ENTRY_ADDR_WIDTH*12-1: ENTRY_ADDR_WIDTH*11];
// assign entry_child[12] = entry[ENTRY_ADDR_WIDTH*13-1: ENTRY_ADDR_WIDTH*12];
// assign entry_child[13] = entry[ENTRY_ADDR_WIDTH*14-1: ENTRY_ADDR_WIDTH*13];
// assign entry_child[14] = entry[ENTRY_ADDR_WIDTH*15-1: ENTRY_ADDR_WIDTH*14];
// assign entry_child[15] = entry[ENTRY_ADDR_WIDTH*16-1: ENTRY_ADDR_WIDTH*15];

wire[ENTRY_ADDR_WIDTH-1: 0] entry_read_child[3:0];
assign entry_read_child[0] = entry_read[ENTRY_ADDR_WIDTH-1: 0];
assign entry_read_child[1] = entry_read[ENTRY_ADDR_WIDTH*2-1: ENTRY_ADDR_WIDTH];
assign entry_read_child[2] = entry_read[ENTRY_ADDR_WIDTH*3-1: ENTRY_ADDR_WIDTH*2];
assign entry_read_child[3] = entry_read[ENTRY_ADDR_WIDTH*4-1: ENTRY_ADDR_WIDTH*3];
// assign entry_read_child[4] = entry_read[ENTRY_ADDR_WIDTH*5-1: ENTRY_ADDR_WIDTH*4];
// assign entry_read_child[5] = entry_read[ENTRY_ADDR_WIDTH*6-1: ENTRY_ADDR_WIDTH*5];
// assign entry_read_child[6] = entry_read[ENTRY_ADDR_WIDTH*7-1: ENTRY_ADDR_WIDTH*6];
// assign entry_read_child[7] = entry_read[ENTRY_ADDR_WIDTH*8-1: ENTRY_ADDR_WIDTH*7];
// assign entry_read_child[8] = entry_read[ENTRY_ADDR_WIDTH*9-1: ENTRY_ADDR_WIDTH*8];
// assign entry_read_child[9] = entry_read[ENTRY_ADDR_WIDTH*10-1: ENTRY_ADDR_WIDTH*9];
// assign entry_read_child[10] = entry_read[ENTRY_ADDR_WIDTH*11-1: ENTRY_ADDR_WIDTH*10];
// assign entry_read_child[11] = entry_read[ENTRY_ADDR_WIDTH*12-1: ENTRY_ADDR_WIDTH*11];
// assign entry_read_child[12] = entry_read[ENTRY_ADDR_WIDTH*13-1: ENTRY_ADDR_WIDTH*12];
// assign entry_read_child[13] = entry_read[ENTRY_ADDR_WIDTH*14-1: ENTRY_ADDR_WIDTH*13];
// assign entry_read_child[14] = entry_read[ENTRY_ADDR_WIDTH*15-1: ENTRY_ADDR_WIDTH*14];
// assign entry_read_child[15] = entry_read[ENTRY_ADDR_WIDTH*16-1: ENTRY_ADDR_WIDTH*15];

wire[ENTRY_WIDTH-1: 0] bram_entry_read;
reg read_enable = 0, write_enable = 0, new_read_enable;
reg[2:0] state = STATE_PAUSE, next_state = STATE_PAUSE;
reg[31:0] lookup_addr;
reg[1:0] lookup_port;
reg[31:0] lookup_nexthop;
reg[6:0] len, dep;
reg[ENTRY_ADDR_WIDTH-1:0] cur, node_cnt;

reg[1:0] upd_child, upd_last;
wire[1:0] cur_child, cur_mask_child;

reg[1:0] upd_mask[1:0];
reg[1:0] upd_extend[1:0];

assign cur_child = lookup_addr >> dep & 3;
assign cur_mask_child = lookup_addr >> dep & upd_mask[(len-1)&1];

xpm_memory_sdpram #(
    .ADDR_WIDTH_A(ENTRY_ADDR_WIDTH),
    .ADDR_WIDTH_B(ENTRY_ADDR_WIDTH),
    .MEMORY_SIZE(ENTRY_WIDTH * ENTRY_ADDR_MAX),
    .READ_DATA_WIDTH_B(ENTRY_WIDTH),
    .READ_LATENCY_B(1),
    .WRITE_DATA_WIDTH_A(ENTRY_WIDTH),
    .USE_MEM_INIT(1)
) trie_sdpram (
    .addra(write_addr),
    .clka(lku_clk),
    .dina(entry_to_write),
    .ena(write_enable),
    .wea(25'b1111111111111111111111111),

    .addrb(new_read_addr),
    .enb(new_read_enable),
    .doutb(bram_entry_read)
);

initial begin
    node_cnt <= 1;
    upd_mask[0] <= 2;
    upd_mask[1] <= 3;
    // upd_mask[2] <= 14;
    // upd_mask[3] <= 15;
    upd_extend[0] <= 1;
    upd_extend[1] <= 0;
    // upd_extend[2] <= 1;
    // upd_extend[3] <= 0;
    full <= 0;
end

always @(posedge lku_clk) begin
    if (lku_rst == 1'b1) begin
        state  <= STATE_PAUSE;
        read_addr <= 0;
        read_enable <= 0;
        upd_mask[0] <= 2;
        upd_mask[1] <= 3;
        // upd_mask[2] <= 14;
        // upd_mask[3] <= 15;
        upd_extend[0] <= 1;
        upd_extend[1] <= 0;
        // upd_extend[2] <= 1;
        // upd_extend[3] <= 0;
    end else begin
        state <= next_state;
        read_addr <= new_read_addr;
        read_enable <= new_read_enable;
    end
    // if (read_enable)
    //     $display("read from %d: [%d %d]/[%d %d]/[%d %d] hop-%h port-%d len-%d vaild-%d", read_addr, bram_entry_read[9:0], bram_entry_read[19:10], entry_read[9:0], entry_read[19:10], entry_read_child[0], entry_read_child[1], bram_entry_read[NXT_HOP_END:NXT_HOP_BEGIN], bram_entry_read[NXT_PORT_END: NXT_PORT_BEGIN], bram_entry_read[LEN_END:LEN_BEGIN], bram_entry_read[VALID_POS]);
    // if (write_enable)
    //     $display("write to %d: [%d %d] hop-%h port-%d len-%d valid-%d", write_addr, entry_to_write[9:0], entry_to_write[19:10], entry_to_write[NXT_HOP_END:NXT_HOP_BEGIN], entry_to_write[NXT_PORT_END: NXT_PORT_BEGIN],  entry_to_write[LEN_END:LEN_BEGIN], entry_to_write[VALID_POS]);
    // $display("state: %d-%d", state, next_state);
end

// state machine
always @(posedge lku_clk) begin
    case (next_state)
        STATE_PAUSE: begin
                // $display("state: pause modify %d query %d full %d", modify_in_ready, query_in_ready, full);
                if (modify_in_ready && !full) begin
                    // $display("[lookup] modify begin %h->%h", modify_in_addr, modify_in_nexthop);
                    dep <= 30;
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
                end else if (query_in_ready) begin
                    // $display("[lookup] query begin %h", query_in_addr);
                    dep <= 30;
                    next_state <= STATE_QUE_READ;
                    lookup_addr <= query_in_addr;
                    query_out_nexthop <= 0;
                    query_out_nextport <= 0;
                    write_enable <= 0;
                end else begin
                    next_state <= STATE_PAUSE;
                    write_enable <= 0;
                end
            end
        STATE_INS_UPD_ROOT: begin
                // $display("state: insert-upd-root");
                entry_to_write <= {1'b1, 2'b00, lookup_port, lookup_nexthop, entry_read[CHILD_END:CHILD_BEGIN]};
                write_addr <= 1;
                write_enable <= 1;
                next_state <= STATE_WAIT_END;
            end
        STATE_INS_READ: begin
                // $display("state: insert-read len %d", len);
                if (len <= 2) begin
                    upd_child <= cur_mask_child;
                    upd_last <= cur_mask_child | upd_extend[len-1];
                    cur <= read_addr;
                    // $display("modify range %d %d", cur_mask_child, cur_mask_child | upd_extend[len-1]);
                    if (entry_read_child[cur_mask_child] == 0) begin
                        node_cnt <= node_cnt + 1;
                        entry <= entry_read | ((node_cnt+1) << (cur_mask_child * ENTRY_ADDR_WIDTH));
                        write_enable <= 0;
                    end else begin
                        write_enable <= 0;
                        entry <= entry_read;
                    end
                    next_state <= STATE_INS_SET;
                end else begin
                    upd_child <= cur_child;
                    entry <= entry_read;
                    len <= len-2;
                    dep <= dep-2;
                    // $display("check child: %d %d", cur_child, entry_read_child[cur_child]);
                    if (entry_read_child[cur_child] == 0) begin
                        entry_to_write <= entry_read | ((node_cnt+1) << (cur_child * ENTRY_ADDR_WIDTH));
                        write_addr <= read_addr;
                        write_enable <= 1;
                        node_cnt <= node_cnt + 1;
                    end else begin
                        write_enable <= 0;
                    end
                    next_state <= STATE_INS_READ;
                end
            end
        STATE_INS_SET: begin
                // $display("state ins-set [valid %d len %d] len-cur %d", entry_read[VALID_POS], entry_read[LEN_END: LEN_BEGIN], len);
                // $display("upd-child %d node_cnt %d me %d next %d", upd_child, node_cnt, entry_child[upd_child], entry_child[upd_child+1]);
                if (entry_read[VALID_POS] == 0 || entry_read[LEN_END:LEN_BEGIN] <= len-1)
                    entry_to_write <= {1'b1, (len[1:0]-2'b01), lookup_port, lookup_nexthop, entry_read[CHILD_END: CHILD_BEGIN]};
                else
                    entry_to_write <= entry_read;
                write_enable <= 1;
                write_addr <= read_addr;
                if (upd_child != upd_last) begin
                    if (entry_child[upd_child+1] == 0) begin
                        entry[(upd_child+2)*ENTRY_ADDR_WIDTH-1-: ENTRY_ADDR_WIDTH] <= node_cnt + 1;
                        node_cnt <= node_cnt + 1;
                    end
                    upd_child <= upd_child + 1;
                    next_state <= STATE_INS_SET;
                end else begin
                    next_state <= STATE_INS_UPD_SELF;
                end
            end
        STATE_INS_UPD_SELF: begin
                // $display("state: insert upd-self");
                entry_to_write <= entry;
                write_addr <= cur;
                write_enable <= 1;
                next_state <= STATE_WAIT_END;
            end
        STATE_WAIT_END: begin
                // $display("state: wait for end");
                next_state <= STATE_PAUSE;
                write_enable <= 0;
            end
        STATE_QUE_READ: begin
            // $display("state query-read addr %d valid %d ans %h cur %d nxt %d", read_addr, entry_read[VALID_POS], entry_read[NXT_HOP_END: NXT_HOP_BEGIN], cur_child, entry_read_child[cur_child]);
            if (entry_read[VALID_POS] == 1) begin
                query_out_nexthop <= entry_read[NXT_HOP_END: NXT_HOP_BEGIN];
                query_out_nextport <= entry_read[NXT_PORT_END: NXT_PORT_BEGIN];
            end
            write_enable <= 0;
            if (entry_read_child[cur_child] > 0) begin
                next_state <= STATE_QUE_READ;
                dep <= dep-2;
            end else begin
                next_state <= STATE_PAUSE;
            end
        end
    endcase
end

always @(*) begin
    case (next_state)
        STATE_PAUSE: begin
                // $display("state: pause");
                if (modify_in_ready && !full) begin
                    new_read_addr <= 1;
                    new_read_enable <= 1;
                end else if (query_in_ready) begin
                    new_read_addr <= 1;
                    new_read_enable <= 1;
                end else begin
                    new_read_enable <= 0;
                end
            end
        STATE_INS_UPD_ROOT: begin
                // $display("state: insert-upd-root");
                new_read_enable <= 0;
            end
        STATE_INS_READ: begin
                // $display("state: insert-read len %d", len);
                if (len <= 2) begin
                    if (entry_read_child[cur_mask_child] == 0) begin
                        new_read_addr <= node_cnt + 1;
                        new_read_enable <= 0;
                    end else begin
                        new_read_addr <= entry_read_child[cur_mask_child];
                        new_read_enable <= 1;
                    end
                end else begin
                    if (entry_read_child[cur_child] == 0) begin
                        new_read_enable <= 0;
                        new_read_addr <= node_cnt + 1;
                    end else begin
                        new_read_addr <= entry_read_child[cur_child];
                        new_read_enable <= 1;
                    end
                end
            end
        STATE_INS_SET: begin
                if (upd_child != upd_last) begin
                    if (entry_child[upd_child+1] == 0) begin
                        new_read_addr <= node_cnt + 1;
                        new_read_enable <= 0;
                    end else if (entry_child[upd_child+1] != node_cnt + 1)begin
                        new_read_addr <= entry_child[upd_child+1];
                        new_read_enable <= 1;
                    end
                end else begin
                    new_read_enable <= 0;
                end
            end
        STATE_INS_UPD_SELF: begin
                new_read_enable <= 0;
            end
        STATE_WAIT_END: begin
                new_read_enable <= 0;
            end
        STATE_QUE_READ: begin
            if (entry_read_child[cur_child] > 0) begin
                new_read_addr <= entry_read_child[cur_child];
                new_read_enable <= 1;
            end else begin
                new_read_enable <= 0;
            end
        end
    endcase
end


// output
always @(posedge lku_clk) begin
    if (state == STATE_WAIT_END && next_state == STATE_PAUSE) begin
        modify_finish <= 1;
        // $display("[lookup] modify end, node cnt %d", node_cnt);
    end else begin
        modify_finish <= 0;
    end
    if (state == STATE_QUE_READ && next_state == STATE_PAUSE) begin
        query_out_ready <= 1;
        // $display("[lookup] query end %h", query_out_nexthop);
    end else
        query_out_ready <= 0;
end

// simulate c++

always @(bram_entry_read or read_enable) begin
    if (read_enable == 1)
        entry_read <= bram_entry_read;
    else
        entry_read <= 0;
end

always @(node_cnt) begin
    if (node_cnt + 20 > ENTRY_ADDR_MAX) begin
        full <= 1;
    end
end

endmodule