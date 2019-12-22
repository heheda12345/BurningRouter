module router(
    input wire eth_rx_mac_aclk,
    input wire eth_tx_mac_aclk,
    input wire cpu_clk, 
    input wire eth_sync_rst_n,
    input wire cpu_rst,

    input [7:0]      eth_rx_axis_mac_tdata,
    input            eth_rx_axis_mac_tvalid,
    input            eth_rx_axis_mac_tlast,
    input            eth_rx_axis_mac_tuser,

    output [7:0]     eth_tx_axis_mac_tdata,
    output           eth_tx_axis_mac_tvalid,
    output           eth_tx_axis_mac_tlast,
    input            eth_tx_axis_mac_tready,
    output           eth_tx_axis_mac_tuser,

    // CPU-side AxiStream interface (use cpu_clk clock)
    (*mark_debug="true"*)input [31:0]     cpu_tx_qword_tdata,
    (*mark_debug="true"*)input  [3:0]     cpu_tx_qword_tlast,
    (*mark_debug="true"*)input            cpu_tx_qword_tvalid,
    (*mark_debug="true"*)output           cpu_tx_qword_tready,

    (*mark_debug="true"*)output [31:0]    cpu_rx_qword_tdata,
    (*mark_debug="true"*)output  [3:0]    cpu_rx_qword_tlast,
    (*mark_debug="true"*)output           cpu_rx_qword_tvalid,
    (*mark_debug="true"*)input            cpu_rx_qword_tready,

    input wire    ip_modify_req,    
    input  [31:0] lookup_modify_in_addr,
    input  [31:0] lookup_modify_in_nexthop,
    input         lookup_modify_in_ready,
    input  [1:0]  lookup_modify_in_nextport,
    input  [6:0]  lookup_modify_in_len,
    output  wire  lookup_modify_finish
);

wire eth_sync_rst = ~eth_sync_rst_n;

(*mark_debug="true"*)wire [7:0] cpu_rx_axis_tdata, cpu_tx_axis_tdata;
(*mark_debug="true"*)wire cpu_rx_axis_tlast, cpu_rx_axis_tready, cpu_rx_axis_tvalid;
(*mark_debug="true"*)wire cpu_tx_axis_tlast, cpu_tx_axis_tready, cpu_tx_axis_tvalid;

(*mark_debug="true"*)wire [31:0] lookup_modify_in_addr_router, lookup_modify_in_nexthop_router;
(*mark_debug="true"*)wire lookup_modify_in_ready_router;
wire [1:0] lookup_modify_in_nextport_router;
wire [6:0] lookup_modify_in_len_router;
wire lookup_modify_finish_router;
(*mark_debug="true"*)wire ip_modify_req_router;

