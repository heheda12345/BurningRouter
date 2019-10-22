module ipv4_module(
    input clk,
    input rst, 
    input start,
    output complete,

    input [7:0] rx_axis_fifo_tdata,
    input rx_axis_fifo_tvalid,
    input rx_axis_fifo_tlast,
    output rx_axis_fifo_tready,
    output [7:0] tx_axis_fifo_tdata,
    output reg tx_axis_fifo_tvalid,
    output reg tx_axis_fifo_tlast,
    input tx_axis_fifo_tready,
    // RAM-write
    output reg mem_write_ena = 0,
    output reg [7:0] mem_write_data = 0,
    output reg [11:0] mem_write_addr = 0,
    output mem_read_ena,
    input [7:0] mem_read_data,
    output reg [11:0] mem_read_addr = 0
);

localparam IDLE             = 4'b0000,
           START            = 4'b0001,
           HEADER1          = 4'b0010,
           HEADER_LEN       = 4'b0011,
           HEADER2          = 4'b0100,
           TTL              = 4'b0101,
           PROTOCOL         = 4'b0110,
           CHECKSUM         = 4'b0111,
           SRC              = 4'b1000,
           DEST             = 4'b1001,
           BODY             = 4'b1010,
           WAIT            = 4'b1011,
           OVER             = 4'b1100;

localparam WRITE = 4'b0001;

localparam WRITE_TOTAL = 46;

reg [3:0] ipv4_read_state = IDLE, 
           next_read_state, 
           ipv4_write_state = IDLE, 
           next_write_state;
reg [4:0] header_counter = 0;
reg [11:0] read_addr = 0, write_addr = 0;
reg rx_last;
always @ (posedge clk) begin
    rx_last <= rx_axis_fifo_tlast;
end

always @ (posedge clk) begin
    ipv4_read_state <= next_read_state;
end
always @ (*) begin
    case (ipv4_read_state)
        IDLE: begin
            next_read_state <= start ? START : IDLE;
        end
        START: begin
            next_read_state <= rx_axis_fifo_tvalid ? HEADER1 : START;
        end
        HEADER1: begin
            next_read_state <= rx_axis_fifo_tvalid && header_counter < 20 ? BODY : HEADER1;
        end
        BODY: begin
            next_read_state <= rx_last ? WAIT : BODY;
        end
        WAIT: begin
            next_read_state <= mem_read_addr != mem_write_addr ? WAIT : OVER;
        end
        OVER: begin
            next_read_state <= IDLE;
        end
    endcase
end

always @ (posedge clk) begin
    ipv4_write_state <= next_write_state;
end
always @ (*) begin
    case (ipv4_write_state)
        IDLE: begin
            next_write_state <= ipv4_read_state == BODY ? WRITE : IDLE;
        end
        WRITE: begin
            next_write_state <= mem_read_addr != mem_write_addr ? WRITE : OVER;
            // PROBLEM: if rx is not ready for a period such that the reader pointer catches up with the writer...
        end
        OVER: begin
            next_write_state <= IDLE;
        end
    endcase
end

assign rx_axis_fifo_tready = rx_axis_fifo_tvalid && (ipv4_read_state >= START && ipv4_read_state <= BODY);

always @ (posedge clk) begin
    header_counter <= rx_axis_fifo_tvalid && (next_read_state == HEADER1) ? header_counter + 1 : 0;
end

always @ (posedge clk) begin
    if (ipv4_read_state == START) 
        mem_write_addr <= 18;
    else if (ipv4_read_state == WAIT) 
        mem_write_addr <= mem_write_addr;
    else if (ipv4_read_state > START && ipv4_read_state <= BODY)
        mem_write_addr <= rx_axis_fifo_tvalid ? mem_write_addr + 1 : mem_write_addr;
    else 
        mem_write_addr <= 0;
    mem_write_ena <= rx_axis_fifo_tready || rx_last;
    mem_write_data <= rx_axis_fifo_tdata;
end
always @ (posedge clk) begin
    if (ipv4_write_state == WRITE) begin
        if (tx_axis_fifo_tready)
            mem_read_addr <= mem_read_addr + 1;
    end
    else
        mem_read_addr <= 0;
end
assign mem_read_ena = ipv4_write_state == WRITE;

assign complete = ipv4_write_state == OVER;

// send out packet
assign tx_axis_fifo_tdata = mem_read_data;
always @ (posedge clk) begin
    tx_axis_fifo_tvalid <= ipv4_write_state == WRITE;
    tx_axis_fifo_tlast <= next_write_state == OVER && ipv4_read_state == WAIT;
end


endmodule