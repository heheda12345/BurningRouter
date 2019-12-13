module bus(
    input wire clk,
    input wire rst,

    // Master device
    // pc_data
    output logic[31:0] pc_data,
    input  wire [31:0] pc_addr,
    output logic pc_stall, 
    // mem interface
    input wire[31:0] mem_data_i,
    output wire[31:0] mem_data_o,
    input wire[31:0] mem_addr_i,
    input wire[3:0] mem_be_i,   // byte enable 
    input wire mem_we_i,        // write enable
    input wire mem_oe_i,        // read enable 
    output logic mem_stall,
    // router mem write
    input wire router_we,
    input wire [31:0] router_addr_i,
    input wire [31:0] router_data_i,
    output wire router_write_stall,
    // router mem read
    input wire router_oe,
    input wire [31:0] router_addr_o,
    output logic [31:0] router_data_o,
    output wire router_read_stall,

    // Slave device
    // instruction ram
    inout wire[31:0] pcram_data,
    output logic[19:0] pcram_addr,
    output logic[3:0] pcram_be_n,
    output logic pcram_we_n,
    output logic pcram_oe_n,
    output logic pcram_ce_n,
    // data ram
    inout  wire [31:0] dtram_data,
    output logic[19:0] dtram_addr,
    output logic[3:0] dtram_be_n,
    output logic dtram_we_n,
    output logic dtram_oe_n,
    // router receive buffer address
    input wire [31:0] router_in_ind,
    // router packet transmission
    input  wire router_out_state, 
    output reg router_out_en, 
    output reg[31:0] router_out_data, // addr or length
    // router forward table entry modification
    output reg [31:0] lookup_modify_in_addr,
    output reg [31:0] lookup_modify_in_nexthop,
    output reg lookup_modify_in_ready,
    output reg [1:0]  lookup_modify_in_nextport,
    output reg [6:0]  lookup_modify_in_len,
    input wire lookup_modify_finish,
    
    input wire uart_dataready,
    input wire uart_tsre,
    input wire uart_tbre,
    output logic uart_rdn,
    output logic uart_wrn,

    output logic[15:0] leds
);

// bit [7:0]
localparam UART_DATA_ADDRESS = 32'hBFD003F8; 
// bit 0: available, ready to send; bit 1: received data
localparam UART_CTRL_ADDRESS = 32'hBFD003FC; 
localparam ROUTER_RECV_BUF_INDEX = 32'hBFD00400;
localparam ROUTER_SEND_STATE = 32'hBFD00404; 
localparam ROUTER_SEND_DATA = 32'hBFD00408; 
localparam ROUTER_LOOKUP_ADDR = 32'hBFD00410; 
localparam ROUTER_LOOKUP_NEXTHOP = 32'hBFD00414; 
localparam ROUTER_LOOKUP_MASKLEN = 32'hBFD00418;
localparam ROUTER_LOOKUP_NEXTPORT = 32'hBFD0041C;
localparam ROUTER_LOOKUP_CTRL = 32'hBFD00420;

wire mem_pcram = mem_addr_i >= 32'h80000000 && mem_addr_i <= 32'h803FFFFF;
wire mem_dtram = mem_addr_i >= 32'h80400000 && mem_addr_i <= 32'h807FFFFF;
wire mem_sstat = mem_addr_i == UART_CTRL_ADDRESS;
wire mem_sdata = mem_addr_i == UART_DATA_ADDRESS;
wire mem_rtrbi = mem_addr_i == ROUTER_RECV_BUF_INDEX;
wire mem_rtss = mem_addr_i == ROUTER_SEND_STATE;
wire mem_rtsd = mem_addr_i == ROUTER_SEND_DATA;
// wire router_dtram = router_addr_i >= 32'h80400000 && router_addr_i <= 32'h807FFFFF;

logic [31:0] pcram_data_reg, dtram_data_reg, mem_data_reg;
logic router_read_ok, mem_ok, router_write_ok;
logic lookup_modify_in_state;

wire [19:0] pc_phy_addr = pc_addr[21:2];
wire [19:0] mem_phy_addr = mem_addr_i[21:2];
wire [31:0] pcram_data_o, dtram_data_o;
wire mem_extram_stall;
assign pcram_data = !rst && (mem_pcram||mem_sdata) && mem_we_i ? pcram_data_reg : 32'bz;
assign pcram_data_o = pcram_data;
assign dtram_data = !rst && (mem_ok && mem_we_i || router_write_ok) ? dtram_data_reg : 32'hz;
assign dtram_data_o = dtram_data;
assign router_data_o = dtram_data;
assign mem_data_o = mem_data_reg;

