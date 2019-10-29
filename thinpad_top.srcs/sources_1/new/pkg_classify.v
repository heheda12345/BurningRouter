/*
Package Classification
Use RAM as a random access fifo
After scanning dest, src and type, RAM is completely controled by sub-module
S1. dest(6) -> A. S2(dest==me || dest=ff*6) B. THROW(otherwise)
S2. src(6)
S3. 0x8000
S4. VLAN Tag(2)
S5. swap dest, src. type(2) -> A. ARP(0x0806) B. IPv4(0x0800)
*/

module pkg_classify(
(*MARK_DEBUG="TRUE"*) input            axi_tclk,
    input            axi_tresetn,

    output     [15:0] debug,
    
    // data from the RX FIFO
    input      [7:0] rx_axis_fifo_tdata,
    input            rx_axis_fifo_tvalid,   // wait
    input            rx_axis_fifo_tlast,
    output           rx_axis_fifo_tready,   // ready
    // data TO the tx fifo
    output     [7:0] tx_axis_fifo_tdata,
    output           tx_axis_fifo_tvalid,
    output           tx_axis_fifo_tlast,
    input            tx_axis_fifo_tready
);

//parameter MAC_BROADCAST = 48'hffffffffffff;

localparam        IDLE           = 3'b000,
                  WAIT           = 3'b001,
                  READ_DEST      = 3'b010,
                  READ_SRC       = 3'b011,
                  READ_TYPE      = 3'b100,
                  READ_VLAN_PORT = 3'b101,
                  READ_VLAN_TYPE = 3'b110,
                  DISCARD        = 3'b111;

localparam  IPV4 = 2'b01,
            ARP = 2'b10;

wire axi_treset;
assign axi_treset = !axi_tresetn;

(*MARK_DEBUG="TRUE"*) reg [2:0] read_state = IDLE, next_read_state = IDLE;
reg [2:0] dst_counter, src_counter;
reg type_counter, vlan_port_counter, vlan_type_counter;

reg [7:0] protocol_type_1 = 0;
reg [1:0] dst_mac_addr_match = 0;
wire [47:0] MY_MAC_ADDR;
wire [31:0] MY_IPV4_ADDR;

(*MARK_DEBUG="TRUE"*) wire sub_procedure_ready; // '1' when last type char is available
wire ipv4_ready, arp_ready;
wire ipv4_complete, arp_complete;
wire sub_procedure_complete;
reg [1:0] sub_procedure_type = 2'b00;

(*MARK_DEBUG="TRUE"*)wire [11:0] mem_read_addr, mem_write_addr;
(*MARK_DEBUG="TRUE"*)wire [7:0] mem_read_data, mem_write_data;
(*MARK_DEBUG="TRUE"*)wire mem_read_ena, mem_write_ena;
// support read & write by this module
reg top_mem_write_ena = 0;
reg [11:0] top_mem_write_addr = 0;
reg [7:0] top_mem_write_data = 0;
// read & write by its sub module
wire ipv4_buf_start, ipv4_mem_write_ena, arp_buf_start, arp_mem_write_ena, ipv4_buf_last, arp_buf_last;
wire [11:0] ipv4_buf_end_addr, ipv4_mem_write_addr, arp_buf_end_addr, arp_mem_write_addr;
wire [7:0] ipv4_mem_write_data, arp_mem_write_data;

wire ipv4_rx_axis_fifo_tready, arp_rx_axis_fifo_tready, top_rx_axis_fifo_tready;

wire arp_table_update, arp_table_insert, arp_table_exist, arp_table_query_exist;
wire [7:0] arp_table_input_vlan_port, arp_table_query_vlan_port;
wire [47:0] arp_table_input_mac_addr, arp_table_query_output_mac_addr;
wire [31:0] arp_table_input_ipv4_addr, arp_table_query_ipv4_addr;

