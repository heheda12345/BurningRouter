/*
ARP1. hardware(2) -> ARP2(0x0001) | ARP1*. -> ARP4(0x000108000604)
ARP2. protocol(2) -> ARP2(0x0800)
ARP3. size(2) -> ARP4(0x0604)
ARP4. opCode(2) -> ARP5(1)
ARP5. senderMAC(6), senderIP(4) -> ARP6
ARP6. targetMAC(6), targetIP(4) + updateTable(refresh with sender) -> ARP7
ARP7. !IamTarget ? OVER : updateTable(insert). [opCode] -> A. request(ARP_RQ1) B. reply(OVER)
ARP_RQ1. opCode <= reply(0x02), swap sender*, target*, src, senderMAC <= MyMAC
ARP_RQ2. sendout
*/
module arp_module(
    input clk,
    input rst, 
    input start,
    output complete,

    input [7:0] rx_axis_fifo_tdata,
    input rx_axis_fifo_tvalid,
    input rx_axis_fifo_tlast,
    output rx_axis_fifo_tready,
    output [7:0] tx_axis_fifo_tdata,
    output tx_axis_fifo_tvalid,
    output tx_axis_fifo_tlast,
    input tx_axis_fifo_tready,
    // RAM-write
    output reg mem_write_ena = 0,
    output reg [7:0] mem_write_data = 0,
    output reg [11:0] mem_write_addr = 0,
    output mem_read_ena,
    input [7:0] mem_read_data,
    output [11:0] mem_read_addr,
    // ARP Table
    output arp_table_update,
    output arp_table_insert,
    input arp_table_exist, 
    output [7:0] arp_table_input_vlan_port, 
    output [47:0] arp_table_input_mac_addr,
    output [31:0] arp_table_input_ipv4_addr, 

    input [47:0] MY_MAC_ADDRESS,
    input [31:0] MY_IPV4_ADDRESS, 
    input [7:0] vlan_port
);

localparam IDLE             = 4'b0000,
           START            = 4'b0001, // read...
           ARP1             = 4'b0010,
           OPCODE           = 4'b0011,
           READ_SENDER_MAC  = 4'b0100,
           READ_SENDER_IP   = 4'b0101,
           READ_TARGET_MAC  = 4'b0110,
           READ_TARGET_IP   = 4'b0111,
           DISCARD          = 4'b1000,
           READ_REST        = 4'b1001, // start writing
           READ_WAITING     = 4'b1010, // not read...
           OVER             = 4'b1011; // end writing

localparam WRITE_FRAME_DEST_MAC = 4'b0001,
           WRITE_SENDER_MAC     = 4'b0010,
           WRITE_PUSHING        = 4'b0100,
           WRITE_OPCODE         = 4'b1000,
           WRITE_WAIT           = 4'b1111;

localparam WRITE_TOTAL = 46;

reg [3:0] arp_read_state = IDLE, next_read_state;
reg [3:0] arp_write_state = IDLE, next_write_state;
reg [2:0] arp_counter1 = 0, 
          opcode_counter = 0,
          sender_mac_counter = 0, 
          target_mac_counter = 0, 
          sender_ip_counter = 0, 
          target_ip_counter = 0;
reg [5:0] write_counter = 0, general_write_counter = 0;
reg [7:0] opCode = 0;
wire [31:0] sender_ip, target_ip;
wire [47:0] sender_mac, target_mac;
wire [47:0] arp_consts;
reg [2:0] my_mac_addr_index = 0;
wire [7:0] my_mac_addr_i;
assign arp_consts = 48'h000108000604;
wire arp1_valid;
reg rx_end = 0;
wire arp_table_edit_enable;

wire arp1_equal_enable;
async_equal # ( .LEN(6) ) arp1_equal (
    .clk(clk), 
    .data_input(rx_axis_fifo_tdata), 
    .index(arp_counter1), 
    .operand(arp_consts),
    .enable(arp1_equal_enable),
    .result(arp1_valid)
);
assign arp1_equal_enable = next_read_state == ARP1;

always @ (posedge clk) begin
    arp_read_state <= next_read_state;
    arp_write_state <= next_write_state;
