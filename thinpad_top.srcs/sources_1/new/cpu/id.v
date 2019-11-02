`include "def_op.v"

module id(
    input wire rst,
    input wire[31:0] pc_i,
    input wire[31:0] inst_i,

    input wire[31:0] reg1_data_i,
    input wire[31:0] reg2_data_i,

    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[4:0] reg1_addr_o,
    output reg[4:0] reg2_addr_o,

    output reg[7:0] aluop_o,
    output reg[2:0] alusel_o,
    output reg[31:0] reg1_o, // output imm if not use reg
    output reg[31:0] reg2_o, // output imm if not use reg
    output reg[4:0] wd_o,
    output reg wreg_o
);

// refer to tsinghua web learning
wire [5:0] ins_op = inst_i[31:26];
wire [4:0] ins_rs = inst_i[25:21];
wire [4:0] ins_rt = inst_i[20:16];
wire [4:0] ins_rd = inst_i[15:11];
wire [4:0] ins_sa = inst_i[10:6];
wire [5:0] ins_func = inst_i[5:0];  
wire [15:0] ins_imm = inst_i[15:0];
wire [25:0] ins_addr = inst_i[26:0];

reg[31:0] imm_reg;
parameter INSTVALID=0;
parameter INSTINVALID=1;
reg instvalid; // 0-valid, 1-invalid. from cpu book, I don't know why


// translate
always @(*) begin
    if (rst == 1'b1) begin
        aluop_o <= 0;
        alusel_o <= 0;
        wd_o <= 0;
        wreg_o <= 0;
        instvalid <= INSTVALID;
        reg1_read_o <= 0;
        reg2_read_o <= 0;
        reg1_addr_o <= 0;
        reg2_addr_o <= 0;
        imm_reg <= 0;
    end else begin
        aluop_o <= 0;
        alusel_o <= 0;
        wd_o <= ins_rd;
        wreg_o <= 0;
        instvalid <= INSTINVALID;
        reg1_read_o <= 0;
        reg2_read_o <= 0;
        reg1_addr_o <= ins_rs;
        reg2_addr_o <= ins_rt;
        imm_reg <= 0;
        case (ins_op)
            `EXE_ORI: begin
                wreg_o <= 1;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= {16'h0, ins_imm};
                wd_o <= ins_rt;
                instvalid <= INSTVALID;
            end
            default: begin
                $display("[id.v] op %h not support", ins_op);
            end
        endcase
    end
end

// reg1_o
always @(*) begin
    if (rst == 1'b1) begin
        reg1_o <= 0;
    end else if (reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;
    end else begin
        reg1_o <= imm_reg;
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        reg2_o <= 0;
    end else if (reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;
    end else begin
        reg2_o <= imm_reg;
    end
end

endmodule