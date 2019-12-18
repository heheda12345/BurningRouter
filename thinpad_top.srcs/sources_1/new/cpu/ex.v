`include "def_op.v"

module ex(
    input wire rst,

    input wire [7:0] aluop_i,
    input wire [2:0] alusel_i,
    input wire [31:0] reg1_i,
    input wire [31:0] reg2_i,
    input wire [4:0] wd_i,
    input wire wreg_i,
    input wire [31:0] link_addr_i,
    input wire is_in_delayslot,
    input wire [31:0] ram_offset_i,
    input wire [31:0] inst_i,
    input wire [31:0] cp0_reg_data_i,
    input wire mem_cp0_reg_we,
    input wire [4:0] mem_cp0_reg_write_addr,
    input wire [31:0] mem_cp0_reg_data,
    input wire wb_cp0_reg_we,
    input wire [4:0] wb_cp0_reg_write_addr,
    input wire [31:0] wb_cp0_reg_data,
    input wire [31:0] excepttype_i,
    input wire [31:0] current_inst_address_i,

    output reg [4:0] wd_o,
    output reg wreg_o,
    output reg [31:0] wdata_o,
    output reg [7:0] aluop_o,
    output reg [31:0] ram_addr_o,
    output reg [4:0] cp0_reg_read_addr_o,
    output reg cp0_reg_we_o,
    output reg [4:0] cp0_reg_write_addr_o,
    output reg [31:0] cp0_reg_data_o,
    output wire [31:0] excepttype_o,
    output wire is_in_delayslot_o,
    output wire [31:0] current_inst_address_o
);

reg[31:0] moveres, logicout, shiftout, arithout, ramout;

assign excepttype_o = excepttype_i;
assign is_in_delayslot_o = is_in_delayslot;
assign current_inst_address_o = current_inst_address_i;

always @(*) begin
    cp0_reg_read_addr_o <= 0;
    if (rst == 1'b1) begin
        moveres <= 0;
    end else begin
        moveres <= 0;
        case (aluop_i)
            `EXE_MOVZ_OP: begin
                moveres <= reg1_i;
            end
            `EXE_MFC0_OP: begin
                cp0_reg_read_addr_o <= inst_i[15:11];
                if (mem_cp0_reg_we == 1'b1 && mem_cp0_reg_write_addr == inst_i[15:11]) begin
                    moveres <= mem_cp0_reg_data;
                end else if (wb_cp0_reg_we == 1'b1 && wb_cp0_reg_write_addr == inst_i[15:11]) begin
                    moveres <= wb_cp0_reg_data;
                end else begin
                    moveres <= cp0_reg_data_i;
                end
            end
            default: begin
            end
        endcase
    end
end

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
            `EXE_SRA_OP: begin
                shiftout <= ({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]}))
                            | reg2_i >> reg1_i[4:0];
            end
            default: begin
                shiftout <= 0;
            end
        endcase
    end
end

wire[31:0] result_minus;
assign result_minus = reg1_i - reg2_i;

always @(*) begin
    if (rst == 1'b1) begin
        arithout <= 0;
    end else begin
        case (aluop_i)
            `EXE_ADDU_OP: begin
                arithout <= reg1_i + reg2_i;
            end
            `EXE_SUBU_OP: begin
                arithout <= result_minus; // OK?
            end
            `EXE_SLT_OP: begin // OK? one bit only?
                arithout <= ((reg1_i[31] && !reg2_i[31]) || 
                             (!reg1_i[31] && !reg2_i[31] && result_minus[31]) ||
                             (reg1_i[31] && reg2_i[31] && result_minus[31]));
            end
            `EXE_SLTU_OP: begin // OK? one bit only?
                arithout <= (reg1_i < reg2_i);
            end
            default: begin
                arithout <= 0;
            end
        endcase
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        ramout <= 0;
    end else begin
        ramout <= 0;
        case (aluop_i)
            `EXE_SB_OP: begin
                ramout <= reg2_i;
            end
            `EXE_SH_OP: begin
                ramout <= reg2_i;
            end
            `EXE_SW_OP: begin
                ramout <= reg2_i;
            end
        endcase
    end
end

always @(*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    ram_addr_o <= alusel_i == `EXE_RES_RAM ? ram_offset_i + reg1_i : 0;
    aluop_o <= aluop_i;
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicout;
        end
        `EXE_RES_SHIFT: begin
            wdata_o <= shiftout;
        end
        `EXE_RES_ARITHMETIC: begin
            wdata_o <= arithout;
        end
        `EXE_RES_BRANCH: begin
            wdata_o <= link_addr_i;
        end
        `EXE_RES_RAM: begin
            wdata_o <= ramout;
        end
        `EXE_RES_MOVE: begin
            wdata_o <= moveres;
        end
        `EXE_RES_NOP: begin
            wdata_o <= reg1_i; // magic, for syscall
        end
        default: begin
            $display("[ex.v] aluop %h not support", aluop_i);
            wdata_o <= 0;
        end
    endcase
end

always @(*) begin
    if (rst == 1'b1) begin
        cp0_reg_write_addr_o <= 0;
        cp0_reg_we_o <= 0;
        cp0_reg_data_o <= 0;
    end else if (aluop_i == `EXE_MTC0_OP) begin
        cp0_reg_write_addr_o <= inst_i[15:11];
        cp0_reg_we_o <= 1;
        cp0_reg_data_o <= reg2_i;
    end else begin
        cp0_reg_write_addr_o <= 0;
        cp0_reg_we_o <= 0;
        cp0_reg_data_o <= 0;
    end
end

endmodule