end
always @ (*) begin
    case (arp_read_state)
        IDLE: begin
            next_read_state <= start ? START : IDLE;
        end
        START: begin
            next_read_state <= rx_axis_fifo_tvalid ? ARP1 : START;
        end
        ARP1: begin
            next_read_state <= rx_axis_fifo_tvalid && arp_counter1 == 6 ? (arp1_valid ? OPCODE : DISCARD) : ARP1;
        end
        OPCODE: begin
            next_read_state <= rx_axis_fifo_tvalid && opcode_counter == 2 ? READ_SENDER_MAC : OPCODE;
        end
        READ_SENDER_MAC: begin
            next_read_state <= rx_axis_fifo_tvalid && sender_mac_counter == 6 ? READ_SENDER_IP : READ_SENDER_MAC;
        end
        READ_SENDER_IP: begin
            next_read_state <= rx_axis_fifo_tvalid && sender_ip_counter == 4 ? READ_TARGET_MAC : READ_SENDER_IP;
        end
        READ_TARGET_MAC: begin
            next_read_state <= rx_axis_fifo_tvalid && target_mac_counter == 6 ? READ_TARGET_IP : READ_TARGET_MAC;
        end
        READ_TARGET_IP: begin
            if (rx_axis_fifo_tvalid && target_ip_counter == 4)
            begin
                if (opCode == 8'h02 && MY_IPV4_ADDRESS == target_ip) 
                    next_read_state <= rx_end ? READ_WAITING : READ_REST;
                else
                    next_read_state <= rx_end ? OVER : DISCARD;
            end
            //next_read_state <= rx_axis_fifo_tvalid && target_ip_counter == 4 ? (rx_end ? READ_WAITING : READ_REST) : READ_TARGET_IP;
        end
        READ_REST: begin
            next_read_state <= rx_end ? READ_WAITING : READ_REST;
        end
        DISCARD: begin
            next_read_state <= rx_end ? OVER : DISCARD;
        end
        READ_WAITING: begin
            next_read_state <= write_counter < WRITE_TOTAL ? READ_WAITING : OVER;
        end
        OVER: begin
            next_read_state <= IDLE;
        end
    endcase
end

always @ (*) begin
    case (arp_write_state)
        IDLE: 
            next_write_state <= next_read_state == READ_REST || next_read_state == READ_WAITING ? WRITE_FRAME_DEST_MAC : IDLE;
        WRITE_FRAME_DEST_MAC: 
            next_write_state <= general_write_counter == 5 ? WRITE_SENDER_MAC : WRITE_FRAME_DEST_MAC;
        WRITE_SENDER_MAC:
            next_write_state <= general_write_counter == 5 ? WRITE_OPCODE : WRITE_SENDER_MAC;
        WRITE_OPCODE:
            next_write_state <= tx_axis_fifo_tready ? WRITE_PUSHING : WRITE_OPCODE;
        WRITE_PUSHING: 
            next_write_state <= write_counter < WRITE_TOTAL ? WRITE_PUSHING : OVER;
        OVER: 
            next_write_state = IDLE;
    endcase
end

assign rx_axis_fifo_tready = rx_axis_fifo_tvalid && (next_read_state >= START && next_read_state <= READ_REST);

always @ (posedge clk) begin
    arp_counter1 <= rx_axis_fifo_tvalid && (next_read_state == ARP1) ? arp_counter1 + 1 : 0;
    sender_mac_counter <= rx_axis_fifo_tvalid && (next_read_state == READ_SENDER_MAC) ? sender_mac_counter + 1 : 0;
    sender_ip_counter <= rx_axis_fifo_tvalid && (next_read_state == READ_SENDER_IP) ? sender_ip_counter + 1 : 0;
    target_mac_counter <= rx_axis_fifo_tvalid && (next_read_state == READ_TARGET_MAC) ? target_mac_counter + 1 : 0;
    target_ip_counter <= rx_axis_fifo_tvalid && (next_read_state == READ_TARGET_IP) ? target_ip_counter + 1 : 0;
    opcode_counter <= rx_axis_fifo_tvalid && (next_read_state == OPCODE) ? opcode_counter + 1 : 0;
    //write_sender_mac_counter <= next_write_state == WRITE_SENDER_MAC ? write_sender_mac_counter + 1 : 0;
    write_counter <= next_write_state == WRITE_PUSHING && tx_axis_fifo_tready ? write_counter + 1 : 0;
    //general_read_counter <= rx_axis_fifo_tvalid ? ( (next_read_state != arp_read_state ? 0 : general_write_counter + 1) ) : general_read_counter;
    general_write_counter <= next_write_state != arp_write_state ? 0 : general_write_counter + 1;
end

always @ (posedge clk) begin
    if (rx_axis_fifo_tvalid && opcode_counter == 1) 
        opCode <= rx_axis_fifo_tdata + 1; // turn request into reply, reply into ???
end

async_setter # (.LEN(6)) sender_mac_setter (
    .value(sender_mac),
    .clk(clk), 
    .enable(next_read_state == READ_SENDER_MAC),
    .data_input(rx_axis_fifo_tdata),
    .index(sender_mac_counter)
);
async_setter # (.LEN(6)) target_mac_setter (
    .value(target_mac),
    .clk(clk), 
    .enable(next_read_state == READ_TARGET_MAC),
    .data_input(rx_axis_fifo_tdata),
    .index(target_mac_counter)
);
async_setter # (.LEN(4)) sender_ip_setter (
    .value(sender_ip),
    .clk(clk), 
    .enable(next_read_state == READ_SENDER_IP),
    .data_input(rx_axis_fifo_tdata),
    .index(sender_ip_counter)
);
async_setter # (.LEN(4)) target_ip_setter (
    .value(target_ip),
    .clk(clk), 
    .enable(next_read_state == READ_TARGET_IP),
    .data_input(rx_axis_fifo_tdata),
    .index(target_ip_counter)
);
async_getter # (.LEN(6)) my_mac_getter (
    .value(my_mac_addr_i), 
    .index(general_write_counter), 
    .data_input(MY_MAC_ADDRESS)
);

