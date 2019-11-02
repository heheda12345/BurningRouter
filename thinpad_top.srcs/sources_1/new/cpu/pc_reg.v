module pc_reg(
    input wire clk,
    input wire rst,

    input wire branch_flag_i,
    input wire[31:0] branch_target_addr_i,
    
    output reg[31:0] pc,
    output reg ce
);

always @(posedge clk) begin
    if (rst == 1'b1) begin
        ce <= 1'b0;
    end else begin
        ce <= 1'b1;
    end 
end

always @(posedge clk) begin
    if (ce == 1'b0) begin
        pc <= 0;
    end else if (branch_flag_i == 1'b1) begin
        pc <= branch_target_addr_i;
    end else begin
        pc <= pc + 32'h00000004;
    end 
end

endmodule