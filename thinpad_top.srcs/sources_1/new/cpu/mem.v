module mem(
    input wire rst,

    input wire[4:0] wd_i,
    input wire wreg_i,
    input wire[31:0] wdata_i,

    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] wdata_o
);

always @(*) begin
    if (rst == 1'b1) begin
        wd_o <= 0;
        wreg_o <= 0;
        wdata_o <= 0;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
    end
end

endmodule