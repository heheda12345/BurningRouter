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
reg [ADDR_WIDTH-1:0] job_cur_mem_addr = 0, job_end_mem_addr = 0;
reg is_last = 0;

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
    if (!is_last && last) job_end_mem_addr <= end_addr + 1;
end

always @(posedge clk) begin
    state <= next_state;
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

always @ (posedge clk) begin
    //mem_read_ena <= next_state == PUSHING;
    if (next_state == PUSHING) 
        job_cur_mem_addr <= job_cur_mem_addr + 1;
    else if (next_state == IDLE)
        job_cur_mem_addr <= start_addr;
end
assign mem_read_addr = job_cur_mem_addr;
assign mem_read_ena = next_state == PUSHING;

assign tx_axis_fifo_tdata = mem_read_data;
assign tx_axis_fifo_tvalid = state == PUSHING;
assign tx_axis_fifo_tlast = job_cur_mem_addr == job_end_mem_addr && state == PUSHING;

endmodule // buffer_pushing