assign complete = arp_read_state == OVER;

always @ (posedge clk) begin
    rx_end <= rx_axis_fifo_tlast;
end

// store into RAM
wire fifo_writing;
assign fifo_writing = next_read_state >= ARP1 && next_read_state <= READ_TARGET_IP;
always @ (posedge clk) begin
    if (arp_write_state == WRITE_FRAME_DEST_MAC) begin
        mem_write_addr <= 6 + general_write_counter;
        mem_write_data <= my_mac_addr_i;
        mem_write_ena <= 1;
    end
    else if (arp_write_state == WRITE_SENDER_MAC) begin
        mem_write_addr <= 26 + general_write_counter;
        mem_write_data <= my_mac_addr_i;
        mem_write_ena <= 1;
    end
    else if (arp_write_state == WRITE_OPCODE) begin
        mem_write_addr <= 25;
        mem_write_data <= opCode;
        mem_write_ena <= 1;
    end
    else begin
        mem_write_data <= fifo_writing ? rx_axis_fifo_tdata : 0;
        mem_write_ena <= fifo_writing;
        case(next_read_state)
            ARP1:            mem_write_addr <= 18 + arp_counter1;
            OPCODE:          mem_write_addr <= 24 + opcode_counter;
            READ_SENDER_MAC: mem_write_addr <= 36 + sender_mac_counter;
            READ_SENDER_IP:  mem_write_addr <= 42 + sender_ip_counter;
            READ_TARGET_MAC: mem_write_addr <= 26 + target_mac_counter;
            READ_TARGET_IP:  mem_write_addr <= 32 + target_ip_counter;
            default:         mem_write_addr <= 0;
        endcase
    end
end

// write into tx FIFO
assign tx_axis_fifo_tvalid = tx_axis_fifo_tready && (arp_write_state == WRITE_PUSHING);
assign tx_axis_fifo_tdata = mem_read_data;
assign tx_axis_fifo_tlast = tx_axis_fifo_tvalid && next_write_state == OVER;
assign mem_read_addr = write_counter;
assign mem_read_ena = tx_axis_fifo_tready && (next_write_state == WRITE_PUSHING);

// ARP Table manipulations
assign arp_table_input_vlan_port = vlan_port;
assign arp_table_input_mac_addr = target_mac;
assign arp_table_input_ipv4_addr = target_ip;
assign arp_table_edit_enable = target_ip_counter == 4; // READ_TARGET_IP -> READ_REST/READ_WAITING
assign arp_table_insert = arp_table_edit_enable && target_mac == MY_MAC_ADDRESS && !arp_table_exist;
assign arp_table_update = arp_table_edit_enable && arp_table_exist;

endmodule

module async_setter
#( parameter LEN = 6, ADDR_WIDTH = 3)
(
    input [7:0] data_input,
    input [ADDR_WIDTH-1:0] index,
    input enable,
    input clk,
    output reg [LEN*8-1:0] value = 0
);

genvar i;
for (i = 0; i < LEN; i = i+1) begin
    always @ (posedge clk)begin
        if (enable && index == i) 
            value[8*(LEN-i-1)+7:8*(LEN-i-1)] <= data_input;
    end
end
endmodule

module async_getter
#( parameter LEN = 6, ADDR_WIDTH = 3)
(
    output [7:0] value,
    input [ADDR_WIDTH-1:0] index,
    input [LEN*8-1:0] data_input
);
wire [LEN*8-1:0] _value;

genvar i;
for (i = 1; i < LEN; i = i+1) begin
    assign _value[8*(LEN-i-1)+7: 8*(LEN-i-1)] = _value[8*(LEN-i)+7: 8*(LEN-i)] | (i == index ? data_input[8*(LEN-i-1)+7: 8*(LEN-i-1)] : 0);
end
assign _value[LEN*8-1:LEN*8-8] = 0 == index ? data_input[LEN*8-1:LEN*8-8] : 0;
assign value = _value[7:0];
endmodule

module async_equal
#( parameter LEN = 6)
(
    input [7:0] data_input,
    input [3:0] index,
    input enable,
    input clk,
    input [LEN*8-1:0] operand, 
    output reg result = 0
);

wire [LEN-1:0] eqif, prefix;
genvar i;
for (i = 0; i < LEN; i = i+1) begin
    assign eqif[i] = index != i || data_input == operand[i*8+7: i*8];
    assign prefix[i] = i == 0 ? eqif[0] : eqif[i] || eqif[i-1];
end

always @ (posedge clk) begin
    if (!enable)
        result <= 1;
    else begin
        result <= result & prefix[LEN-1];
    end
end

endmodule