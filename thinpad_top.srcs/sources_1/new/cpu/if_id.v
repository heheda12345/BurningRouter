module if_id(
    input wire clk,
    input wire rst,

    input wire[31:0] if_pc,
    input wire[31:0] if_inst,
    input wire if_ce,

    output reg[31:0] id_pc,
    output reg[31:0] id_inst
);

always @(posedge clk) begin
    if (rst == 1'b1 || if_ce == 1'b0) begin
        id_pc <= 0;
        id_inst <= 0;
    end else begin
        $display("pc %h %h", if_pc, if_inst);
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end

endmodule