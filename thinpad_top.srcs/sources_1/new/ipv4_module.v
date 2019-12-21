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
    // RAM-write
    output reg mem_write_ena = 0,
    output reg [7:0] mem_write_data = 0,
    output reg [11:0] mem_write_addr = 0,
    
    input buf_ready, 
    output wire buf_start, 
    output wire buf_last,
    output wire [11:0] buf_end_addr,
    input [11:0] buf_start_addr,
    
    output wire [31:0] lookup_query_in_addr,
    output wire lookup_query_in_ready,
    input wire [31:0] lookup_query_out_nexthop,
    input wire [1:0] lookup_query_out_nextport,
    input wire lookup_query_out_ready,

    output [7:0] arp_table_query_vlan_port,
    output [31:0] arp_table_query_ipv4_addr,
    input [47:0] arp_table_output_mac_addr, 
    input arp_table_query_exist,

    input from_cpu, 
    output reg to_cpu,
    
    input [7:0] vlan_port,
    input [31:0] MY_IPV4_ADDRESS, 
    input [127:0] MY_IPV4_ADDRESSES, 
    input [47:0] MY_MAC_ADDRESS
);

localparam IDLE             = 5'h0,
           START            = 5'h1,
           HEADER_LEN       = 5'h2, // start reading...
           HEADER_SVC       = 5'h3,
           TOTAL_LEN        = 5'h4,
           ID_FLAG          = 5'h5,
           TTL              = 5'h6,
           PROTOCOL         = 5'h7,
           CHECKSUM         = 5'h8,
           SRC              = 5'h9,
           DEST             = 5'ha,
           VARIANT          = 5'hb,
           BODY             = 5'hc,// header variant part & body
           TAIL             = 5'hd,
           DISCARD          = 5'he, // end reading...
           WAIT             = 5'hf,
           OVER             = 5'h1f;

localparam WRITE_WAIT          = 5'h1,
           WRITE_CHECKSUM      = 5'h2, 
           WRITE_TTL           = 5'h3,
           WRITE_DEST_MAC_ADDR = 5'h4,
           WRITE_VLAN_PORT     = 5'h5,
           WRITE_BLOCKED       = 5'h6,
           WRITE_BLOCKED_TOCPU = 5'h7,
           WRITE_ARPREQUEST    = 5'h8,
           WRITE_PUSH          = 5'h9,
           WRITE_TOCPU         = 5'ha;

localparam WRITE_TOTAL = 46;

(*MARK_DEBUG="TRUE"*) reg [4:0] ipv4_read_state = IDLE, 
           next_read_state, 
           ipv4_write_state = IDLE, 
           next_write_state;
reg [11:0] mem_write_counter = 0;
reg rx_last;
always @ (posedge clk) begin
    rx_last <= rx_axis_fifo_tlast;
end

reg [3:0] header_length = 0;
reg [5:0] header_counter = 0;
reg [3:0] write_counter = 0;
reg [15:0] total_length = 0, total_counter = 0;
(*MARK_DEBUG="TRUE"*)reg [23:0] checksum = 0; // little-endian
reg [15:0] checksum_text = 0;
reg [7:0] ttl;
wire [31:0] dst_ip;
wire [7:0] dest_vlan_port, dest_mac_addr;
reg [7:0] dest_vlan_port_r;
reg [47:0] arp_table_output_mac_addr_r;
reg [31:0] dest_ipv4_address_r;
wire [7:0] arp_request_data;
wire [5:0] arp_request_counter;
wire arp_request_last;
reg arp_table_query_out_ready;
wire [31:0] MY_IPV4_ADDRESS_NEW;
reg to_read_over, to_read_dest;
wire next_busy_writing;

wire body_start;
wire is_writing;

always @ (posedge clk) begin
    ipv4_read_state <= next_read_state;
