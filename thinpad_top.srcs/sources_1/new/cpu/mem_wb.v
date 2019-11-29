module mem_wb(
    input wire clk,
    input wire rst,
    
    input wire[4:0] mem_wd,
    input wire mem_wreg,
    input wire[31:0] mem_wdata,
    input wire mem_cp0_reg_we,
    input wire[4:0] mem_cp0_reg_write_addr,
    input wire[31:0] mem_cp0_reg_data,

    input wire wb_stall, // not implement

    output reg[4:0] wb_wd,
    output reg wb_wreg,
    output reg[31:0] wb_wdata,
    output reg wb_cp0_reg_we,
    output reg[4:0] wb_cp0_reg_write_addr,
    output reg[31:0] wb_cp0_reg_data
);

always @(posedge clk) begin
    if (rst == 1'b1) begin
        wb_wd <= 0;
        wb_wreg <= 0;
        wb_wdata <= 0;
        wb_cp0_reg_we <= 0;
        wb_cp0_reg_write_addr <= 0;
        wb_cp0_reg_data <= 0;
    end else begin
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
        wb_cp0_reg_we <= mem_cp0_reg_we;
        wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
        wb_cp0_reg_data <= mem_cp0_reg_data;
    end
end

endmodule