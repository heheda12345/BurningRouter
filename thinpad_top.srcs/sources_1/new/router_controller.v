
module router_controller
#(parameter BUFFER_IND = 4)
(
    input wire clk,
    input wire rst,

    // if the bus require the controller to stall
    input wire read_stall,
    input wire write_stall,

    // IN direction: router -> cpu
    output wire [BUFFER_IND-1:0] in_index,
    output wire mem_write_en,
    output wire [31:0] mem_write_addr,
    output wire [31:0] mem_write_data,

    // OUT direction: cpu -> router
    // CPU send a packet by consecutively write an address and a length.
    // They share a common wire 'out_data'. 
    // 'out_state' represents if writing is available. 
    // out_state[0] : addr is received; out_state[1] : length is received
    // (IDLE)00 -> 01/10 -> (BUSY)11 -> ... -> 00
    output wire[1:0] out_state, 
    input  wire[1:0] out_en, 
    input wire[31:0] out_data, // addr or length
    output wire mem_read_en,
    output wire [31:0] mem_read_addr,
    input wire [31:0] mem_read_data,

    input wire [31:0] cpu_rx_qword_tdata, 
    input wire [3:0] cpu_rx_qword_tlast, 
    input wire cpu_rx_qword_tvalid, 
    output wire cpu_rx_qword_tready, 
    output wire [31:0] cpu_tx_qword_tdata,
    output wire [3:0] cpu_tx_qword_tlast,
    output wire cpu_tx_qword_tvalid, 
    input wire cpu_tx_qword_tready
);

router_controller_out router_controller_out_inst
(
    .clk(clk),
    .rst(rst),
    .bus_stall(read_stall),
    .out_state(out_state),
    .out_en(out_en),
    .out_data(out_data),
    .mem_read_en(mem_read_en),
    .mem_read_addr(mem_read_addr),
    .mem_read_data(mem_read_data),
    .cpu_tx_qword_tdata(cpu_tx_qword_tdata),
    .cpu_tx_qword_tlast(cpu_tx_qword_tlast),
    .cpu_tx_qword_tready(cpu_tx_qword_tready),
    .cpu_tx_qword_tvalid(cpu_tx_qword_tvalid)
);

router_controller_in  # (.BUFFER_IND(BUFFER_IND) ) router_controller_in_inst
(
    .clk(clk),
    .rst(rst),
    .bus_stall(write_stall),
    .in_index(in_index),
    .mem_write_en(mem_write_en),
    .mem_write_addr(mem_write_addr),
    .mem_write_data(mem_write_data),
    .cpu_rx_qword_tdata(cpu_rx_qword_tdata),
    .cpu_rx_qword_tlast(cpu_rx_qword_tlast),
    .cpu_rx_qword_tready(cpu_rx_qword_tready),
    .cpu_rx_qword_tvalid(cpu_rx_qword_tvalid)
);

endmodule // router_controller

// BUFFER_IND <= 10
module router_controller_in
#(parameter BUFFER_IND = 5)
(
    input wire clk,
    input wire rst,

    input wire bus_stall,
    // router -> cpu
    output wire [BUFFER_IND-1:0] in_index,
    output reg mem_write_en,
    output reg [31:0] mem_write_addr,
    output reg [31:0] mem_write_data,
    
    input wire [31:0] cpu_rx_qword_tdata, 
    input wire [3:0] cpu_rx_qword_tlast, 
    input wire cpu_rx_qword_tvalid, 
    output wire cpu_rx_qword_tready
);

localparam BLOCK_SIZE = 2048;
localparam BASE_MEM_ADDR = 32'h80600000;

localparam  IDLE = 2'h0,
            WRITE_DATA = 2'h1,
            WRITE_LEN = 2'h2;
reg [1:0] state;
reg [10:0] mem_addr_offset, total_len;
reg [BUFFER_IND-1:0] cur_index; // index of the currently writing package
reg is_end;

assign in_index = cur_index;

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        cur_index <= 0;
        total_len <= 0;
        mem_addr_offset <= 0;
        state <= IDLE;
        is_end <= 0;
    end
    else begin
        case (state)
            IDLE: state <= cpu_rx_qword_tready ? WRITE_DATA : IDLE;
            WRITE_DATA: state <= !is_end ? WRITE_DATA : WRITE_LEN;
            WRITE_LEN:  state <= bus_stall ? WRITE_LEN : IDLE;
            default: state <= IDLE;
        endcase
        is_end <= cpu_rx_qword_tready && cpu_rx_qword_tlast != 4'b0;
        if (cpu_rx_qword_tready) begin
            mem_addr_offset <= mem_addr_offset + 4;
        end
        else if (state == WRITE_LEN && !bus_stall) mem_addr_offset <= 0;
        if (state == WRITE_LEN) 
            cur_index <= cur_index + 1;
        if (state == WRITE_DATA)
            total_len <= mem_addr_offset;
    end
