`include "def_op.v"

module ex(
    input wire rst,

    input wire [7:0] aluop_i,
    input wire [2:0] alusel_i,
    input wire [31:0] reg1_i,
    input wire [31:0] reg2_i,
    input wire [4:0] wd_i,
    input wire wreg_i,

    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] wdata_o
);

reg[31:0] logicout, shiftout;

always @(*) begin
    if (rst == 1'b1) begin
        logicout <= 0;
    end else begin
        case (aluop_i)
            `EXE_AND_OP: begin
                logicout <= reg1_i & reg2_i;
            end
            `EXE_OR_OP: begin
                logicout <= reg1_i | reg2_i;
            end
            `EXE_XOR_OP: begin
                logicout <= reg1_i ^ reg2_i;
            end
            default: begin
                logicout <= 0;
            end
        endcase
    end
end


always @(*) begin
    if (rst == 1'b1) begin
        shiftout <= 0;
    end else begin
        case (aluop_i)
            `EXE_SLL_OP: begin
                shiftout <= reg2_i << reg1_i[4:0];
            end
            `EXE_SRL_OP: begin
                shiftout <= reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftout <= 0;
            end
        endcase
    end
end

always @(*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout;
        end
        `EXE_RES_SHIFT: begin
            wdata_o <= shiftout;
        end
        default: begin
            $display("[ex.v] aluop %h not support", aluop_i);
            wdata_o <= 0;
        end
    endcase
end

endmodule