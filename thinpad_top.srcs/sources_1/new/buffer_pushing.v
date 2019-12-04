module buffer_pushing
# (parameter ADDR_WIDTH = 12)
(
    input wire clk, 
    input wire [ADDR_WIDTH-1:0] end_addr, // when reading complete, lock it into job_end_mem_addr
    output reg [ADDR_WIDTH-1:0] start_addr = 0,
    output wire ready,
    input wire start,
    input wire last, // whether package complete
    output wire finish,
    
    output wire [7:0] tx_axis_fifo_tdata,
    output wire tx_axis_fifo_tvalid,
    output wire tx_axis_fifo_tlast,
    input wire tx_axis_fifo_tready,

    output wire [7:0] cpu_tx_axis_fifo_tdata,
    input wire cpu_tx_axis_fifo_tready,
    output wire cpu_tx_axis_fifo_tvalid,
    output wire cpu_tx_axis_fifo_tlast,

    output wire mem_read_ena,
    input wire [7:0] mem_read_data,
    output wire [11:0] mem_read_addr,

    input wire to_cpu
);

localparam  IDLE = 3'd0,
            PUSHING = 3'd1,
            WAITING = 3'd2,
            OVER = 3'd3;
reg [2:0] state = IDLE, next_state;
reg [ADDR_WIDTH-1:0] job_cur_mem_addr = 0, job_end_mem_addr_r = 0;
wire [ADDR_WIDTH - 1:0 ] job_end_mem_addr;
reg is_last = 0;
reg to_cpu_r;
wire packet_end;

assign ready = state == IDLE;
assign finish = state == OVER;

always @(posedge clk) begin
    if (next_state == IDLE) begin
        is_last <= 0;
    end
    else if (next_state == PUSHING && last) begin
        start_addr <= end_addr + 1;
        is_last <= 1;
        // job_end_mem_addr <= end_addr;
    end
    if (!is_last) job_end_mem_addr_r <= end_addr;
end

assign job_end_mem_addr = !is_last ? end_addr : job_end_mem_addr;

always @(posedge clk) begin
    state <= next_state;
end

always @(posedge clk) begin
    if (next_state == IDLE) to_cpu_r <= to_cpu;
end

always @(*) begin
    case (state)
        IDLE: 
            next_state <= start ? PUSHING : IDLE;
        PUSHING:
            next_state <= job_cur_mem_addr == job_end_mem_addr ? (is_last ? OVER : WAITING) : PUSHING;
        WAITING:
            next_state <= job_cur_mem_addr == job_end_mem_addr ? WAITING : PUSHING;
        OVER:
            next_state <= IDLE;
        default: 
            next_state <= IDLE;
    endcase
end

wire fifo_ready = to_cpu_r && cpu_tx_axis_fifo_tready && cpu_tx_axis_fifo_tvalid
        || !to_cpu_r && tx_axis_fifo_tready && tx_axis_fifo_tvalid;

always @ (posedge clk) begin
    //mem_read_ena <= next_state == PUSHING;
    if (mem_read_ena) 
        job_cur_mem_addr <= job_cur_mem_addr + 1;
    else if (next_state == IDLE)
        job_cur_mem_addr <= start_addr;
end
assign mem_read_addr = job_cur_mem_addr;
assign mem_read_ena = next_state == PUSHING && (fifo_ready || start);

assign tx_axis_fifo_tdata = mem_read_data;
assign cpu_tx_axis_fifo_tdata = mem_read_data;
assign tx_axis_fifo_tvalid = state == PUSHING && !to_cpu_r;
assign cpu_tx_axis_fifo_tvalid = state == PUSHING && to_cpu_r;
assign packet_end = is_last && job_cur_mem_addr == job_end_mem_addr;
assign tx_axis_fifo_tlast = packet_end && tx_axis_fifo_tvalid;
assign cpu_tx_axis_fifo_tlast = packet_end && cpu_tx_axis_fifo_tvalid;

endmodule // buffer_pushing