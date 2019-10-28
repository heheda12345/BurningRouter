/*
IP Header format:
1. Version + Header Length (1)
2. Service(1)
3. Total Length(2)
4. Identification + Flags(4)
5. TTL(1)
6. Protocol(1)
7. Checksum(2)
8. source(4)
9. destination(4)
(10. variant?)
11. Data
*/
module ipv4_module(
    input clk,
    input rst, 
    input start,
    output complete,

    input [7:0] rx_axis_fifo_tdata,
    input rx_axis_fifo_tvalid,
    input rx_axis_fifo_tlast,
    output rx_axis_fifo_tready,
    /*
    output [7:0] tx_axis_fifo_tdata,
    output reg tx_axis_fifo_tvalid,
    output reg tx_axis_fifo_tlast,
    input tx_axis_fifo_tready,
    */
    // RAM-write
    output reg mem_write_ena = 0,
    output reg [7:0] mem_write_data = 0,
    output reg [11:0] mem_write_addr = 0,
    /*
    output mem_read_ena,
    input [7:0] mem_read_data,
    output reg [11:0] mem_read_addr = 0
    */
    input buf_ready, 
    output wire buf_start, 
    output wire buf_last,
    output wire [11:0] buf_end_addr,
    input [11:0] buf_start_addr
    //input 
);

localparam IDLE             = 4'h0,
           START            = 4'h1,
           HEADER_LEN       = 4'h2, // start reading...
           HEADER_SVC       = 4'h3,
           TOTAL_LEN        = 4'h4,
           ID_FLAG          = 4'h5,
           TTL              = 4'h6,
           //PROTOCOL         = 4'h7,
           CHECKSUM         = 4'h7,
           SRC              = 4'h8,
           DEST             = 4'h9,
           VARIANT          = 4'ha,
           BODY             = 4'hb,
           TAIL             = 4'hc,
           DISCARD          = 4'hd, // end reading...
           WAIT             = 4'he,
           OVER             = 4'hf;

localparam WRITE_PUSH               = 4'h1, 
           WRITE_DEST_MAC_ADDR = 4'h2 ;

localparam WRITE_TOTAL = 46;

(*MARK_DEBUG="TRUE"*) reg [3:0] ipv4_read_state = IDLE, 
           next_read_state, 
           ipv4_write_state = IDLE, 
           next_write_state;
reg [11:0] read_addr = 0, write_addr = 0;
reg rx_last;
always @ (posedge clk) begin
    rx_last <= rx_axis_fifo_tlast;
end

reg [3:0] header_length = 0;
reg [5:0] header_counter = 0;
reg [15:0] total_length = 0, total_counter = 0;
reg [23:0] checksum = 0;
wire [15:0] dst_ip, src_ip;

always @ (posedge clk) begin
    ipv4_read_state <= next_read_state;
end
always @ (*) begin
    if (rst) begin
        next_read_state <= IDLE;
    end
    else case (ipv4_read_state)
        IDLE: begin
            next_read_state <= start ? START : IDLE;
        end
        START: begin
            next_read_state <= rx_axis_fifo_tvalid ? HEADER_LEN : START;
        end
        HEADER_LEN: begin
            next_read_state <= rx_axis_fifo_tvalid/*&& header_counter == 1*/ ? HEADER_SVC : HEADER_LEN;
        end
        HEADER_SVC: begin
            next_read_state <= rx_axis_fifo_tvalid/*&& header_counter == 2*/? TOTAL_LEN : HEADER_SVC;
        end
        TOTAL_LEN: begin
            next_read_state <= rx_axis_fifo_tvalid && header_counter == 4 ? ID_FLAG : TOTAL_LEN;
        end
        ID_FLAG: begin
            next_read_state <= rx_axis_fifo_tvalid && header_counter == 8 ? TTL : ID_FLAG;
        end
        TTL: begin
            next_read_state <= rx_axis_fifo_tvalid/*&& header_counter == 9*/? (
                rx_axis_fifo_tdata > 0 ? CHECKSUM : DISCARD // TTL > 0?
            ) : TTL;
        end
        /*
        PROTOCOL: begin
            next_read_state <= rx_axis_fifo_tvalid/ *&& header_counter == 10* /? CHECKSUM : PROTOCOL;
        end*/
        CHECKSUM: begin // now include both protocol & checksum
            next_read_state <= rx_axis_fifo_tvalid && header_counter == 12? SRC : CHECKSUM;
        end
        SRC: begin
            next_read_state <= rx_axis_fifo_tvalid && header_counter == 16? DEST : SRC;
        end
        DEST: begin
            next_read_state <= rx_axis_fifo_tvalid && header_counter == 20? (
                header_counter[5:2] < header_length ? VARIANT : (
                    BODY//(checksum[15:0] + checksum[23:16]) == 16'hffff ? BODY : DISCARD // checksum? no
                )
            ) : DEST;
        end
        VARIANT: begin
            next_read_state <= rx_axis_fifo_tvalid && header_counter[5:2] == header_length? BODY :  (
                BODY//(checksum[15:0] + checksum[23:16]) == 16'hffff ? BODY : DISCARD // checksum? no
            );
        end
        BODY: begin
            if (rx_last) next_read_state <= next_write_state == IDLE ? OVER : WAIT;
            else next_read_state <= rx_axis_fifo_tvalid && total_counter == total_length ? TAIL : BODY;
            //next_read_state <= total_counter == total_length ? (rx_last ? WAIT : TAIL) : BODY;
        end
        TAIL: begin
            next_read_state <= rx_last ? (next_write_state == IDLE ? OVER : WAIT) : TAIL;
        end
        DISCARD: begin
            next_read_state <= rx_axis_fifo_tvalid && rx_axis_fifo_tlast ? OVER : DISCARD;
        end
        // pipeline, so ... no waiting?
        WAIT: begin
            next_read_state <= next_write_state == IDLE ? OVER : WAIT;
        end
        OVER: begin
            next_read_state <= IDLE;
        end
        default:begin
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
            next_write_state <= ipv4_read_state == DEST && next_read_state != DEST ? WRITE_DEST_MAC_ADDR : IDLE;
        end
        WRITE_DEST_MAC_ADDR : begin
            next_write_state <= buf_ready ? WRITE_PUSH : WAIT;
        end
        WAIT: begin
            next_write_state <= buf_ready ? WRITE_PUSH : WAIT;
        end
        WRITE_PUSH: begin
            next_write_state <= OVER;
        end
        OVER: begin
            next_write_state <= IDLE;
        end
        default: next_write_state <= IDLE;
    endcase