assign pc_data = pcram_data_o;
assign pc_stall = !rst && (mem_pcram||mem_sdata) && (mem_we_i || mem_oe_i);


bus_judger bus_judger_inst(
    .clk(clk),
    .rst(rst),
    .cpu_mem_req((mem_we_i || mem_oe_i) && mem_dtram == 1'b1),
    .router_write_req(router_we),
    .router_read_req(router_oe),
    .cpu_mem_ok(mem_ok),
    .router_write_ok(router_write_ok),
    .router_read_ok(router_read_ok),
    .cpu_mem_stall(mem_extram_stall),
    .router_write_stall(router_write_stall),
    .router_read_stall(router_read_stall)
);

// for uart
always_comb begin
    if (pc_stall && !mem_pcram) begin
        if (!mem_oe_i && mem_we_i) begin
            uart_wrn = ~clk;
            $display("start send %h", mem_data_i[7:0]);
        end else begin
            uart_wrn = 1;
        end
        if (mem_oe_i && !mem_we_i) begin // read, high to low
            uart_rdn = clk;
        end else begin
            uart_rdn = 1;
        end
    end
    else begin
        uart_rdn = 1;
        uart_wrn = 1;
    end
end
// Base RAM control
always_comb begin
    if (rst == 1'b1) begin
        pcram_data_reg = 32'b0;
        pcram_addr = 20'b0;
        pcram_oe_n = 1'b1;
        pcram_we_n = 1'b1;
        pcram_be_n = 4'b0000;
        pcram_ce_n = 1'b1;
    end else if (pc_stall) begin
        if (mem_pcram) begin
            pcram_data_reg = mem_data_i;
            pcram_addr = mem_phy_addr;
            pcram_we_n = !mem_we_i || mem_oe_i || ~clk;
            pcram_oe_n = !mem_oe_i || mem_we_i; 
            pcram_be_n = ~mem_be_i;
            pcram_ce_n = 1'b0;
        end else begin // uart
            // disable bram
            pcram_addr = 20'b0;
            pcram_we_n = 1;
            pcram_oe_n = 1;
            pcram_be_n = 4'b0000;
            pcram_ce_n = 1;
            pcram_data_reg = mem_data_i;
        end
    end else begin
        pcram_data_reg = 32'b0;
        pcram_addr = pc_phy_addr;
        pcram_we_n = 1'b1;
        pcram_oe_n = 1'b0;
        pcram_ce_n = 1'b0;
        pcram_be_n = 4'b0000;
    end
end

// Ext RAM control
always_comb begin
    if (rst == 1'b1) begin
        dtram_data_reg = 32'b0;
        dtram_addr = 20'b0;
        dtram_be_n = 4'b0000;
        dtram_oe_n = 1'b1;
        dtram_we_n = 1'b1;
    end
    else if (router_read_ok) begin
        dtram_addr = router_addr_o[21:2];
        dtram_data_reg = 32'b0;
        dtram_be_n = 4'b0000;
        dtram_we_n = 1;
        dtram_oe_n = 0;
    end
    else if (router_write_ok) begin
        dtram_addr = router_addr_i[21:2];
        dtram_data_reg = router_data_i;
        dtram_be_n = 4'b0000;
        dtram_we_n = 0;
        dtram_oe_n = 1;
    end
    else if (mem_ok) begin
        dtram_addr = mem_phy_addr;
        dtram_data_reg = mem_data_i;
        dtram_be_n = ~mem_be_i;
        dtram_we_n = !mem_we_i || mem_oe_i || ~clk;
        dtram_oe_n = !mem_oe_i || mem_we_i;
    end
    else begin
        dtram_addr = 20'b0;
        dtram_data_reg = 32'b0;
        dtram_be_n = 4'b0000;
        dtram_we_n = 1'b1;
        dtram_oe_n = 1'b1;
    end
end

// CPU Mem load data
always_comb begin
    if (rst == 1'b1) begin
        mem_stall = 1'b1;
        mem_data_reg = 32'b0;
    end
    else if (mem_we_i) begin
        mem_stall = mem_dtram ? mem_extram_stall : 1'b0;
        mem_data_reg = 32'b0;
    end
    else if (mem_oe_i) begin
        mem_stall = 1'b0;
        if (mem_pcram)
            mem_data_reg = pcram_data;
        else if (mem_sdata)
            mem_data_reg = {24'b000000000000000000000000, pcram_data[7:0]};
        else if (mem_dtram) begin
            mem_data_reg = dtram_data_o;
            mem_stall <= mem_extram_stall;
        end else if (mem_sstat)
            mem_data_reg = {30'b000000000000000000000000000000, uart_dataready, uart_tsre};
        else if (mem_rtrbi)
            mem_data_reg = {28'b0, router_in_ind};
        else if (mem_rtss)
            mem_data_reg = router_out_state;
        else if (mem_addr_i == ROUTER_LOOKUP_CTRL)
            mem_data_reg = lookup_modify_in_state;
        else
            mem_data_reg = 32'b0;
    end else begin
        mem_stall = 1'b0;
        mem_data_reg = 32'b0;
    end
end

always_comb begin
    if (rst == 1'b0 && mem_we_i && mem_rtsd)begin
        router_out_en <= 1'b1;
        router_out_data <= mem_data_i;
    end else begin
        router_out_en <= 1'b0;
        router_out_data <= mem_data_i;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        lookup_modify_in_addr <= 0;
        lookup_modify_in_len <= 0;
        lookup_modify_in_nexthop <= 0;
        lookup_modify_in_nextport <= 0;
        lookup_modify_in_ready <= 0;
        lookup_modify_in_state <= 0;
    end else if (mem_we_i) begin
        case(mem_addr_i)
            ROUTER_LOOKUP_ADDR:     lookup_modify_in_addr <= mem_data_i;
            ROUTER_LOOKUP_MASKLEN:  lookup_modify_in_len <= mem_data_i[6:0];
            ROUTER_LOOKUP_NEXTHOP:  lookup_modify_in_nexthop <= mem_data_i;
            ROUTER_LOOKUP_NEXTPORT: lookup_modify_in_nextport <= mem_data_i[1:0];
            ROUTER_LOOKUP_CTRL: if (lookup_modify_in_state == 1'b0)begin
                lookup_modify_in_ready <= mem_data_i[0];
                lookup_modify_in_state <= mem_data_i[0];
            end
        endcase
    end
    if (lookup_modify_in_state == 1 && lookup_modify_finish) 
        lookup_modify_in_state <= 0;
    if (lookup_modify_in_ready == 1) 
        lookup_modify_in_ready <= 0;
end

endmodule // bus

module bus_judger (
    input wire clk,
    input wire rst, 

    input wire cpu_mem_req,
    input wire router_write_req,
    input wire router_read_req,

    output reg cpu_mem_ok,
    output reg router_write_ok,
    output reg router_read_ok,

    output reg cpu_mem_stall,
    output reg router_write_stall,
    output reg router_read_stall
);

reg [1:0] state, next_state;
localparam  IDLE = 2'b00,
            CPU = 2'b01,
            ROUTER_WRITE = 2'b10,
            ROUTER_READ = 2'b11;

always_ff @ (posedge clk or posedge rst) begin
    if (rst == 1'b1)
        state <= IDLE;
    else state <= next_state;
end

// One device is occupying until req becomes 0
always_comb begin
    case(state)
        CPU: begin
            if (cpu_mem_req) next_state = CPU;
            else if (router_write_req) next_state = ROUTER_WRITE;
            else if (router_read_req) next_state = ROUTER_READ;
            else next_state = IDLE;
        end
        ROUTER_WRITE: begin
            if (router_write_req) next_state = ROUTER_WRITE;
            else if (router_read_req) next_state = ROUTER_READ;
            else if (cpu_mem_req) next_state = CPU;
            else next_state = IDLE;
        end
        ROUTER_READ: begin
            if (router_read_req) next_state = ROUTER_READ;
            else if (cpu_mem_req) next_state = CPU;
            else if (router_write_req) next_state = ROUTER_WRITE;
            else next_state = IDLE;
        end
        default: begin
            if (cpu_mem_req) next_state = CPU;
            else if (router_write_req) next_state = ROUTER_WRITE;
            else if (router_read_req) next_state = ROUTER_READ;
            else next_state = IDLE;
        end
    endcase
    cpu_mem_ok = next_state == CPU;
    router_read_ok = next_state == ROUTER_READ;
    router_write_ok = next_state == ROUTER_WRITE;
    cpu_mem_stall = !cpu_mem_ok && cpu_mem_req;
    router_read_stall = !router_read_ok && router_read_req;
    router_write_stall = !router_write_ok && router_write_req;
end

endmodule