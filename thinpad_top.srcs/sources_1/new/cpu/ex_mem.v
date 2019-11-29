module ex_mem(
    input wire clk,
    input wire rst,

    input wire[4:0] ex_wd,
    input wire ex_wreg,
    input wire[31:0] ex_wdata,
    input wire[7:0] ex_alu_op,
    input wire[31:0] ex_ram_addr,
    input wire ex_cp0_reg_we,
    input wire[4:0] ex_cp0_reg_write_addr,
    input wire[31:0] ex_cp0_reg_data,

    input wire mem_stall, // unimplement

    output reg[4:0] mem_wd,
    output reg mem_wreg,
    output reg[31:0] mem_wdata,
    output reg[7:0] mem_alu_op,
    output reg[31:0] mem_ram_addr,
    output reg mem_cp0_reg_we,
    output reg[4:0] mem_cp0_reg_write_addr,
    output reg[31:0] mem_cp0_reg_data
);

always @(posedge clk) begin
    if (rst == 1'b1) begin
        mem_wd <= 0;
        mem_wreg <= 0;
        mem_wdata <= 0;
        mem_alu_op <= 0;
        mem_ram_addr <= 0;
        mem_cp0_reg_we <= 0;
        mem_cp0_reg_write_addr <= 0;
        mem_cp0_reg_data <= 0;
    end else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_alu_op <= ex_alu_op;
        mem_ram_addr <= ex_ram_addr;
        mem_cp0_reg_we <= ex_cp0_reg_we;
        mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
        mem_cp0_reg_data <= ex_cp0_reg_data;
    end 
end

endmodule