end

assign rx_axis_fifo_tready = rx_axis_fifo_tvalid && (ipv4_read_state >= START && ipv4_read_state <= DISCARD);

always @ (posedge clk) begin
    header_counter <= rx_axis_fifo_tvalid && (next_read_state >= HEADER_LEN && next_read_state <= VARIANT) ? header_counter + 1 : 0;
    total_counter <= rx_axis_fifo_tvalid && (next_read_state >= HEADER_LEN && next_read_state <= BODY) ? total_counter + 1 : 0;
end

always @ (posedge clk) begin
    if (next_read_state == HEADER_LEN) 
        header_length <= rx_axis_fifo_tdata[3:0];
    if (next_read_state == TOTAL_LEN) begin
        if (header_counter == 2) 
            total_length[15:8] <= rx_axis_fifo_tdata;
        else if (header_counter == 3)
            total_length[7:0] <= rx_axis_fifo_tdata;
    end
end

// BRAM writing is 1 clock period behind FIFO reading
always @ (posedge clk) begin
    if (ipv4_read_state == START) 
        mem_write_addr <= buf_start_addr + 18;
    else if (ipv4_read_state == IDLE || ipv4_read_state == OVER) 
        mem_write_addr <= buf_start_addr;
    else if (next_read_state > START && ipv4_read_state <= BODY)
        mem_write_addr <= rx_axis_fifo_tvalid ? mem_write_addr + 1 : mem_write_addr;
    else 
        mem_write_addr <= mem_write_addr;

    mem_write_ena <= next_read_state > START && next_read_state <= BODY;

    if (next_read_state == TTL)
        mem_write_data <= rx_axis_fifo_tdata - 1; // TTL --
    else mem_write_data <= rx_axis_fifo_tdata;
end

/*
always @ (posedge clk) begin
    if (ipv4_write_state == WRITE_PUSH) begin
        if (tx_axis_fifo_tready)
            mem_read_addr <= mem_read_addr + 1;
    end
    else
        mem_read_addr <= buf_start_addr;
end*/
//assign mem_read_ena = ipv4_write_state == WRITE_PUSH;
assign buf_start = next_write_state == WRITE_PUSH && buf_ready;
assign buf_last = ipv4_read_state <= BODY && next_read_state > BODY;
assign buf_end_addr = mem_write_addr;

assign complete = ipv4_read_state == OVER;

/*
// send out packet
assign tx_axis_fifo_tdata = mem_read_data;
always @ (posedge clk) begin
    tx_axis_fifo_tvalid <= ipv4_write_state == WRITE_PUSH;
    tx_axis_fifo_tlast <= next_write_state == OVER && ipv4_read_state == WAIT;
end
*/

async_setter # (.LEN(4)) src_ip_setter (
    .value(src_ip),
    .clk(clk), 
    .enable(next_read_state == SRC),
    .data_input(rx_axis_fifo_tdata),
    .index(header_counter[1:0])
);
async_setter # (.LEN(4)) dst_ip_setter (
    .value(dst_ip),
    .clk(clk), 
    .enable(next_read_state == DEST),
    .data_input(rx_axis_fifo_tdata),
    .index(header_counter[1:0])
);

endmodule