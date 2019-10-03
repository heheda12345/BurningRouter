/*
rx_client->swap->wr_client
*/

module eth_mac_wrapper (
    // MAC-side (write-side) AxiStream interface
    input            rx_mac_aclk,
    input            rx_mac_resetn,
    input [7:0]      rx_axis_mac_tdata,
    input            rx_axis_mac_tvalid,
    input            rx_axis_mac_tlast,
    input            rx_axis_mac_tuser,

    // MAC-side (read-side) AxiStream interface
    input            tx_mac_aclk,
    input            tx_mac_resetn,
    output [7:0]     tx_axis_mac_tdata,
    output           tx_axis_mac_tvalid,
    output           tx_axis_mac_tlast,
    input            tx_axis_mac_tready,
    output           tx_axis_mac_tuser
);



wire clk = rx_mac_aclk;
wire resetn = rx_mac_resetn | tx_mac_resetn ;

wire rx_axis_fifo_tvalid;
wire [7:0] rx_axis_fifo_tdata;
wire rx_axis_fifo_tlast;
wire rx_axis_fifo_tready;

wire tx_axis_fifo_tvalid;
wire [7:0] tx_axis_fifo_tdata;
wire tx_axis_fifo_tlast;
wire tx_axis_fifo_tready;


eth_mac_rx_client_fifo rx_fifo_i
(
    .rx_fifo_aclk(clk), // i
    .rx_fifo_resetn(resetn), // i
    .rx_axis_fifo_tdata(rx_axis_fifo_tdata), // o
    .rx_axis_fifo_tvalid(rx_axis_fifo_tvalid), // o
    .rx_axis_fifo_tlast(rx_axis_fifo_tlast), // o
    .rx_axis_fifo_tready(rx_axis_fifo_tready), // i

    .rx_mac_aclk(clk), // i
    .rx_mac_resetn(resetn), // i
    .rx_axis_mac_tdata(rx_axis_mac_tdata), // i
    .rx_axis_mac_tvalid(rx_axis_mac_tvalid), // i
    .rx_axis_mac_tlast(rx_axis_mac_tlast), // i
    .rx_axis_mac_tuser(rx_axis_mac_tuser) // i
);

eth_mac_address_swap addr_swap_i(
    .axi_tclk(clk), // i 
    .axi_tresetn(resetn), // i
    .enable_address_swap(1'b1), // i

    .rx_axis_fifo_tdata(rx_axis_fifo_tdata), // i
    .rx_axis_fifo_tvalid(rx_axis_fifo_tvalid), // i
    .rx_axis_fifo_tlast(rx_axis_fifo_tlast), // i
    .rx_axis_fifo_tready(rx_axis_fifo_tready), // o

    .tx_axis_fifo_tdata(tx_axis_fifo_tdata), // o
    .tx_axis_fifo_tvalid(tx_axis_fifo_tvalid), // o
    .tx_axis_fifo_tlast(tx_axis_fifo_tlast), // o
    .tx_axis_fifo_tready(tx_axis_fifo_tready) // i
);

eth_mac_tx_client_fifo tx_fifo_i(
    .tx_fifo_aclk(clk), // i
    .tx_fifo_resetn(resetn), // i
    .tx_axis_fifo_tdata(tx_axis_fifo_tdata), // i
    .tx_axis_fifo_tvalid(tx_axis_fifo_tvalid), // i
    .tx_axis_fifo_tlast(tx_axis_fifo_tlast), // i
    .tx_axis_fifo_tready(tx_axis_fifo_tready), // o

    .tx_mac_aclk(tx_mac_aclk), // i
    .tx_mac_resetn(resetn), // i
    .tx_axis_mac_tdata(tx_axis_mac_tdata), // o
    .tx_axis_mac_tvalid(tx_axis_mac_tvalid), // o
    .tx_axis_mac_tlast(tx_axis_mac_tlast), // o
    .tx_axis_mac_tready(tx_axis_mac_tready), // i
    .tx_axis_mac_tuser(tx_axis_mac_tuser), // o
 
    .tx_collision(1'b1), // i zc: not sure
    .tx_retransmit(1'b0) // i
);

endmodule
