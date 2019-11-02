module pc_reg(
    input wire clk,
    input wire rst,
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
    if (ce == 1'b1) begin
        pc <= 0;
    end else begin
        pc <= pc + 32'h00000004;
    end 
end

endmodule