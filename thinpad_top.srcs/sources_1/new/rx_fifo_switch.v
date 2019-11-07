/*
Switch between ethernet MAC fifo and CPU fifo.

*/
module rx_fifo_switch(
    input            clk,
    input            rst,

    input [7:0]      eth_rx_axis_tdata,
    input            eth_rx_axis_tvalid,
    input            eth_rx_axis_tlast,
    output           eth_rx_axis_tready,
    
    input [7:0]      cpu_rx_axis_tdata,
    input            cpu_rx_axis_tvalid,
    input            cpu_rx_axis_tlast,
    output           cpu_rx_axis_tready,

    output [7:0]     merged_rx_axis_tdata,
    output           merged_rx_axis_tvalid,
    output           merged_rx_axis_tlast,
    input            merged_rx_axis_tready,

    output wire is_cpu,
    output wire is_eth
);

localparam IDLE_MAC = 2'h0,
           IDLE_CPU = 2'h1,
           BUSY_MAC = 2'h2,
           BUSY_CPU = 2'h3;

reg [1:0] read_state, next_read_state;
reg eth_rx_end, cpu_rx_end;
wire eth_ok = read_state == IDLE_MAC && eth_rx_axis_tvalid;
wire cpu_ok = read_state == IDLE_CPU && cpu_rx_axis_tvalid;

always @(posedge clk or posedge rst) begin
    if (rst) read_state <= 0;
    else read_state <= next_read_state;
end

always @(*) begin
    case (read_state)
        IDLE_MAC: 
            next_read_state <= !eth_rx_axis_tvalid ? IDLE_CPU : (eth_rx_axis_tready ? BUSY_MAC : IDLE_MAC);
        IDLE_CPU: 
            next_read_state <= !cpu_rx_axis_tvalid ? IDLE_MAC : (cpu_rx_axis_tready ? BUSY_CPU : IDLE_CPU);
        BUSY_MAC:
            next_read_state <= eth_rx_end ? IDLE_CPU : BUSY_MAC;
        BUSY_CPU:
            next_read_state <= cpu_rx_end ? IDLE_MAC : BUSY_CPU;
        default: 
            next_read_state <= IDLE_MAC;
    endcase
end

always @(posedge clk) begin
    eth_rx_end <= eth_rx_axis_tlast && eth_rx_axis_tvalid;
    cpu_rx_end <= cpu_rx_axis_tlast && cpu_rx_axis_tvalid;
end

assign is_cpu = next_read_state == BUSY_CPU;
assign is_eth = next_read_state == BUSY_MAC;
assign merged_rx_axis_tdata = next_read_state == BUSY_CPU ? cpu_rx_axis_tdata : eth_rx_axis_tdata;
assign merged_rx_axis_tlast = next_read_state == BUSY_CPU ? cpu_rx_axis_tlast : eth_rx_axis_tlast;
assign merged_rx_axis_tvalid = eth_rx_axis_tvalid && read_state == IDLE_MAC || cpu_rx_axis_tvalid && read_state == IDLE_CPU
    || read_state == BUSY_CPU && !cpu_rx_end || read_state == BUSY_MAC && !eth_rx_end;
assign eth_rx_axis_tready = (eth_ok || read_state == BUSY_MAC) && merged_rx_axis_tready;
assign cpu_rx_axis_tready = (cpu_ok || read_state == BUSY_CPU) && merged_rx_axis_tready;

endmodule // rx_fifo_switch