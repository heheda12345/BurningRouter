module bus(
    input wire clk,
    input wire rst,

    // instruction ram
    inout wire[31:0] pcram_data,
    output logic[19:0] pcram_addr,
    output logic[3:0] pcram_be_n,
    output logic pcram_we_n,
    output logic pcram_oe_n,
    
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
    inout wire[31:0] mem_data,
    input wire[31:0] mem_addr_i,
    input wire[3:0] mem_be_i,   // byte enable
    input wire mem_we_i,        // write enable
    input wire mem_oe_i,        // read enable
    output logic mem_stall
);

// bit [7:0]
localparam UART_DATA_ADDRESS = 32'hBFD003F8; 
// bit 0: available, ready to send; bit 1: received data
localparam UART_CTRL_ADDRESS = 32'hBFD003FC; 

wire mem_pcram = mem_addr_i >= 32'h80000000 && mem_addr_i <= 32'h803FFFFF;
wire mem_dtram = mem_addr_i >= 32'h80400000 && mem_addr_i <= 32'h807FFFFF;
logic [31:0] pcram_data_reg, dtram_data_reg, mem_data_reg;

wire [19:0] pc_phy_addr = pc_addr[21:2];
wire [19:0] mem_phy_addr = mem_addr_i[21:2];
assign pcram_data = !rst && mem_pcram && mem_we_i ? pcram_data_reg : 32'bz;
assign dtram_data = !rst && mem_dtram && mem_we_i ? dtram_data_reg : 32'hz;
assign mem_data = !rst && mem_oe_i && ~mem_we_i ? mem_data_reg : 32'hz;

assign pc_data = pcram_data;
assign pc_stall = !rst && mem_pcram && (mem_we_i || mem_oe_i);

always_comb begin
    pcram_be_n = 4'b0000;
    if (rst == 1'b1) begin
        pcram_data_reg = 32'b0;
        pcram_addr = 20'b0;
        pcram_oe_n = 1'b1;
        pcram_we_n = 1'b1;
    end else if (pc_stall) begin
        pcram_data_reg = mem_data;
        pcram_addr = mem_phy_addr;
        pcram_we_n = !mem_we_i || mem_oe_i;
        pcram_oe_n = !mem_oe_i || mem_we_i;
    end else begin
        pcram_data_reg = 32'b0;
        pcram_addr = pc_phy_addr;
        pcram_we_n = 1'b1;
        pcram_oe_n = 1'b0;
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
        dtram_data_reg = mem_data;
        dtram_be_n = ~mem_be_i;
        dtram_we_n = !mem_we_i || mem_oe_i;
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
        else if (mem_dtram)
            mem_data_reg = dtram_data;
        else
            mem_data_reg = 32'b0;
    end else begin
        mem_stall = 1'b1;
        mem_data_reg = 32'b0;
    end
end

endmodule // bus