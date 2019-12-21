/*
Package Classification
Use RAM as a random access fifo
After scanning dest, src and type, RAM is completely controled by sub-module
S1. dest(6) -> A. S2(dest==me || dest=ff*6) B. THROW(otherwise)
S2. src(6)
S3. 0x8000
S4. VLAN Tag(2)
S5. swap dest, src. type(2) -> A. ARP(0x0806) B. IPv4(0x0800)
*/

module pkg_classify(
    input            axi_tclk,
    input            axi_tresetn,

    output     [15:0] debug,
    
    // data from the RX FIFO
    input      [7:0] rx_axis_fifo_tdata,
    input            rx_axis_fifo_tvalid,   // wait
    input            rx_axis_fifo_tlast,
    output           rx_axis_fifo_tready,   // ready
    
    output reg mem_write_ena,
    output reg [ 7:0] mem_write_data,
    output reg [11:0] mem_write_addr,
    input [11:0] buf_start_addr,

    output is_ipv4,
    output is_arp,
    output ipv4_ready, 
    output arp_ready,
    input ipv4_complete,
    input arp_complete,
    output reg [7:0] vlan_port,
    input [47:0] MY_MAC_ADDRESS
);

//parameter MAC_BROADCAST = 48'hffffffffffff;

localparam        IDLE           = 3'b000,
                  WAIT           = 3'b001,
                  READ_DEST      = 3'b010,
                  READ_SRC       = 3'b011,
                  READ_TYPE      = 3'b100,
                  READ_VLAN_PORT = 3'b101,
                  READ_VLAN_TYPE = 3'b110,
                  DISCARD        = 3'b111;

localparam  IPV4 = 2'b01,
            ARP = 2'b10;

wire axi_treset;
assign axi_treset = !axi_tresetn;

(*mark_debug="true"*)reg [2:0] read_state = IDLE, next_read_state = IDLE;
reg [2:0] dst_counter, src_counter;
reg type_counter, vlan_port_counter, vlan_type_counter;

reg [7:0] protocol_type_1 = 0;
reg [2:0] dst_mac_addr_match = 0;

wire sub_procedure_ready; // '1' when last type char is available
wire sub_procedure_complete;
reg [1:0] sub_procedure_type = 2'b00;

assign debug[2:0] = read_state;
assign debug[5:4] = sub_procedure_type;

always @ (posedge axi_tclk)
begin
    read_state <= axi_tresetn ? next_read_state : IDLE;
end

assign rx_axis_fifo_tready = rx_axis_fifo_tvalid; // read as soon as available

always @ (*)
begin
    if (rx_axis_fifo_tvalid) begin
        case (read_state)
            IDLE: begin
                // new package?
                next_read_state <= rx_axis_fifo_tvalid ? READ_DEST : IDLE;
            end
            WAIT: begin
                next_read_state <= sub_procedure_complete ? IDLE : WAIT;
            end
            READ_DEST: begin
                if (dst_counter <= 5) begin
                    next_read_state <= READ_DEST;
                end
                else if (dst_mac_addr_match != 3'b000) begin
                    next_read_state <= READ_SRC;
                end
                else begin
                    next_read_state <= DISCARD;
                end
            end
            READ_SRC:
                next_read_state <= src_counter <= 5 ? READ_SRC : READ_TYPE;
            READ_TYPE:
                next_read_state <= type_counter == 1 ? READ_TYPE : READ_VLAN_PORT;
            READ_VLAN_PORT:
                next_read_state <= vlan_port_counter == 1 ? READ_VLAN_PORT : READ_VLAN_TYPE;
            READ_VLAN_TYPE:
                next_read_state <= vlan_type_counter == 1 ? READ_VLAN_TYPE : (sub_procedure_type > 0 ? WAIT : DISCARD);
            DISCARD:
                next_read_state <= rx_axis_fifo_tlast ? IDLE : DISCARD;
            default:
                next_read_state <= read_state;
        endcase 
    end else begin
        if (read_state == WAIT) next_read_state <= sub_procedure_complete ? IDLE : WAIT;
        else next_read_state <= read_state;
    end
end

always @ (posedge axi_tclk) begin
    if (axi_treset) begin
        dst_counter <= 0;
        src_counter <= 0;
        type_counter <= 0;
        vlan_type_counter <= 0;
        vlan_port_counter <= 0;
    end else if (rx_axis_fifo_tvalid) begin
        dst_counter <= next_read_state == READ_DEST ? dst_counter + 1 : 0;
        src_counter <= next_read_state == READ_SRC ? src_counter + 1 : 0;
        type_counter <= next_read_state == READ_TYPE ? ~type_counter : 0;
        vlan_type_counter <= next_read_state == READ_VLAN_TYPE ? ~vlan_type_counter : 0;
        vlan_port_counter <= next_read_state == READ_VLAN_PORT ? ~vlan_port_counter : 0;
    end
end

always @ (posedge axi_tclk) begin
    if (next_read_state != READ_DEST) begin
        dst_mac_addr_match <= 3'b111;
    end
    else begin 
        if (rx_axis_fifo_tvalid) begin
            dst_mac_addr_match[0] <= dst_mac_addr_match[0] & (rx_axis_fifo_tdata == 8'hff);
            case (dst_counter)
                0: dst_mac_addr_match[2] <= rx_axis_fifo_tdata == 8'h01;
                1: dst_mac_addr_match[2] <= dst_mac_addr_match[2] & rx_axis_fifo_tdata == 8'h00;
                2: dst_mac_addr_match[2] <= dst_mac_addr_match[2] & rx_axis_fifo_tdata == 8'h5e;
                3, 4, 5: dst_mac_addr_match[2] <= dst_mac_addr_match[2];
                default: dst_mac_addr_match[2] <= 0;
            endcase
            case (dst_counter)
                0: dst_mac_addr_match[1] <= rx_axis_fifo_tdata == MY_MAC_ADDRESS[47:40];
                1: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDRESS[39:32]);
                2: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDRESS[31:24]);
                3: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDRESS[23:16]);
                4: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDRESS[15: 8]);
                5: dst_mac_addr_match[1] <= dst_mac_addr_match[1] & (rx_axis_fifo_tdata == MY_MAC_ADDRESS[ 7: 0]);
                default: dst_mac_addr_match[1] <= 0;
            endcase
        end
    end