wire [31:0] lookup_query_in_addr, lookup_query_out_nexthop;
reg  [31:0] lookup_modify_in_addr, lookup_modify_in_nexthop;
wire lookup_query_in_ready, lookup_query_out_ready;
reg  lookup_modify_in_ready; 
wire lookup_modify_finish;
wire lookup_full;
wire [1:0] lookup_query_out_nextport;
reg  [1:0] lookup_modify_in_nextport;
reg  [6:0] lookup_modify_in_len;

// VLAN port
reg [7:0] vlan_port = 0;

//assign MY_MAC_ADDR = 48'h8e570afa9939;
assign MY_MAC_ADDR = 48'h020203030000;
assign MY_IPV4_ADDR = 32'h0A000001;

assign debug[2:0] = read_state;
assign debug[5:4] = sub_procedure_type;

// manual forward table
initial begin
    lookup_modify_in_addr <= 32'h0a00000b;
    lookup_modify_in_nexthop <= 32'h0a00000b;
    lookup_modify_in_nextport <= 2'h0;
    lookup_modify_in_len <= 32;
    lookup_modify_in_ready <= 1;
    #10
    lookup_modify_in_ready <= 0;
    #10
    lookup_modify_in_addr <= 32'h0a00010c;
    lookup_modify_in_nexthop <= 32'h0a00010c;
    lookup_modify_in_nextport <= 2'h1;
    lookup_modify_in_len <= 32;
    lookup_modify_in_ready <= 1;
    #10
    lookup_modify_in_ready <= 0;
    #10
    lookup_modify_in_addr <= 32'h0a00020d;
    lookup_modify_in_nexthop <= 32'h0a00020d;
    lookup_modify_in_nextport <= 2'h2;
    lookup_modify_in_len <= 32;
    lookup_modify_in_ready <= 1;
    #10
    lookup_modify_in_ready <= 0;
    #10
    lookup_modify_in_addr <= 32'h0a00030e;
    lookup_modify_in_nexthop <= 32'h0a00030e;
    lookup_modify_in_nextport <= 2'h3;
    lookup_modify_in_len <= 32;
    lookup_modify_in_ready <= 1;
    #10
    lookup_modify_in_ready <= 0;
end

always @ (posedge axi_tclk)
begin
    read_state <= next_read_state;
end

assign top_rx_axis_fifo_tready = rx_axis_fifo_tvalid; // read as soon as available

always @ (*)
begin
    if (axi_treset) begin
        next_read_state <= IDLE;
    end
    else if (rx_axis_fifo_tvalid) begin
        case (read_state)
            IDLE: begin
                // new package?
                next_read_state <= rx_axis_fifo_tvalid ? READ_DEST : IDLE;
            end
            WAIT: begin
                next_read_state <= sub_procedure_complete ? IDLE : WAIT;
            end
            READ_DEST: begin
                if (dst_counter <= 5) begin
                    next_read_state <= READ_DEST;
                end
                else if (dst_mac_addr_match != 2'b00) begin
                    next_read_state <= READ_SRC;
                end
                else begin
                    next_read_state <= DISCARD;
                end
            end
            READ_SRC:
                next_read_state <= src_counter <= 5 ? READ_SRC : READ_TYPE;
            READ_TYPE:
                next_read_state <= type_counter == 1 ? READ_TYPE : READ_VLAN_PORT;
            READ_VLAN_PORT:
                next_read_state <= vlan_port_counter == 1 ? READ_VLAN_PORT : READ_VLAN_TYPE;
            READ_VLAN_TYPE:
                next_read_state <= vlan_type_counter == 1 ? READ_VLAN_TYPE : (sub_procedure_type > 0 ? WAIT : DISCARD);
            DISCARD:
                next_read_state <= rx_axis_fifo_tlast ? IDLE : DISCARD;
            default:
                next_read_state <= read_state;
        endcase 
    end
    else if (read_state == WAIT) begin 
        next_read_state <= sub_procedure_complete ? IDLE : WAIT;
    end
    else next_read_state <= IDLE;
end

always @ (posedge axi_tclk) begin
    dst_counter <= rx_axis_fifo_tvalid && next_read_state == READ_DEST ? dst_counter + 1 : 0;
    src_counter <= rx_axis_fifo_tvalid && next_read_state == READ_SRC ? src_counter + 1 : 0;
    type_counter <= rx_axis_fifo_tvalid && next_read_state == READ_TYPE ? ~type_counter : 0;
    vlan_type_counter <= rx_axis_fifo_tvalid && next_read_state == READ_VLAN_TYPE ? ~vlan_type_counter : 0;
    vlan_port_counter <= rx_axis_fifo_tvalid && next_read_state == READ_VLAN_PORT ? ~vlan_port_counter : 0;
end

always @ (posedge axi_tclk) begin
    if (next_read_state != READ_DEST) begin
        dst_mac_addr_match <= 2'b11;
    end
    else begin 
        if (rx_axis_fifo_tvalid) begin
            dst_mac_addr_match[0] <= dst_mac_addr_match[0] & (rx_axis_fifo_tdata == 8'hff);
            case (dst_counter)
                0: dst_mac_addr_match[1] <= rx_axis_fifo_tdata == MY_MAC_ADDR[47:40];
                1: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDR[39:32]);
                2: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDR[31:24]);
                3: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDR[23:16]);
                4: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDR[15: 8]);
                5: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDR[ 7: 0]);
                default: dst_mac_addr_match[1] <= 0;
            endcase
        end
    end
