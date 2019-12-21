module router_core(
    // MAC-side AxiStream interface
    input            eth_rx_mac_aclk,
    input            eth_rx_mac_resetn,
    input [7:0]      eth_rx_axis_mac_tdata,
    input            eth_rx_axis_mac_tvalid,
    input            eth_rx_axis_mac_tlast,
    input            eth_rx_axis_mac_tuser,

    input            eth_tx_mac_aclk,
    input            eth_tx_mac_resetn,
    output [7:0]     eth_tx_axis_mac_tdata,
    output           eth_tx_axis_mac_tvalid,
    output           eth_tx_axis_mac_tlast,
    input            eth_tx_axis_mac_tready,
    output           eth_tx_axis_mac_tuser,

    // CPU-side AxiStream interface (use eth_rx_mac clock)
    input [7:0]      cpu_rx_axis_tdata,
    input            cpu_rx_axis_tvalid,
    input            cpu_rx_axis_tlast,
    output           cpu_rx_axis_tready,

    output [7:0]     cpu_tx_axis_tdata,
    output           cpu_tx_axis_tvalid,
    output           cpu_tx_axis_tlast,
    input            cpu_tx_axis_tready,

    input wire [31:0] ip_modify_address,
    input wire [2:0]  ip_modify_interface,
    
    input  [31:0] lookup_modify_in_addr,
    input  [31:0] lookup_modify_in_nexthop,
    input         lookup_modify_in_ready,
    input  [1:0]  lookup_modify_in_nextport,
    input  [6:0]  lookup_modify_in_len,
    output  wire  lookup_modify_finish
);


wire [47:0] MY_MAC_ADDR;
reg [32*4-1:0] MY_IPV4_ADDR = {32'h0a000101, 32'h0a000001, 32'h0a000201, 32'h0a000301};
assign MY_MAC_ADDR = 48'h020203030000;
reg [31:0] MY_IPV4_ADDR_PORT;

wire eth_rx_axis_fifo_tvalid, rx_axis_fifo_tvalid;
wire [7:0] eth_rx_axis_fifo_tdata, rx_axis_fifo_tdata;
wire eth_rx_axis_fifo_tlast, rx_axis_fifo_tlast;
wire eth_rx_axis_fifo_tready, rx_axis_fifo_tready;

wire eth_tx_axis_fifo_tvalid;
wire [7:0] eth_tx_axis_fifo_tdata;
wire eth_tx_axis_fifo_tlast;
wire eth_tx_axis_fifo_tready;
wire from_cpu, to_cpu;