end

always @ (posedge axi_tclk) begin
    if (rx_axis_fifo_tvalid && next_read_state == READ_VLAN_TYPE && vlan_type_counter == 0) begin
        protocol_type_1 <= rx_axis_fifo_tdata;
    end
end

always @ (posedge axi_tclk) begin
    if (rx_axis_fifo_tvalid && next_read_state == READ_VLAN_PORT && vlan_port_counter == 1) begin
        vlan_port <= rx_axis_fifo_tdata;
    end
end

// sub procedure

assign sub_procedure_ready = /*next_read_state == READ_VLAN_TYPE && */vlan_type_counter == 1;
assign ipv4_ready = sub_procedure_ready && protocol_type_1 == 8'h08 && rx_axis_fifo_tvalid && rx_axis_fifo_tdata == 8'h00;
assign arp_ready = sub_procedure_ready && protocol_type_1 == 8'h08 && rx_axis_fifo_tvalid && rx_axis_fifo_tdata == 8'h06;
assign sub_procedure_complete = arp_complete || ipv4_complete;

always @ (posedge axi_tclk) begin
    if (next_read_state == READ_VLAN_TYPE && vlan_type_counter == 1) begin
        sub_procedure_type <= arp_ready ? ARP : (ipv4_ready ? IPV4 : 0);
    end
    else if (next_read_state == WAIT || read_state == WAIT || !rx_axis_fifo_tvalid)
        sub_procedure_type <= sub_procedure_type;
    else
        sub_procedure_type <= 0;
end

// store MAC address into RAM

always @ (posedge axi_tclk) begin
    mem_write_ena <= rx_axis_fifo_tvalid;
    mem_write_data <= rx_axis_fifo_tdata;
    case (next_read_state)
        READ_DEST: 
            mem_write_addr <= buf_start_addr + 6 + dst_counter;
        READ_SRC:
            mem_write_addr <= buf_start_addr + src_counter;
        READ_TYPE:
            mem_write_addr <= buf_start_addr + 12 + type_counter;
        READ_VLAN_PORT:
            mem_write_addr <= buf_start_addr + 14 + vlan_port_counter;
        READ_VLAN_TYPE:
            mem_write_addr <= buf_start_addr + 16 + vlan_type_counter;
        default: 
            mem_write_addr <= buf_start_addr;
    endcase
end

assign is_arp = sub_procedure_type == ARP && read_state == WAIT;
assign is_ipv4 = sub_procedure_type == IPV4 && read_state == WAIT;

// for simulation
initial begin
    dst_counter <= 0;
end

endmodule // pkg_classify