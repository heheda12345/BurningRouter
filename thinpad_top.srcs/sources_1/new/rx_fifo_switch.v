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
reg is_cpu_r, is_eth_r;
wire eth_ok = read_state == IDLE_MAC && eth_rx_axis_tvalid;
wire cpu_ok = read_state == IDLE_CPU && cpu_rx_axis_tvalid;

always @(posedge clk or posedge rst) begin
    if (rst) read_state <= 0;
    else read_state <= next_read_state;
end

always @(*) begin
    case (read_state)
        IDLE_MAC: begin
            // is_cpu_r <= 0;
            // is_eth_r <= eth_rx_axis_tvalid && eth_rx_axis_tready;
            next_read_state <= !eth_rx_axis_tvalid ? IDLE_CPU : (eth_rx_axis_tready ? BUSY_MAC : IDLE_MAC);
        end
        IDLE_CPU: begin
            // is_cpu_r <= cpu_rx_axis_tvalid && cpu_rx_axis_tready;
            // is_eth_r <= 0;
            next_read_state <= !cpu_rx_axis_tvalid ? IDLE_MAC : (cpu_rx_axis_tready ? BUSY_CPU : IDLE_CPU);
        end
        BUSY_MAC: begin
            // is_eth_r <= 1;
            // is_cpu_r <= 0;
            next_read_state <= eth_rx_end ? IDLE_CPU : BUSY_MAC;
        end
        BUSY_CPU: begin
            // is_eth_r <= 0;
            // is_cpu_r <= 1;
            next_read_state <= cpu_rx_end ? IDLE_MAC : BUSY_CPU;
        end
        default: begin
            // is_eth_r <= 0;
            // is_cpu_r <= 0;
            next_read_state <= IDLE_MAC;
        end
    endcase
end

always @(posedge clk) begin
    eth_rx_end <= eth_rx_axis_tlast && eth_rx_axis_tvalid;
    cpu_rx_end <= cpu_rx_axis_tlast && cpu_rx_axis_tvalid;
    is_cpu_r <= next_read_state == BUSY_CPU;
    is_eth_r <= next_read_state == BUSY_MAC;
end

assign is_cpu = is_cpu_r;
assign is_eth = is_eth_r;
assign merged_rx_axis_tdata = read_state == BUSY_CPU || read_state == IDLE_CPU ? cpu_rx_axis_tdata : eth_rx_axis_tdata;
assign merged_rx_axis_tlast = read_state == BUSY_CPU || read_state == IDLE_CPU ? cpu_rx_axis_tlast : eth_rx_axis_tlast;
assign merged_rx_axis_tvalid = eth_rx_axis_tvalid && read_state == IDLE_MAC || cpu_rx_axis_tvalid && read_state == IDLE_CPU
    || read_state == BUSY_CPU && !cpu_rx_end || read_state == BUSY_MAC && !eth_rx_end;
assign eth_rx_axis_tready = (eth_ok || read_state == BUSY_MAC) && merged_rx_axis_tready;
assign cpu_rx_axis_tready = (cpu_ok || read_state == BUSY_CPU) && merged_rx_axis_tready;

endmodule // rx_fifo_switch