end
always @ (*) begin
    to_read_over <= 0;
    to_read_dest <= 0;
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
                rx_axis_fifo_tdata > 0 || from_cpu ? CHECKSUM : DISCARD // TTL > 0?
            ) : TTL;
        end
        PROTOCOL: begin
            next_read_state <= rx_axis_fifo_tvalid/* && header_counter == 10*/? CHECKSUM : PROTOCOL;
        end
        CHECKSUM: begin
            next_read_state <= rx_axis_fifo_tvalid && header_counter == 12? SRC : CHECKSUM;
        end
        SRC: begin
            if (rx_axis_fifo_tvalid && header_counter == 16) begin
                next_read_state <= DEST;
                to_read_dest <= 1;
            end else  next_read_state <= SRC;
        end
        DEST: begin
            // to_read_dest <= 1;
            if (rx_axis_fifo_tvalid && header_counter == 20) begin
                if (header_counter[5:2] == header_length) begin
                    // it is possible that this number overflows. Why do we not check it?
                    // 1. if checksum could have been proved to be right but considered wrong as a result of overflowing, 
                    //    the correct checksum must be 0x1fffe, so checksum[15:0] == checksum[23:16] == 0xffff, where it 
                    //    is impossible for the latter half equation to hold.
                    // 2. if checksum is wrong but mistaken as a correct one, it overflows, and it could not be other than
                    //    0x1ffff, which is also impossible.
                    if (checksum[15:0] + checksum[23:16] == 16'hffff) begin
                        next_read_state <= BODY;
                    end else next_read_state <= DISCARD;
                end else next_read_state <= VARIANT;
            end else  begin next_read_state <= DEST; to_read_dest <= 1; end
        end
        VARIANT: begin
            if (rx_axis_fifo_tvalid && header_counter[5:2] == header_length) begin
                if (checksum[15:0] + checksum[23:16] == 16'hffff || from_cpu) begin
                    next_read_state <= BODY;
                end else next_read_state <= DISCARD;
            end else next_read_state <= VARIANT;
        end
        BODY: begin
            if (!to_cpu && arp_table_query_out_ready && !arp_table_query_exist) next_read_state <= DISCARD;
            else begin
                if (rx_last) begin 
                    next_read_state <= is_writing ? WAIT : OVER; 
                    if (!is_writing) to_read_over <= 1;
                end
                else next_read_state <= rx_axis_fifo_tvalid && total_counter == total_length ? TAIL : BODY;
            end
        end
        TAIL: begin
            next_read_state <= rx_last ? (is_writing ? WAIT : OVER) : TAIL;
            if (rx_last && !is_writing) to_read_over <= 1;
        end
        DISCARD: begin
            next_read_state <= rx_axis_fifo_tvalid && rx_axis_fifo_tlast ? (
                is_writing ? WAIT : OVER
            ) : DISCARD;
            if (rx_axis_fifo_tvalid && rx_axis_fifo_tlast && !is_writing) to_read_over <= 1;
        end
        // pipeline, so ... no waiting?
        WAIT: begin
            if (is_writing) next_read_state <= WAIT;
            else begin
                next_read_state <= OVER;
                to_read_over <= 1;
            end
            // next_read_state <= is_writing ? WAIT : OVER;
        end
        OVER: begin
            // to_read_over <= 1;
            next_read_state <= IDLE;
        end
        default:begin
            next_read_state <= IDLE;
        end
    endcase
end

assign body_start = (ipv4_read_state == DEST || ipv4_read_state == VARIANT) && rx_axis_fifo_tvalid 
        && header_counter[5:2] == header_length && checksum[15:0] + checksum[23:16] == 16'hffff;
assign is_writing = ipv4_write_state != IDLE && ipv4_write_state != OVER;

always @ (posedge clk) begin
    ipv4_write_state <= next_write_state;
end
always @ (*) begin
    case (ipv4_write_state)
        IDLE: begin
            next_write_state <= body_start ? WRITE_TTL : IDLE;
        end
        WRITE_TTL: begin
            next_write_state <= WRITE_CHECKSUM;
        end
        WRITE_CHECKSUM : begin
            next_write_state <= write_counter == 2 ? (
                to_cpu ? (buf_ready ? WRITE_PUSH : WRITE_BLOCKED_TOCPU) : WRITE_WAIT
            ) : WRITE_CHECKSUM;
        end
        WRITE_WAIT: begin
            next_write_state <= arp_table_query_out_ready ? (arp_table_query_exist ? WRITE_DEST_MAC_ADDR : WRITE_ARPREQUEST) : WRITE_WAIT;
        end
        WRITE_DEST_MAC_ADDR : begin
            next_write_state <= write_counter == 6 ? WRITE_VLAN_PORT : WRITE_DEST_MAC_ADDR;
        end
        WRITE_VLAN_PORT : begin
            next_write_state <= buf_ready ? WRITE_PUSH : WRITE_BLOCKED;
        end
        WRITE_BLOCKED: begin
            next_write_state <= buf_ready ? WRITE_PUSH : WRITE_BLOCKED;
        end
        WRITE_BLOCKED_TOCPU: begin
            next_write_state <= buf_ready ? WRITE_TOCPU : WRITE_BLOCKED_TOCPU;
        end
        WRITE_ARPREQUEST: begin
            next_write_state <= arp_request_last ? WRITE_PUSH : WRITE_ARPREQUEST; 
        end
        WRITE_PUSH: begin
            next_write_state <= OVER;
        end
        WRITE_TOCPU: begin
            next_write_state <= OVER;
        end
        OVER: begin
            next_write_state <= IDLE;
        end
        default: next_write_state <= IDLE;
    endcase
end

assign rx_axis_fifo_tready = rx_axis_fifo_tvalid && (ipv4_read_state >= START && ipv4_read_state <= DISCARD) 
        && !(next_write_state == WRITE_CHECKSUM || next_write_state == WRITE_VLAN_PORT 
            || next_write_state == WRITE_TTL || next_write_state == WRITE_DEST_MAC_ADDR);

always @ (posedge clk) begin
    header_counter <= next_read_state >= HEADER_LEN && next_read_state < BODY ? (rx_axis_fifo_tready ?header_counter + 1 : header_counter) : 0;
    total_counter <= next_read_state >= HEADER_LEN && next_read_state <= BODY ? (rx_axis_fifo_tready ?total_counter + 1 : total_counter) : 0;
    write_counter <= next_write_state == WRITE_DEST_MAC_ADDR || next_write_state == WRITE_CHECKSUM || next_write_state == WRITE_VLAN_PORT ? write_counter + 1 : 0;
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
    if (next_read_state == TTL) begin
        if (from_cpu)
            ttl <= rx_axis_fifo_tdata;
        else ttl <= rx_axis_fifo_tdata - 1;
    end
end

function [15:0] mod_ffff_1;
input [23:0] x;
begin
    mod_ffff_1 = x[15:0] + x[23:16] > 16'hffff ? x[15:0] + x[23:16] - 16'hffff : x[15:0] + x[23:16];
end
endfunction

always @(posedge clk or posedge rst) begin
    if (rst) begin
        checksum_text <= 0;
        checksum <= 0;
    end
    else begin
        if (next_read_state >= HEADER_LEN && next_read_state <= VARIANT && rx_axis_fifo_tvalid) begin
            if (header_counter[0] == 0) 
                checksum[23:8] <= checksum[23:8] + rx_axis_fifo_tdata;
            else checksum <= checksum + rx_axis_fifo_tdata;
        end
        else if (ipv4_read_state == OVER) checksum <= 0;
        if (next_read_state == CHECKSUM) begin
            if (header_counter[0] == 0) 
                checksum_text[15:8] <= rx_axis_fifo_tdata;
            else checksum_text[7:0] <= rx_axis_fifo_tdata;
        end
        else if (next_read_state == BODY && ipv4_read_state != BODY) 
            // the only change to header is TTL (-1), so checksum += 1
            // NOTE: TTL is on higher digit, so minus 1 on that digit
            if (!from_cpu) 
                checksum_text <= ~mod_ffff_1(checksum + 16'hfeff + 16'hffff - checksum_text);
            else checksum_text <= ~mod_ffff_1(checksum + 16'hffff - checksum_text);
            // {checksum_text[7:0], checksum_text[15:8]} = 
            //     {checksum_text[7:0], checksum_text[15:8]} == 16'hfffe ? 0 : {checksum_text[7:0], checksum_text[15:8]}+1;
    end
end

// BRAM writing is 1 clock period behind FIFO reading
always @ (posedge clk) begin
    if (next_write_state == WRITE_TTL) begin
        mem_write_data <= ttl;
        mem_write_ena <= 1;
        mem_write_addr <= buf_start_addr + 26;
    end
    else if (next_write_state == WRITE_ARPREQUEST) begin
        mem_write_data <= arp_request_data;
        mem_write_ena <= 1;
        mem_write_addr <= buf_start_addr + arp_request_counter;
        mem_write_counter <= arp_request_counter;
    end
    else if (next_write_state == WRITE_DEST_MAC_ADDR) begin
        mem_write_addr <= buf_start_addr + write_counter;
        mem_write_ena <= 1;
        mem_write_data <= dest_mac_addr;
    end 
    else if (next_write_state == WRITE_VLAN_PORT) begin
        mem_write_addr <= buf_start_addr + 14 + (write_counter - 6);
        mem_write_ena <= 1;
        mem_write_data <= write_counter[0] == 0 ? 0 : dest_vlan_port_r;
    end
    else if (next_write_state == WRITE_CHECKSUM) begin
        mem_write_addr <= buf_start_addr + 28 + write_counter;
        mem_write_ena <= 1;
        mem_write_data <= write_counter[0] == 0 ? checksum_text[15:8] : checksum_text[7:0];
    end else begin
        if (ipv4_read_state == START) begin
            mem_write_addr <= buf_start_addr + 18;
            mem_write_counter <= 18;
        end
        else if (ipv4_read_state == IDLE || ipv4_read_state == OVER) begin
            mem_write_addr <= buf_start_addr;
            mem_write_counter <= 0;
        end
        else if (next_read_state > START && next_read_state <= BODY) begin
            mem_write_addr <= rx_axis_fifo_tready ? buf_start_addr + mem_write_counter + 1 : buf_start_addr + mem_write_counter;
            mem_write_counter <= rx_axis_fifo_tready ? mem_write_counter + 1 : mem_write_counter;
        end

        mem_write_ena <= next_read_state > START && next_read_state <= BODY;
        mem_write_data <= rx_axis_fifo_tdata;
    end
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
assign buf_start = next_write_state == WRITE_PUSH || next_write_state == WRITE_TOCPU;
assign buf_last = to_read_over;
assign buf_end_addr = buf_start_addr + mem_write_counter + 1; // mark the farthest point the writer pointer reaches
always @(posedge clk) begin
    if (ipv4_read_state == IDLE) to_cpu <= 0;
    else if (header_counter == 20) to_cpu <= dst_ip == MY_IPV4_ADDRESS || dst_ip[31:8] == 24'he00000;
end

assign complete = ipv4_read_state == OVER;

/*
// send out packet
assign tx_axis_fifo_tdata = mem_read_data;
always @ (posedge clk) begin
    tx_axis_fifo_tvalid <= ipv4_write_state == WRITE_PUSH;
    tx_axis_fifo_tlast <= next_write_state == OVER && ipv4_read_state == WAIT;
end
*/

arp_request_sender arp_request_sender_inst (
    .clk(clk), 
    .rst(rst), 
    .ready(next_write_state == WRITE_ARPREQUEST), 
    .opcode(8'h1), 
    .last(arp_request_last), 
    .arp_counter(arp_request_counter), 
    .my_mac_address(MY_MAC_ADDRESS), 
    .my_ipv4_address(MY_IPV4_ADDRESS_NEW),
    .target_ipv4_address(dest_ipv4_address_r), 
    .target_vlan_port(dest_vlan_port_r),
    .data(arp_request_data)
);

ip_address_port_access ip_address_port_access_inst (
    .ip_addresses(MY_IPV4_ADDRESSES),
    .vlan_port(dest_vlan_port_r), 
    .ip_address(MY_IPV4_ADDRESS_NEW)
);
/*
async_setter # (.LEN(4), .ADDR_WIDTH(2)) src_ip_setter (
    .value(src_ip),
    .clk(clk), 
    .enable(next_read_state == SRC),
    .data_input(rx_axis_fifo_tdata),
    .index(header_counter[1:0])
);*/
async_setter # (.LEN(4), .ADDR_WIDTH(2)) dst_ip_setter (
    .value(dst_ip),
    .clk(clk), 
    .enable(to_read_dest),
    .data_input(rx_axis_fifo_tdata),
    .index(header_counter[1:0])
);
async_getter # (.LEN(6)) dst_mac_getter (
    .value(dest_mac_addr),
    .index(write_counter),
    .data_input(arp_table_output_mac_addr_r)
);

assign dest_vlan_port = lookup_query_out_ready ? lookup_query_out_nextport + 1 : 0;
always @(posedge clk) begin
    if (lookup_query_out_ready) begin
        if (lookup_query_out_nexthop == 0) begin
            dest_ipv4_address_r <= dst_ip;
            dest_vlan_port_r <= dest_vlan_port;
        end else begin
            dest_vlan_port_r <= dest_vlan_port;
            dest_ipv4_address_r <= lookup_query_out_nexthop;
        end
    end
end
always @(arp_table_query_out_ready or arp_table_output_mac_addr) begin
    if (arp_table_query_out_ready)
        arp_table_output_mac_addr_r <= arp_table_output_mac_addr;
end

always @(posedge clk) begin
    arp_table_query_out_ready <= lookup_query_out_ready;
end

assign lookup_query_in_addr = dst_ip;
// just complete reading destination address
assign lookup_query_in_ready = header_counter == 20;
assign arp_table_query_ipv4_addr = lookup_query_out_nexthop;
assign arp_table_query_vlan_port = dest_vlan_port;

endmodule
