module bus(
    input wire clk,
    input wire rst,

    // instruction ram
    (*mark_debug="true"*)inout wire[31:0] pcram_data,
    (*mark_debug="true"*)output logic[19:0] pcram_addr,
    output logic[3:0] pcram_be_n,
    (*mark_debug="true"*)output logic pcram_we_n,
    (*mark_debug="true"*)output logic pcram_oe_n,
    output logic pcram_ce_n,
    
    // data ram
    inout wire[31:0] dtram_data,
    output logic[19:0] dtram_addr,
    output logic[3:0] dtram_be_n,
    output logic dtram_we_n,
    output logic dtram_oe_n,
    
    // pc_data
    output logic [31:0] pc_data,
    input wire [31:0] pc_addr, 
    output logic pc_stall, 
    // mem interface
    input wire[31:0] mem_data_i,
    output wire[31:0] mem_data_o,
    (*mark_debug="true"*)input wire[31:0] mem_addr_i,
    input wire[3:0] mem_be_i,   // byte enable
    (*mark_debug="true"*)input wire mem_we_i,        // write enable
    (*mark_debug="true"*)input wire mem_oe_i,        // read enable
    output logic mem_stall,

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

wire mem_pcram = mem_addr_i >= 32'h80000000 && mem_addr_i <= 32'h803FFFFF;
wire mem_dtram = mem_addr_i >= 32'h80400000 && mem_addr_i <= 32'h807FFFFF;
wire mem_sstat = mem_addr_i == UART_CTRL_ADDRESS;
wire mem_sdata = mem_addr_i == UART_DATA_ADDRESS;
logic [31:0] pcram_data_reg, dtram_data_reg, mem_data_reg;

wire [19:0] pc_phy_addr = pc_addr[21:2];
wire [19:0] mem_phy_addr = mem_addr_i[21:2];
wire [31:0] pcram_data_o, dtram_data_o;
assign pcram_data = !rst && (mem_pcram||mem_sdata) && mem_we_i ? pcram_data_reg : 32'bz;
assign pcram_data_o = pcram_data;
assign dtram_data = !rst && mem_dtram && mem_we_i ? dtram_data_reg : 32'hz;
assign dtram_data_o = dtram_data;
assign mem_data_o = mem_data_reg;

assign pc_data = pcram_data_o;
assign pc_stall = !rst && (mem_pcram||mem_sdata) && (mem_we_i || mem_oe_i);


always_comb begin
    if (rst == 1'b1) begin
        pcram_data_reg = 32'b0;
        pcram_addr = 20'b0;
        pcram_oe_n = 1'b1;
        pcram_we_n = 1'b1;
        pcram_be_n = 4'b0000;
        pcram_ce_n = 1'b1;
        uart_rdn = 1;
        uart_wrn = 0;
        leds = 0;
    end else if (pc_stall) begin
        if (mem_pcram) begin
            pcram_data_reg = mem_data_i;
            pcram_addr = mem_phy_addr;
            pcram_we_n = !mem_we_i || mem_oe_i || ~clk;
            pcram_oe_n = !mem_oe_i || mem_we_i; 
            pcram_be_n = ~mem_be_i;
            pcram_ce_n = 1'b0;
            uart_rdn = 1;
            uart_wrn = 1;
        end else begin // uart
            // disable bram
            pcram_addr = 20'b0;
            pcram_we_n = 1;
            pcram_oe_n = 1;
            pcram_be_n = 4'b0000;
            pcram_ce_n = 1;
            pcram_data_reg = mem_data_i;
            // for uart
            if (!mem_oe_i && mem_we_i) begin
                uart_wrn = ~clk;
                leds = mem_data_i[15:0];
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
    end else begin
        pcram_data_reg = 32'b0;
        pcram_addr = pc_phy_addr;
        pcram_we_n = 1'b1;
        pcram_oe_n = 1'b0;
        pcram_ce_n = 1'b0;
        pcram_be_n = 4'b0000;
        uart_rdn = 1;
        uart_wrn = 1;
    end
end

always_comb begin
    if (rst == 1'b1) begin
        dtram_data_reg = 32'b0;
        dtram_addr = 20'b0;
        dtram_be_n = 4'b0000;
        dtram_oe_n = 1'b1;
        dtram_we_n = 1'b1;
    end
    else if (mem_dtram) begin
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

always_comb begin
    if (rst == 1'b1) begin
        mem_stall = 1'b1;
        mem_data_reg = 32'b0;
    end
    else if (mem_we_i) begin
        mem_stall = 1'b0;
        mem_data_reg = 32'b0;
    end
    else if (mem_oe_i) begin
        mem_stall = 1'b0;
        if (mem_pcram)
            mem_data_reg = pcram_data;
        else if (mem_sdata)
            mem_data_reg = {24'b000000000000000000000000, pcram_data[7:0]};
        else if (mem_dtram)
            mem_data_reg = dtram_data_o;
        else if (mem_sstat)
            mem_data_reg = {30'b000000000000000000000000000000, uart_dataready, uart_tsre};
        else
            mem_data_reg = 32'b0;
    end else begin
        mem_stall = 1'b1;
        mem_data_reg = 32'b0;
    end
end

endmodule // bus