end

always @ (posedge axi_tclk) begin
    if (rx_axis_fifo_tvalid && next_read_state == READ_VLAN_TYPE && vlan_type_counter == 0) begin
        protocol_type_1 <= rx_axis_fifo_tdata;
    end
end

always @ (posedge axi_tclk) begin
    if (rx_axis_fifo_tvalid && next_read_state == READ_VLAN_PORT && vlan_port_counter == 1) begin
        vlan_port <= rx_axis_fifo_tdata;
    end
end

// sub procedure

assign sub_procedure_ready = next_read_state == READ_VLAN_TYPE && vlan_type_counter == 1;
assign ipv4_ready = sub_procedure_ready && protocol_type_1 == 8'h08 && rx_axis_fifo_tvalid && rx_axis_fifo_tdata == 8'h00;
assign arp_ready = sub_procedure_ready && protocol_type_1 == 8'h08 && rx_axis_fifo_tvalid && rx_axis_fifo_tdata == 8'h06;
assign sub_procedure_complete = arp_complete || ipv4_complete;

always @ (posedge axi_tclk) begin
    if (next_read_state == READ_VLAN_TYPE) begin
        sub_procedure_type <= arp_ready ? ARP : (ipv4_ready ? IPV4 : 0);
    end
    else if (next_read_state == WAIT || read_state == WAIT)
        sub_procedure_type <= sub_procedure_type;
    else
        sub_procedure_type <= 0;
end

arp_table arp_table_inst (
    .clk(axi_tclk), 
    .syn_rst(axi_treset), 
    .update(arp_table_update), 
    .insert(arp_table_insert),
    .exist(arp_table_exist),
    .input_vlan_port(arp_table_input_vlan_port),
    .input_mac_addr(arp_table_input_mac_addr),
    .input_ipv4_addr(arp_table_input_ipv4_addr), 
    .query_vlan_port(arp_table_query_vlan_port), 
    .query_ipv4_addr(arp_table_query_ipv4_addr), 
    .output_mac_addr(arp_table_query_output_mac_addr),
    .query_exist(arp_table_query_exist)
);

lookup_table_trie lookup_table_trie_inst (
    .lku_clk(axi_tclk), 
    .lku_rst(axi_treset), 

    .query_in_addr(lookup_query_in_addr), 
    .query_in_ready(lookup_query_in_ready), 
    .query_out_nexthop(lookup_query_out_nexthop),
    .query_out_nextport(lookup_query_out_nextport), 
    .query_out_ready(lookup_query_out_ready), 

    .modify_in_addr(lookup_modify_in_addr),
    .modify_in_ready(lookup_modify_in_ready),
    .modify_in_nexthop(lookup_modify_in_nexthop),
    .modify_in_nextport(lookup_modify_in_nextport),
    .modify_in_len(lookup_modify_in_len),
    .modify_finish(lookup_modify_finish),
    .full(lookup_full)
);

