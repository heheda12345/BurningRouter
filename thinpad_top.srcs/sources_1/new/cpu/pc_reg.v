module pc_reg(
    input wire clk,
    input wire rst,
    output reg[31:0] pc,
    output reg ce
);

always @(posedge clk) begin
    if (rst == 0) begin
        ce <= 0;
    end else begin
        ce <= 1;
    end 
end

always @(posedge clk) begin
    if (ce == 0) begin
        pc <= 0;
    end else begin
        pc <= pc + 4;
    end 
end

endmodule