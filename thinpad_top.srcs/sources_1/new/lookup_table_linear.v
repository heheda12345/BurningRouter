module lookup_table_linear (
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
    output wire full,
    output reg error
);

parameter NXT_HOP_BEGIN = 0;
parameter NXT_HOP_END   = 31;
parameter NXT_PORT_BEGIN = 32;
parameter NXT_PORT_END = 33;
parameter ENTRY_WIDTH = NXT_PORT_END + 1;
parameter ADDR_WIDTH = 8;
parameter ENTRY_ADDR_MAX = 1 << ADDR_WIDTH;
parameter CHECK_BEGIN = 16;
parameter CHECK_END = 31;
parameter ADDR_BEGIN = 8;
parameter ADDR_END = 15;
parameter prefix = 16'hc0a8;
parameter mask_len = 7'b0011000;


reg[ENTRY_WIDTH - 1: 0] entry_to_write;
reg[ADDR_WIDTH - 1: 0] entry_write_addr;
reg entry_write_enable;
reg[ENTRY_WIDTH - 1: 0] clear_to_write;
reg[ADDR_WIDTH - 1: 0] clear_write_addr;
reg clear_write_enable;
wire[ENTRY_WIDTH - 1: 0] entry_write;
wire [ADDR_WIDTH - 1: 0] write_addr;
wire write_enable;
assign entry_write = (clear_write_enable == 1'b1)? clear_to_write : entry_to_write;
assign write_addr = clear_write_enable == 1'b1 ? clear_write_addr: entry_write_addr;
assign write_enable = clear_write_enable | entry_write_enable;

wire[ENTRY_WIDTH - 1: 0] entry_read;
reg[ADDR_WIDTH - 1: 0] read_addr;
reg read_enable;
reg[ADDR_WIDTH - 1: 0] to_clear;

xpm_memory_sdpram #(
    .ADDR_WIDTH_A(ADDR_WIDTH),
    .ADDR_WIDTH_B(ADDR_WIDTH),
    .MEMORY_SIZE(ENTRY_WIDTH * ENTRY_ADDR_MAX),
    .READ_DATA_WIDTH_B(ENTRY_WIDTH),
    .READ_LATENCY_B(1),
    .WRITE_DATA_WIDTH_A(ENTRY_WIDTH),
    .USE_MEM_INIT(1)
) trie_sdpram (
    .addra(write_addr),
    .clka(lku_clk),
    .dina(entry_write),
    .ena(write_enable),
    .wea(25'b1111111111111111111111111),

    .addrb(read_addr),
    .enb(read_enable),
    .doutb(entry_read)
);

reg[2:0] state;
parameter STATE_PAUSE = 3'b000;
parameter STATE_MODIFY_END = 3'b001;
parameter STATE_QUERY_WAIT = 3'b010;
parameter STATE_QUERY_END = 3'b011;
parameter STATE_ERROR = 3'b100;
assign full = 0;

initial begin
    to_clear <= 0;
    state <= STATE_PAUSE;
    clear_to_write <= 0;
end

always @(posedge lku_clk) begin
    query_out_nexthop <= 0;
    query_out_nextport <= 0;
    query_out_ready <= 0;
    modify_finish <= 0;
    error <= 0;
    entry_write_addr <= 0;
    entry_to_write <= 0;
    entry_write_enable <= 0;
    read_addr <= 0;
    read_enable <= 0;
    to_clear <= to_clear;
    if (lku_rst == 1'b1) begin
        state  <= STATE_PAUSE;
    end else begin
        case (state)
            STATE_PAUSE: begin
                if (modify_in_ready) begin
                    if (modify_in_addr[CHECK_END: CHECK_BEGIN] != prefix || modify_in_len != mask_len) begin
                        state <= STATE_ERROR;
                    end else begin
                        entry_write_addr <= modify_in_addr[ADDR_END: ADDR_BEGIN];
                        entry_to_write <= {modify_in_nextport, modify_in_nexthop};
                        entry_write_enable <= 1;
                        state <= STATE_MODIFY_END;
                    end
                end else if (query_in_ready) begin
                    if (query_in_addr[CHECK_END: CHECK_BEGIN] != prefix) begin
                        state <= STATE_ERROR;
                    end else begin
                        read_addr <= query_in_addr[ADDR_END: ADDR_BEGIN];
                        read_enable <= 1;
                        state <= STATE_QUERY_WAIT;
                    end
                end else begin
                    state <= STATE_PAUSE;
                end
            end
            STATE_MODIFY_END: begin
                modify_finish <= 1;
                state <= STATE_PAUSE;
            end
            STATE_QUERY_WAIT: begin
                state <= STATE_QUERY_END;
            end
            STATE_QUERY_END: begin
                query_out_ready <= 1;
                query_out_nexthop <= entry_read[NXT_HOP_END: NXT_HOP_BEGIN];
                query_out_nextport <= entry_read[NXT_PORT_END: NXT_PORT_BEGIN];
                state <= STATE_PAUSE;
            end
            STATE_ERROR: begin
                state <= STATE_ERROR;
                error <= 1;
            end
        endcase
    end
end

always @(posedge lku_clk) begin
    clear_write_addr <= 0;
    clear_write_enable <= 0;
    if (lku_rst == 1'b1) begin
        if (to_clear != 0) begin
            clear_write_addr <= to_clear;
            clear_write_enable <= 1;
            to_clear <= to_clear - 1;
        end else if (clear_write_addr != 0) begin
            clear_write_addr <= 0;
            clear_write_enable <= 1;
            to_clear <= 0;
        end
    end else begin
         to_clear <= ENTRY_ADDR_MAX - 1;
    end
end

endmodule