wire [11:0] buf_end_addr, buf_start_addr;
wire buf_ready, buf_finish, buf_start, buf_last;

buffer_pushing buffer_pushing_i (
    .clk(axi_tclk), 
    .end_addr(buf_end_addr), // i
    .start_addr(buf_start_addr), // o
    .ready(buf_ready), // o
    .start(buf_start), // i
    .last(buf_last), // i
    .finish(buf_finish), // o

    .tx_axis_fifo_tdata(tx_axis_fifo_tdata),
    .tx_axis_fifo_tlast(tx_axis_fifo_tlast),
    .tx_axis_fifo_tvalid(tx_axis_fifo_tvalid),
    .tx_axis_fifo_tready(tx_axis_fifo_tready),

    .mem_read_ena(mem_read_ena),
    .mem_read_data(mem_read_data),
    .mem_read_addr(mem_read_addr)
);

arp_module arp_module_inst(
    .clk(axi_tclk),
    .rst(axi_treset), 
    .start(arp_ready),
    .complete(arp_complete),

    .rx_axis_fifo_tdata(rx_axis_fifo_tdata),
    .rx_axis_fifo_tvalid(rx_axis_fifo_tvalid),
    .rx_axis_fifo_tlast(rx_axis_fifo_tlast),
    .rx_axis_fifo_tready(arp_rx_axis_fifo_tready),
    // RAM-write
    .mem_write_ena(arp_mem_write_ena),
    .mem_write_data(arp_mem_write_data),
    .mem_write_addr(arp_mem_write_addr),
    .buf_ready(buf_ready), // i
    .buf_start(arp_buf_start), // o
    .buf_last(arp_buf_last), // o
    .buf_start_addr(buf_start_addr), // i
    .buf_end_addr(arp_buf_end_addr), // o
    // ARP Table
    .arp_table_update(arp_table_update),
    .arp_table_insert(arp_table_insert),
    .arp_table_exist(arp_table_exist), 
    .arp_table_input_vlan_port(arp_table_input_vlan_port), 
    .arp_table_input_mac_addr(arp_table_input_mac_addr),
    .arp_table_input_ipv4_addr(arp_table_input_ipv4_addr), 

    .MY_MAC_ADDRESS(MY_MAC_ADDR),
    .MY_IPV4_ADDRESS(MY_IPV4_ADDR),
    .vlan_port(vlan_port),

    .debug(debug[15:8])
);

ipv4_module ipv4_module_inst(
    .clk(axi_tclk),
    .rst(axi_treset), 
    .start(ipv4_ready),
    .complete(ipv4_complete),

    .rx_axis_fifo_tdata(rx_axis_fifo_tdata),
    .rx_axis_fifo_tvalid(rx_axis_fifo_tvalid),
    .rx_axis_fifo_tlast(rx_axis_fifo_tlast),
    .rx_axis_fifo_tready(ipv4_rx_axis_fifo_tready),
    // RAM-write
    .mem_write_ena(ipv4_mem_write_ena),
    .mem_write_data(ipv4_mem_write_data),
    .mem_write_addr(ipv4_mem_write_addr),
    .buf_ready(buf_ready), // i
    .buf_start(ipv4_buf_start), // o
    .buf_last(ipv4_buf_last), // o
    .buf_start_addr(buf_start_addr), // i
    .buf_end_addr(ipv4_buf_end_addr), // o
    // forward table lookup
    .lookup_query_in_addr(lookup_query_in_addr), 
    .lookup_query_in_ready(lookup_query_in_ready), 
    .lookup_query_out_nexthop(lookup_query_out_nexthop),
    .lookup_query_out_nextport(lookup_query_out_nextport), 
    .lookup_query_out_ready(lookup_query_out_ready),
    .arp_table_query_vlan_port(arp_table_query_vlan_port), 
    .arp_table_query_ipv4_addr(arp_table_query_ipv4_addr), 
    .arp_table_output_mac_addr(arp_table_query_output_mac_addr), 
    .arp_table_query_exist(arp_table_query_exist),

    .MY_MAC_ADDRESS(MY_MAC_ADDR),
    .MY_IPV4_ADDRESS(MY_IPV4_ADDR)
);