router_core router_core_i(
    .eth_rx_mac_aclk(eth_rx_mac_aclk),
    .eth_rx_mac_resetn(eth_sync_rst_n),
    .eth_rx_axis_mac_tdata(eth_rx_axis_mac_tdata),
    .eth_rx_axis_mac_tvalid(eth_rx_axis_mac_tvalid),
    .eth_rx_axis_mac_tlast(eth_rx_axis_mac_tlast),
    .eth_rx_axis_mac_tuser(eth_rx_axis_mac_tuser),

    .eth_tx_mac_aclk(eth_tx_mac_aclk),
    .eth_tx_mac_resetn(eth_sync_rst_n),
    .eth_tx_axis_mac_tdata(eth_tx_axis_mac_tdata),
    .eth_tx_axis_mac_tvalid(eth_tx_axis_mac_tvalid),
    .eth_tx_axis_mac_tlast(eth_tx_axis_mac_tlast),
    .eth_tx_axis_mac_tready(eth_tx_axis_mac_tready),
    .eth_tx_axis_mac_tuser(eth_tx_axis_mac_tuser),

    // transmitted by CPU
    .cpu_rx_axis_tdata(cpu_rx_axis_tdata),
    .cpu_rx_axis_tlast(cpu_rx_axis_tlast),
    .cpu_rx_axis_tvalid(cpu_rx_axis_tvalid),
    .cpu_rx_axis_tready(cpu_rx_axis_tready),
    // received by CPU
    .cpu_tx_axis_tdata(cpu_tx_axis_tdata),
    .cpu_tx_axis_tlast(cpu_tx_axis_tlast),
    .cpu_tx_axis_tvalid(cpu_tx_axis_tvalid),
    .cpu_tx_axis_tready(cpu_tx_axis_tready),
    

    .ip_modify_address(lookup_modify_in_addr_router),
    .ip_modify_interface(ip_modify_req_router ? lookup_modify_in_nextport_router + 1 : 3'b0),

    .lookup_modify_in_addr(lookup_modify_in_addr_router),
    .lookup_modify_in_nexthop(lookup_modify_in_nexthop_router),
    .lookup_modify_in_ready(lookup_modify_in_ready_router),
    .lookup_modify_in_nextport(lookup_modify_in_nextport_router),
    .lookup_modify_in_len(lookup_modify_in_len_router),
    .lookup_modify_finish(lookup_modify_finish_router)
);

(*mark_debug="true"*)wire [35:0] fifo_cpu2router_din, fifo_router2cpu_dout;
(*mark_debug="true"*)wire fifo_cpu2router_empty, fifo_cpu2router_full;
(*mark_debug="true"*)wire [8:0] fifo_cpu2router_dout, fifo_router2cpu_din;
(*mark_debug="true"*)wire fifo_router2cpu_wr_en, fifo_cpu2router_rd_en;
(*mark_debug="true"*)wire fifo_router2cpu_empty, fifo_router2cpu_full;

assign cpu_rx_qword_tvalid = ~fifo_router2cpu_empty; // non-empty, CPU read is ok
assign cpu_tx_qword_tready = cpu_tx_qword_tvalid && ~fifo_cpu2router_full; // CPU ready to send
assign fifo_cpu2router_din = { 
    cpu_tx_qword_tdata[7:0], cpu_tx_qword_tlast[0],
    cpu_tx_qword_tdata[15:8], cpu_tx_qword_tlast[1], 
    cpu_tx_qword_tdata[23:16], cpu_tx_qword_tlast[2], 
    cpu_tx_qword_tdata[31:24], cpu_tx_qword_tlast[3]
};
assign cpu_rx_qword_tdata = {
    fifo_router2cpu_dout[8:1],
    fifo_router2cpu_dout[17:10],
    fifo_router2cpu_dout[26:19],
    fifo_router2cpu_dout[35:28]
};
assign cpu_rx_qword_tlast = {
    fifo_router2cpu_dout[0],
    fifo_router2cpu_dout[9],
    fifo_router2cpu_dout[18],
    fifo_router2cpu_dout[27]
};


fifo_cpu2router fifo_cpu2router_inst(
    .rd_clk(eth_rx_mac_aclk),
    .wr_clk(cpu_clk),
    .rst(eth_sync_rst),
    // <-CPU
    .full(fifo_cpu2router_full),
    .din(fifo_cpu2router_din),
    .wr_en(cpu_tx_qword_tready),
    // ->router
    .empty(fifo_cpu2router_empty),
    .dout(fifo_cpu2router_dout),
    .rd_en(fifo_cpu2router_rd_en)
);
fifo_router2cpu fifo_router2cpu_inst(
    .rd_clk(cpu_clk),
    .wr_clk(eth_rx_mac_aclk),
    .rst(eth_sync_rst),
    // <-router
    .full(fifo_router2cpu_full),
    .din(fifo_router2cpu_din),
    .wr_en(fifo_router2cpu_wr_en),
    // ->CPU
    .empty(fifo_router2cpu_empty),
    .dout(fifo_router2cpu_dout),
    .rd_en(cpu_rx_qword_tready)
);
fifo_native2axis fifo_native2axis_inst(
    .clk(eth_rx_mac_aclk),
    .rst(eth_sync_rst),
    .native_empty(fifo_cpu2router_empty),
    .native_dout(fifo_cpu2router_dout),
    .native_rd_en(fifo_cpu2router_rd_en),
    .axis_tdata(cpu_rx_axis_tdata),
    .axis_tlast(cpu_rx_axis_tlast),
    .axis_tready(cpu_rx_axis_tready),
    .axis_tvalid(cpu_rx_axis_tvalid)
);
fifo_axis2native fifo_axis2native_inst(
    .clk(eth_rx_mac_aclk),
    .rst(eth_sync_rst),
    .axis_tdata(cpu_tx_axis_tdata),
    .axis_tlast(cpu_tx_axis_tlast),
    .axis_tready(cpu_tx_axis_tready),
    .axis_tvalid(cpu_tx_axis_tvalid),
    .native_full(fifo_router2cpu_full),
    .native_din(fifo_router2cpu_din),
    .native_wr_en(fifo_router2cpu_wr_en)
);

data_crossdomain #(.WIDTH(32)) data_crossdomain_addr(
    .clk_in(cpu_clk),
    .clk_out(eth_rx_mac_aclk),
    .data_in(lookup_modify_in_addr),
    .data_out(lookup_modify_in_addr_router)
);
data_crossdomain #(.WIDTH(32)) data_crossdomain_nexthop(
    .clk_in(cpu_clk),
    .clk_out(eth_rx_mac_aclk),
    .data_in(lookup_modify_in_nexthop),
    .data_out(lookup_modify_in_nexthop_router)
);
data_crossdomain #(.WIDTH(7)) data_crossdomain_len(
    .clk_in(cpu_clk),
    .clk_out(eth_rx_mac_aclk),
    .data_in(lookup_modify_in_len),
    .data_out(lookup_modify_in_len_router)
);
data_crossdomain #(.WIDTH(2)) data_crossdomain_nextport(
    .clk_in(cpu_clk),
    .clk_out(eth_rx_mac_aclk),
    .data_in(lookup_modify_in_nextport),
    .data_out(lookup_modify_in_nextport_router)
);
pulse_crossdomain pulse_crossdomain_ready(
    .clk_in(cpu_clk),
    .clk_out(eth_rx_mac_aclk),
    .rst(cpu_rst),
    .pulse_in(lookup_modify_in_ready),
    .pulse_out(lookup_modify_in_ready_router)
);
pulse_crossdomain pulse_crossdomain_finish(
    .clk_in(eth_rx_mac_aclk),
    .clk_out(cpu_clk),
    .rst(eth_sync_rst),
    .pulse_in(lookup_modify_finish_router),
    .pulse_out(lookup_modify_finish)
);
pulse_crossdomain pulse_crossdomain_ip_modify(
    .clk_in(cpu_clk),
    .clk_out(eth_rx_mac_aclk),
    .rst(cpu_rst),
    .pulse_in(ip_modify_req),
    .pulse_out(ip_modify_req_router)
);

endmodule // router