end

assign cpu_rx_qword_tready = cpu_rx_qword_tvalid && !bus_stall;

always @(posedge clk) begin
    if (cpu_rx_qword_tready || state == WRITE_DATA && !is_end) begin
        mem_write_en <= cpu_rx_qword_tvalid; // just request
        if (!bus_stall) begin
            mem_write_data <= cpu_rx_qword_tdata;
            mem_write_addr <= BASE_MEM_ADDR + cur_index * BLOCK_SIZE + mem_addr_offset + 4;
        end
    end else if (state == WRITE_DATA && is_end ) begin
        mem_write_en <= 1'b1; // just request
        mem_write_data <= mem_addr_offset;
        mem_write_addr <= BASE_MEM_ADDR + cur_index * BLOCK_SIZE;
    end else begin
        mem_write_en <= 1'b0;
        mem_write_data <= 0;
        mem_write_addr <= BASE_MEM_ADDR + cur_index * BLOCK_SIZE;
    end
end

endmodule // router_controller_in

module router_controller_out(
    input wire clk,
    input wire rst,

    input  wire bus_stall,
    output reg out_state = 1'b0, 
    input  wire out_en, 
    input  wire [31:0] out_data, // addr
    output reg  mem_read_en,
    output reg [31:0] mem_read_addr,
    input  wire [31:0] mem_read_data,
    
    output reg [31:0] cpu_tx_qword_tdata, 
    output reg [3:0] cpu_tx_qword_tlast, 
    output reg cpu_tx_qword_tvalid, 
    input  wire cpu_tx_qword_tready
);

localparam  IDLE = 2'b00,
            WAIT = 2'b01,
            READ_LEN = 2'b10,
            READ_DATA = 2'b11;
reg [1:0] state;
reg [10:0] total_len = 0, offset_reg = 0;
reg [31:0] base_mem_addr;

wire fifo_ready = cpu_tx_qword_tready && cpu_tx_qword_tvalid;
reg last_stall;
wire byte_ready = fifo_ready && !last_stall;
wire [10:0] offset = state == READ_LEN || byte_ready ? offset_reg: offset_reg - 4;

always @(posedge clk) begin
    last_stall <= bus_stall;
end

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        total_len <= 0;
        state <= IDLE;
        out_state <= 0;
        offset_reg <= 0;
        base_mem_addr <= 32'h0;
    end
    else begin
        if (out_en) begin
            out_state <= 1;
            base_mem_addr <= out_data;
        end
        case (state)
            IDLE: begin
                state <= !out_en ? IDLE : READ_LEN;
            end
            READ_LEN: begin
                state <= bus_stall ? READ_LEN : READ_DATA;
                if (!bus_stall) offset_reg <= offset_reg + 8; // fifo_ready = 0. Real mem offset is 4.
            end
            READ_DATA: begin
                if (offset >= total_len) begin
                    state <= IDLE;
                    out_state <= 0;
                    offset_reg <= 0;
                end else begin
                    state <= READ_DATA;
                    offset_reg <= offset + 4;
                end
            end
            default: state <= IDLE;
        endcase
        if (state == READ_LEN)
            total_len <= mem_read_data;
    end
end

always @(*) begin
    mem_read_addr <= base_mem_addr + offset;
    case (state)
        IDLE: begin
            mem_read_en <= 1'b0;
        end
        READ_LEN: begin
            mem_read_en <= 1'b1;
            mem_read_addr <= base_mem_addr;
        end
        READ_DATA: begin
            mem_read_en <= 1'b1;
        end
        default: 
            mem_read_en <= 1'b0;
    endcase
end

always @(posedge clk) begin
    case (state)
        IDLE: begin
            cpu_tx_qword_tvalid <= 0;
            cpu_tx_qword_tdata <= 0;
            cpu_tx_qword_tlast <= 4'b0000;
        end
        READ_LEN: begin
            cpu_tx_qword_tvalid <= 0;
        end
        READ_DATA: begin
            cpu_tx_qword_tvalid <= !bus_stall;
            cpu_tx_qword_tdata <= mem_read_data;
            cpu_tx_qword_tlast <= {
                offset == total_len + 3, 
                offset == total_len + 2, 
                offset == total_len + 1, 
                offset == total_len + 0
            };
        end
        default:  begin
            cpu_tx_qword_tvalid <= 0;
        end
    endcase
end

endmodule // router_controller_out