// store MAC address into RAM

always @ (posedge axi_tclk) begin
    top_mem_write_ena <= rx_axis_fifo_tvalid;
    top_mem_write_data <= rx_axis_fifo_tdata;
    case (next_read_state)
        READ_DEST: 
            top_mem_write_addr <= buf_start_addr + 6 + dst_counter;
        READ_SRC:
            top_mem_write_addr <= buf_start_addr + src_counter;
        READ_TYPE:
            top_mem_write_addr <= buf_start_addr + 12 + type_counter;
        READ_VLAN_PORT:
            top_mem_write_addr <= buf_start_addr + 14 + vlan_port_counter;
        READ_VLAN_TYPE:
            top_mem_write_addr <= buf_start_addr + 16 + vlan_type_counter;
        default: 
            top_mem_write_addr <= buf_start_addr;
    endcase
end

// RAM

blk_mem_gen_0 blk_mem_inst (
    .clka(axi_tclk),
    .ena(mem_write_ena),
    .wea(mem_write_ena),
    .addra(mem_write_addr),
    .dina(mem_write_data),
    .clkb(axi_tclk),
    .enb(mem_read_ena),
    .addrb(mem_read_addr),
    .doutb(mem_read_data)
);

assign mem_write_addr = read_state == WAIT && sub_procedure_type == ARP ? arp_mem_write_addr : (
    read_state == WAIT && sub_procedure_type == IPV4 ? ipv4_mem_write_addr : top_mem_write_addr
);
assign mem_write_ena = read_state == WAIT && sub_procedure_type == ARP ? arp_mem_write_ena : (
    read_state == WAIT && sub_procedure_type == IPV4 ? ipv4_mem_write_ena : top_mem_write_ena
);
assign mem_write_data = read_state == WAIT && sub_procedure_type == ARP ? arp_mem_write_data : (
    read_state == WAIT && sub_procedure_type == IPV4 ? ipv4_mem_write_data : top_mem_write_data
);

assign buf_start = read_state == WAIT && sub_procedure_type == ARP ? arp_buf_start : (
    read_state == WAIT && sub_procedure_type == IPV4 ? ipv4_buf_start : 0
);
assign buf_last = read_state == WAIT && sub_procedure_type == ARP ? arp_buf_last : (
    read_state == WAIT && sub_procedure_type == IPV4 ? ipv4_buf_last : 0
);
assign buf_end_addr = read_state == WAIT && sub_procedure_type == ARP ? arp_buf_end_addr : (
    read_state == WAIT && sub_procedure_type == IPV4 ? ipv4_buf_end_addr : 0
);

assign rx_axis_fifo_tready = sub_procedure_type == ARP ? arp_rx_axis_fifo_tready : (
    sub_procedure_type == IPV4 ? ipv4_rx_axis_fifo_tready : top_rx_axis_fifo_tready
);
/*
assign tx_axis_fifo_tlast = sub_procedure_type == ARP ? arp_tx_axis_fifo_tlast : (
    sub_procedure_type == IPV4 ? ipv4_tx_axis_fifo_tlast : top_tx_axis_fifo_tlast
);
assign tx_axis_fifo_tdata = sub_procedure_type == ARP ? arp_tx_axis_fifo_tdata : (
    sub_procedure_type == IPV4 ? ipv4_tx_axis_fifo_tdata : top_tx_axis_fifo_tdata
);
assign tx_axis_fifo_tvalid = sub_procedure_type == ARP ? arp_tx_axis_fifo_tvalid : (
    sub_procedure_type == IPV4 ? ipv4_tx_axis_fifo_tvalid : top_tx_axis_fifo_tvalid
);

assign top_tx_axis_fifo_tdata = 0;
assign top_tx_axis_fifo_tvalid = 0;
assign top_tx_axis_fifo_tlast = 0;*/

endmodule // pkg_classify