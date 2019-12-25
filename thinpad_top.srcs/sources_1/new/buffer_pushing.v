module buffer_pushing
# (parameter ADDR_WIDTH = 12)
(
    input wire clk, 
    input wire rst,
    input wire [ADDR_WIDTH-1:0] end_addr, // when reading complete, lock it into job_end_mem_addr
    (*mark_debug="true"*)output reg [ADDR_WIDTH-1:0] start_addr = 0,
    output wire ready,
    input wire start,
    input wire last, // whether package complete
    output wire finish,
    
    output wire [7:0] tx_axis_fifo_tdata,
    output reg tx_axis_fifo_tvalid,
    output wire tx_axis_fifo_tlast,
    input wire tx_axis_fifo_tready,

    output wire [7:0] cpu_tx_axis_fifo_tdata,
    input wire cpu_tx_axis_fifo_tready,
    output reg cpu_tx_axis_fifo_tvalid,
    output wire cpu_tx_axis_fifo_tlast,

    (*mark_debug="true"*)output wire mem_read_ena,
    (*mark_debug="true"*)input wire [7:0] mem_read_data,
    (*mark_debug="true"*)output wire [11:0] mem_read_addr,

    (*mark_debug="true"*)input wire to_cpu
);

localparam  IDLE = 3'd0,
            PUSHING = 3'd1,
            WAITING = 3'd2,
            OVER = 3'd3;
(*mark_debug="true"*)reg [2:0] state = IDLE, next_state;
(*mark_debug="true"*)reg [ADDR_WIDTH-1:0] job_cur_mem_addr_r = 0, job_end_mem_addr_r = 0;
(*mark_debug="true"*)wire [ADDR_WIDTH-1:0] job_cur_mem_addr;
(*mark_debug="true"*)wire [ADDR_WIDTH - 1:0 ] job_end_mem_addr;
(*mark_debug="true"*)reg is_last = 0;
(*mark_debug="true"*)reg to_cpu_r = 0;
wire packet_end;

assign ready = state == IDLE;
assign finish = state == OVER;

always @(posedge clk) begin
    if (next_state == IDLE) begin
        is_last <= 0;
    end
    else if ((next_state == PUSHING || next_state == WAITING) && last) begin
        start_addr <= end_addr + 1;
        is_last <= 1;
        // job_end_mem_addr <= end_addr;
    end
    if (!is_last) job_end_mem_addr_r <= end_addr;
end

assign job_end_mem_addr = !is_last ? end_addr : job_end_mem_addr_r;

always @(posedge clk) begin
    if (rst) state <= IDLE;
    else state <= next_state;
end

always @(posedge clk) begin
    if (state == IDLE) to_cpu_r <= to_cpu;
end

always @(*) begin
    case (state)
        IDLE: 
            next_state <= start ? PUSHING : IDLE;
        PUSHING, WAITING:
            next_state <= job_cur_mem_addr == job_end_mem_addr ? (is_last ? OVER : WAITING) : PUSHING;
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
    if (fifo_ready) 
        job_cur_mem_addr_r <= job_cur_mem_addr_r + 1;
    else if (next_state == IDLE)
        job_cur_mem_addr_r <= start_addr;
end
assign job_cur_mem_addr = fifo_ready ? job_cur_mem_addr_r + 1 : job_cur_mem_addr_r;  
assign mem_read_addr = job_cur_mem_addr;
assign mem_read_ena = next_state != IDLE && job_cur_mem_addr != job_end_mem_addr && (job_cur_mem_addr + 1 != job_end_mem_addr || is_last);

assign tx_axis_fifo_tdata = mem_read_data;
assign cpu_tx_axis_fifo_tdata = mem_read_data;
always @(posedge clk) begin
    tx_axis_fifo_tvalid <= mem_read_ena && !to_cpu_r;
    cpu_tx_axis_fifo_tvalid <= mem_read_ena && to_cpu_r;
end
assign packet_end = is_last && job_cur_mem_addr == job_end_mem_addr;
assign tx_axis_fifo_tlast = !to_cpu_r && packet_end && tx_axis_fifo_tvalid;
assign cpu_tx_axis_fifo_tlast = packet_end && to_cpu_r && cpu_tx_axis_fifo_tvalid;

endmodule // buffer_pushing