always @(posedge eth_rx_mac_aclk or negedge eth_rx_mac_resetn) begin
    if (!eth_rx_mac_resetn) begin
        MY_IPV4_ADDR <= {32'h0a000101, 32'h0a000001, 32'h0a000201, 32'h0a000301};
    end else if (ip_modify_interface == 3'h1) 
        MY_IPV4_ADDR[127: 96] <= ip_modify_address;
    else if (ip_modify_interface == 3'h2) 
        MY_IPV4_ADDR[95: 64] <= ip_modify_address;
    else if (ip_modify_interface == 3'h3) 
        MY_IPV4_ADDR[63: 32] <= ip_modify_address;
    else if (ip_modify_interface == 3'h4) 
        MY_IPV4_ADDR[31: 0] <= ip_modify_address;
end

eth_mac_wrapper eth_mac_wraper_i(
    .rx_mac_aclk(eth_rx_mac_aclk),
    .rx_mac_resetn(eth_rx_mac_resetn),
    .rx_axis_mac_tdata(eth_rx_axis_mac_tdata),
    .rx_axis_mac_tvalid(eth_rx_axis_mac_tvalid),
    .rx_axis_mac_tlast(eth_rx_axis_mac_tlast),
    .rx_axis_mac_tuser(eth_rx_axis_mac_tuser),

    .tx_mac_aclk(eth_tx_mac_aclk),
    .tx_mac_resetn(eth_tx_mac_resetn),
    .tx_axis_mac_tdata(eth_tx_axis_mac_tdata),
    .tx_axis_mac_tvalid(eth_tx_axis_mac_tvalid),
    .tx_axis_mac_tlast(eth_tx_axis_mac_tlast),
    .tx_axis_mac_tready(eth_tx_axis_mac_tready),
    .tx_axis_mac_tuser(eth_tx_axis_mac_tuser), 

    .rx_axis_fifo_tvalid(eth_rx_axis_fifo_tvalid),
    .rx_axis_fifo_tdata(eth_rx_axis_fifo_tdata),
    .rx_axis_fifo_tlast(eth_rx_axis_fifo_tlast),
    .rx_axis_fifo_tready(eth_rx_axis_fifo_tready),

    .tx_axis_fifo_tvalid(eth_tx_axis_fifo_tvalid),
    .tx_axis_fifo_tdata(eth_tx_axis_fifo_tdata),
    .tx_axis_fifo_tlast(eth_tx_axis_fifo_tlast),
    .tx_axis_fifo_tready(eth_tx_axis_fifo_tready)
);

wire is_ipv4, is_arp, ipv4_ready, arp_ready, ipv4_complete, arp_complete;
wire [7:0] vlan_port;

wire [11:0] mem_read_addr, mem_write_addr;
wire [7:0] mem_read_data, mem_write_data;
wire mem_read_ena, mem_write_ena;
// support read & write by this module
wire top_mem_write_ena;
wire [11:0] top_mem_write_addr;
wire [7:0] top_mem_write_data;
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
wire lookup_query_in_ready, lookup_query_out_ready;
wire lookup_modify_finish;
wire lookup_full;
wire [1:0] lookup_query_out_nextport;

wire [11:0] buf_end_addr, buf_start_addr;
wire buf_ready, buf_finish, buf_start, buf_last;
wire resetn = eth_rx_mac_resetn | eth_tx_mac_resetn ;
wire axi_treset = !resetn;
wire axi_tclk = eth_rx_mac_aclk;

rx_fifo_switch rx_fifo_switch_inst (
    .clk(axi_tclk),
    .rst(axi_treset),
    
    .eth_rx_axis_tdata(eth_rx_axis_fifo_tdata),
    .eth_rx_axis_tvalid(eth_rx_axis_fifo_tvalid), 
    .eth_rx_axis_tlast(eth_rx_axis_fifo_tlast), 
    .eth_rx_axis_tready(eth_rx_axis_fifo_tready), 

    .cpu_rx_axis_tdata(cpu_rx_axis_tdata),
    .cpu_rx_axis_tvalid(cpu_rx_axis_tvalid), 
    .cpu_rx_axis_tlast(cpu_rx_axis_tlast), 
    .cpu_rx_axis_tready(cpu_rx_axis_tready), 

    .merged_rx_axis_tdata(rx_axis_fifo_tdata),
    .merged_rx_axis_tvalid(rx_axis_fifo_tvalid),
    .merged_rx_axis_tlast(rx_axis_fifo_tlast),
    .merged_rx_axis_tready(rx_axis_fifo_tready),

    .is_cpu(from_cpu)
);

pkg_classify pkg_classify_inst(
    .axi_tclk(axi_tclk), // i 
    .axi_tresetn(resetn), // i
    //.enable_address_swap(1'b1), // i

    .rx_axis_fifo_tdata(rx_axis_fifo_tdata), // i
    .rx_axis_fifo_tvalid(rx_axis_fifo_tvalid), // i
    .rx_axis_fifo_tlast(rx_axis_fifo_tlast), // i
    .rx_axis_fifo_tready(top_rx_axis_fifo_tready), // o

    .mem_write_ena(top_mem_write_ena),
    .mem_write_data(top_mem_write_data),
    .mem_write_addr(top_mem_write_addr),
    .buf_start_addr(buf_start_addr),

    .is_ipv4(is_ipv4),
    .is_arp(is_arp),
    .ipv4_ready(ipv4_ready), 
    .arp_ready(arp_ready),
    .ipv4_complete(ipv4_complete),
    .arp_complete(arp_complete),
    .vlan_port(vlan_port),
    .MY_MAC_ADDRESS(MY_MAC_ADDR)
);

//assign from_cpu = vlan_port == 0;

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

buffer_pushing buffer_pushing_i (
    .clk(axi_tclk), 
    .end_addr(buf_end_addr), // i
    .start_addr(buf_start_addr), // o
    .ready(buf_ready), // o
    .start(buf_start), // i
    .last(buf_last), // i
    .finish(buf_finish), // o

    .tx_axis_fifo_tdata(eth_tx_axis_fifo_tdata),
    .tx_axis_fifo_tlast(eth_tx_axis_fifo_tlast),
    .tx_axis_fifo_tvalid(eth_tx_axis_fifo_tvalid),
    .tx_axis_fifo_tready(eth_tx_axis_fifo_tready),

    .cpu_tx_axis_fifo_tdata(cpu_tx_axis_tdata),
    .cpu_tx_axis_fifo_tready(cpu_tx_axis_tready),
    .cpu_tx_axis_fifo_tvalid(cpu_tx_axis_tvalid),
    .cpu_tx_axis_fifo_tlast(cpu_tx_axis_tlast),

    .mem_read_ena(mem_read_ena),
    .mem_read_data(mem_read_data),
    .mem_read_addr(mem_read_addr),

    .to_cpu(to_cpu)
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
    .MY_IPV4_ADDRESS(MY_IPV4_ADDR_PORT),
    .vlan_port(vlan_port),
    .from_cpu(from_cpu)
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

    .to_cpu(to_cpu),
    .from_cpu(from_cpu),

    .vlan_port(vlan_port),
    .MY_MAC_ADDRESS(MY_MAC_ADDR),
    .MY_IPV4_ADDRESS(MY_IPV4_ADDR_PORT),
    .MY_IPV4_ADDRESSES(MY_IPV4_ADDR)
);

assign mem_write_addr = is_arp ? arp_mem_write_addr : (
    is_ipv4 ? ipv4_mem_write_addr : top_mem_write_addr
);
assign mem_write_ena = is_arp ? arp_mem_write_ena : (
    is_ipv4 ? ipv4_mem_write_ena : top_mem_write_ena
);
assign mem_write_data = is_arp ? arp_mem_write_data : (
    is_ipv4 ? ipv4_mem_write_data : top_mem_write_data
);

assign buf_start = is_arp ? arp_buf_start : (
    is_ipv4 ? ipv4_buf_start : 0
);
assign buf_last = is_arp ? arp_buf_last : (
    is_ipv4 ? ipv4_buf_last : 0
);
assign buf_end_addr = is_arp ? arp_buf_end_addr : (
    is_ipv4 ? ipv4_buf_end_addr : 0
);

assign rx_axis_fifo_tready = is_arp ? arp_rx_axis_fifo_tready : (
    is_ipv4 ? ipv4_rx_axis_fifo_tready : top_rx_axis_fifo_tready
);


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

// initialize forward table

reg[31:0] counter = 0;

always @(posedge axi_tclk) begin
    if (counter < 10000)
        counter <= counter + 1;
end

// always @(posedge axi_tclk) begin
//     if (counter == 100) begin
//         lookup_modify_in_addr <= 32'h0a00010b;
//         lookup_modify_in_nexthop <= 32'h0a00010b;
//         lookup_modify_in_nextport <= 2'h0;
//         lookup_modify_in_len <= 32;
//         lookup_modify_in_ready <= 1;
//     end else if (counter == 150) begin
//         lookup_modify_in_ready <= 0;
//     end else if (counter == 350) begin
//         lookup_modify_in_addr <= 32'h0a00000c;
//         lookup_modify_in_nexthop <= 32'h0a00000c;
//         lookup_modify_in_nextport <= 2'h1;
//         lookup_modify_in_len <= 32;
//         lookup_modify_in_ready <= 1;
//     end else if (counter == 400) begin
//         lookup_modify_in_ready <= 0;
//     end else if (counter == 600) begin
//         lookup_modify_in_addr <= 32'h0a00020d;
//         lookup_modify_in_nexthop <= 32'h0a00020d;
//         lookup_modify_in_nextport <= 2'h2;
//         lookup_modify_in_len <= 32;
//         lookup_modify_in_ready <= 1;
//     end else if (counter == 650) begin
//         lookup_modify_in_ready <= 0;
//     end else if (counter == 850) begin
//         lookup_modify_in_addr <= 32'h0a00030e;
//         lookup_modify_in_nexthop <= 32'h0a00030e;
//         lookup_modify_in_nextport <= 2'h3;
//         lookup_modify_in_len <= 32;
//         lookup_modify_in_ready <= 1;
//     end else if (counter == 900) begin
//         lookup_modify_in_ready <= 0;
//     end
// end

always @(posedge axi_tclk or posedge axi_treset) begin
    if (axi_treset)  MY_IPV4_ADDR_PORT = 0;
    else if (vlan_port == 4) MY_IPV4_ADDR_PORT = MY_IPV4_ADDR[31:0];
    else if (vlan_port == 3) MY_IPV4_ADDR_PORT = MY_IPV4_ADDR[63:32];
    else if (vlan_port == 2) MY_IPV4_ADDR_PORT = MY_IPV4_ADDR[95:64];
    else if (vlan_port == 1) MY_IPV4_ADDR_PORT = MY_IPV4_ADDR[127:96];
    else MY_IPV4_ADDR_PORT = 0;
end

endmodule // router_core

// get correct ip address according to the port
module ip_address_port_access(
    input [127:0] ip_addresses,
    input [7:0] vlan_port, 
    output [31:0] ip_address
);

assign ip_address = 
    vlan_port == 4 ? ip_addresses[31:0] : (
        vlan_port == 3 ? ip_addresses[63:32] : (
            vlan_port == 2 ? ip_addresses[95:64] : (
                vlan_port == 1 ? ip_addresses[127:96] : 0
            )
        )
    );

endmodule // ip_address_port_access