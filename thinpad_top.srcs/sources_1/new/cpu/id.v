`include "def_op.v"

module id(
    input wire rst,
    input wire[31:0] pc_i,
    input wire[31:0] inst_i,

    input wire[31:0] reg1_data_i,
    input wire[31:0] reg2_data_i,

    input wire ex_wreg_i,
    input wire[4:0] ex_wd_i,
    input wire[31:0] ex_wdata_i,
    
    input wire mem_wreg_i,
    input wire [4:0] mem_wd_i,
    input wire [31:0] mem_wdata_i,

    input wire is_in_delayslot_i,

    input wire [7:0] pre_aluop,
    input wire pre_reg1_read,
    input wire [4:0] pre_reg1_addr,
    input wire pre_reg2_read,
    input wire [4:0] pre_reg2_addr,
    input wire pre_wreg,
    input wire [4:0] pre_wd,

    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[4:0] reg1_addr_o,
    output reg[4:0] reg2_addr_o,

    output reg[7:0] aluop_o,
    output reg[2:0] alusel_o,
    output reg[31:0] reg1_o, // output imm if not use reg
    output reg[31:0] reg2_o, // output imm if not use reg
    output reg[4:0] wd_o,
    output reg wreg_o,

    output reg branch_flag_o,
    output reg[31:0] branch_target_addr_o,
    output reg is_in_delayslot_o,
    output reg[31:0] link_addr_o,

    output reg[31:0] ram_offset_o,

    output reg next_inst_in_delayslot_o,

    output reg stall_req_o,
    output wire[31:0] inst_o,
    output wire[31:0] excepttype_o,
    output wire[31:0] current_inst_address_o
);

// refer to tsinghua web learning
wire [5:0] ins_op = inst_i[31:26];
wire [4:0] ins_rs = inst_i[25:21];
wire [4:0] ins_rt = inst_i[20:16];
wire [4:0] ins_rd = inst_i[15:11];
wire [4:0] ins_sa = inst_i[10:6];
wire [5:0] ins_func = inst_i[5:0];  
wire [15:0] ins_imm = inst_i[15:0];
wire [25:0] ins_addr = inst_i[25:0];

reg[31:0] imm_reg;
parameter INSTVALID=0;
parameter INSTINVALID=1;
reg instvalid; // 0-valid, 1-invalid. from cpu book, I don't know why

wire[31:0] nxt_pc, nxt_nxt_pc, add_sign_pc, sign_imm, sign_imm18;
assign nxt_pc = pc_i + 32'h00000004;
assign nxt_nxt_pc = pc_i + 32'h00000008;
assign add_sign_pc = nxt_pc + {{14{ins_imm[15]}}, ins_imm, 2'b00};
assign sign_imm = {{16{sign_imm[15]}}, ins_imm};
assign sign_imm18 = {{12{inst_i[17]}}, inst_i[17:0], 2'b00};

assign inst_o = inst_i;

reg is_syscall, is_eret;
assign excepttype_o = {19'b0, is_eret, 3'b0, is_syscall, 8'b0};
assign current_inst_address_o = pc_i;
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
        branch_flag_o <= 0;
        branch_target_addr_o <= 0;
        next_inst_in_delayslot_o <= 0;
        link_addr_o <= 0;
        // is_syscall & is_eret
    end else begin
        reg1_addr_o <= ins_rs;
        reg2_addr_o <= ins_rt;

        branch_flag_o <= 0;
        branch_target_addr_o <= 0;
        next_inst_in_delayslot_o <= 0;
        link_addr_o <= 0;
        
        ram_offset_o <= 0;
        is_syscall <= 0;
        is_eret <= 0;
        instvalid <= INSTINVALID;
        case (ins_op)
            `EXE_SPECIAL: begin
                case (ins_func)
                    `EXE_JR_FUNC: begin
                        wreg_o <= 0;
                        aluop_o <= `EXE_BRANCH_OP;
                        alusel_o <= `EXE_RES_BRANCH;
                        reg1_read_o <= 1;
                        reg2_read_o <= 0;
                        imm_reg <= 0;
                        wd_o <= 0;
                        instvalid <= INSTVALID;

                        link_addr_o <= 0;
                        branch_flag_o <= 1;
                        branch_target_addr_o <= reg1_o;
                        next_inst_in_delayslot_o <= 1;
                    end
                    `EXE_SLL_FUNC: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_SLL_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        reg1_read_o <= 0;
                        reg2_read_o <= 1;
                        imm_reg <= {27'b0, ins_sa};
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    `EXE_SRL_FUNC: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_SRL_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        reg1_read_o <= 0;
                        reg2_read_o <= 1;
                        imm_reg <= {27'b0, ins_sa};
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    `EXE_SRA_FUNC: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_SRA_OP;
                        alusel_o <= `EXE_RES_SHIFT;
                        reg1_read_o <= 0;
                        reg2_read_o <= 1;
                        imm_reg <= {27'b0, ins_sa};
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    `EXE_ADDU_FUNC: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_ADDU_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        reg1_read_o <= 1;
                        reg2_read_o <= 1;
                        imm_reg <= 0;
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    `EXE_AND_FUNC: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_AND_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                        reg1_read_o <= 1;
                        reg2_read_o <= 1;
                        imm_reg <= 0;
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    `EXE_OR_FUNC: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_OR_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                        reg1_read_o <= 1;
                        reg2_read_o <= 1;
                        imm_reg <= 0;
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    `EXE_XOR_FUNC: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_XOR_OP;
                        alusel_o <= `EXE_RES_LOGIC;
                        reg1_read_o <= 1;
                        reg2_read_o <= 1;
                        imm_reg <= 0;
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    `EXE_SYSCALL_FUNC: begin
                        wreg_o <= 0;
                        aluop_o <= `EXE_SYSCALL_OP;
                        alusel_o <= `EXE_RES_NOP;
                        reg1_read_o <= 0;
                        reg2_read_o <= 0;
                        imm_reg <= {12'b0, inst_i[25:6]};
                        wd_o <= 0;
                        instvalid <= INSTVALID;
                        is_syscall <= 1;
                    end
                    `EXE_MOVZ_FUNC: begin
                        if (reg2_o == 32'h00000000) begin
                            wreg_o <= 1;
                        end else begin
                            wreg_o <= 0;
                        end
                        aluop_o <= `EXE_MOVZ_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        reg1_read_o <= 1;
                        reg2_read_o <= 1;
                        imm_reg <= 0;
                        wd_o <= ins_rd;
                        instvalid <= INSTVALID;
                    end
                    default: begin
                        $display("[id.v] func %h not support", ins_func);
                    end
                endcase
            end
            `EXE_JUMP: begin
                wreg_o <= 0;
                aluop_o <= `EXE_BRANCH_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 0;
                reg2_read_o <= 0;
                imm_reg <= 0;
                wd_o <= 0;
                instvalid <= INSTINVALID;

                link_addr_o <= 0;
                branch_flag_o <= 1;
                branch_target_addr_o <= {nxt_pc[31:28], ins_addr, 2'b00};;
                next_inst_in_delayslot_o <= 1;
            end

            `EXE_JAL: begin
                wreg_o <= 1;
                aluop_o <= `EXE_BRANCH_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 0;
                reg2_read_o <= 0;
                imm_reg <= 0;
                wd_o <= 5'b11111;
                instvalid <= INSTINVALID;

                link_addr_o <= nxt_nxt_pc;
                branch_flag_o <= 1;
                branch_target_addr_o <= {nxt_pc[31:28], ins_addr, 2'b00};;
                next_inst_in_delayslot_o <= 1;
            end

            `EXE_BEQ: begin
                wreg_o <= 0;
                aluop_o <= `EXE_BRANCH_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1;
                reg2_read_o <= 1;
                imm_reg <= 0;
                wd_o <= 0;
                instvalid <= INSTINVALID;

                link_addr_o <= 0;
                if (reg1_o == reg2_o) begin
                    branch_flag_o <= 1;
                    branch_target_addr_o <= add_sign_pc;
                    next_inst_in_delayslot_o <= 1;
                end
            end

            `EXE_BNE: begin
                wreg_o <= 0;
                aluop_o <= `EXE_BRANCH_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1;
                reg2_read_o <= 1;
                imm_reg <= 0;
                wd_o <= 0;
                instvalid <= INSTINVALID;

                link_addr_o <= 0;
                if (reg1_o != reg2_o) begin
                    branch_flag_o <= 1;
                    branch_target_addr_o <= add_sign_pc;
                    next_inst_in_delayslot_o <= 1;
                end
            end

            `EXE_BGTZ: begin
                wreg_o <= 0;
                aluop_o <= `EXE_BRANCH_OP;
                alusel_o <= `EXE_RES_BRANCH;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= 0;
                wd_o <= 0;
                instvalid <= INSTINVALID;

                link_addr_o <= 0;
                if (reg1_o[31] == 1'b0 && reg1_o != 32'h00000000) begin
                    branch_flag_o <= 1;
                    branch_target_addr_o <= add_sign_pc;
                    next_inst_in_delayslot_o <= 1;
                end
            end

            `EXE_ADDIU: begin
                wreg_o <= 1;
                aluop_o <= `EXE_ADDU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= {{16{ins_imm[15]}}, ins_imm};
                wd_o <= ins_rt;
                instvalid <= INSTVALID;
            end
            `EXE_ANDI: begin
                wreg_o <= 1;
                aluop_o <= `EXE_AND_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= {16'h0, ins_imm};
                wd_o <= ins_rt;
                instvalid <= INSTVALID;
            end
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
            `EXE_XORI: begin
                wreg_o <= 1;
                aluop_o <= `EXE_XOR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= {16'h0, ins_imm};
                wd_o <= ins_rt;
                instvalid <= INSTVALID;
            end
            `EXE_LUI: begin
                wreg_o <= 1;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= 0;
                reg2_read_o <= 0;
                imm_reg <= {ins_imm, 16'h0};
                wd_o <= ins_rt;
                instvalid <= INSTVALID;
            end
            `EXE_LB: begin
                wreg_o <= 1;
                aluop_o <= `EXE_LB_OP;
                alusel_o <= `EXE_RES_RAM;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= sign_imm;
                wd_o <= ins_rt;
                instvalid <= INSTVALID;
                
                ram_offset_o <= sign_imm;
            end
            `EXE_LH: begin
                wreg_o <= 1;
                aluop_o <= `EXE_LH_OP;
                alusel_o <= `EXE_RES_RAM;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= sign_imm;
                wd_o <= ins_rt;
                instvalid <= INSTVALID;

                ram_offset_o <= sign_imm;
            end
            `EXE_LW: begin
                wreg_o <= 1;
                aluop_o <= `EXE_LW_OP;
                alusel_o <= `EXE_RES_RAM;
                reg1_read_o <= 1;
                reg2_read_o <= 0;
                imm_reg <= sign_imm;
                wd_o <= ins_rt;
                instvalid <= INSTVALID;
                
                ram_offset_o <= sign_imm;
            end
            `EXE_LWPC: begin
                wreg_o <= 1;
                aluop_o <= `EXE_LWPC_OP;
                alusel_o <= `EXE_RES_RAM;
                reg1_read_o <= 0;
                reg2_read_o <= 0;
                imm_reg <= sign_imm18;
                wd_o <= ins_rs;
                instvalid <= INSTVALID;

                ram_offset_o <= sign_imm18;
                $display("lwpc %h %h", inst_i, sign_imm18);
            end
            `EXE_SB: begin
                wreg_o <= 0;
                aluop_o <= `EXE_SB_OP;
                alusel_o <= `EXE_RES_RAM;
                reg1_read_o <= 1;
                reg2_read_o <= 1;
                imm_reg <= sign_imm;
                wd_o <= 0;
                instvalid <= INSTVALID;

                ram_offset_o <= sign_imm;
            end
            `EXE_SW: begin
                wreg_o <= 0;
                    aluop_o <= `EXE_SW_OP;
                alusel_o <= `EXE_RES_RAM;
                reg1_read_o <= 1;
                reg2_read_o <= 1;
                imm_reg <= sign_imm;
                wd_o <= 0;
                instvalid <= INSTVALID;

                ram_offset_o <= sign_imm;
            end
            `EXE_COP: begin
                case (ins_rs)
                    `EXE_MF: begin
                        wreg_o <= 1;
                        aluop_o <= `EXE_MFC0_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        reg1_read_o <= 0;
                        reg2_read_o <= 0;
                        imm_reg <= 0;
                        wd_o <= ins_rt;
                        instvalid <= INSTVALID;
                    end
                    `EXE_MT: begin
                        wreg_o <= 0;
                        aluop_o <= `EXE_MTC0_OP;
                        alusel_o <= `EXE_RES_MOVE;
                        reg1_read_o <= 0;
                        reg2_read_o <= 1;
                        imm_reg <= 0;
                        wd_o <= 0;
                        instvalid <= INSTVALID;
                    end
                    `EXE_ERET: begin
                        if (inst_i != `EXE_ERET_32) begin
                            $display("[id.v] invalid ere %h", inst_i);
                        end else begin
                            wreg_o <= 0;
                            aluop_o <= `EXE_ERET_OP;
                            alusel_o <= `EXE_RES_NOP;
                            reg1_read_o <= 0;
                            reg2_read_o <= 0;
                            imm_reg <= 0;
                            wd_o <= 0;
                            instvalid <= INSTVALID;
                            is_eret <= 1;
                        end
                    end
                    default: begin
                        $display("[id.v] cop0 %h not support", ins_rs);
                    end
                endcase
            end
            default: begin
                $display("[id.v] op %h not support", ins_op);
            end
        endcase
    end
end

// reg1_o, use the newest value
always @(*) begin
    if (rst == 1'b1) begin
        reg1_o <= 0;
    end else if (reg1_read_o == 1'b1) begin
        if (ex_wreg_i == 1'b1 && ex_wd_i == reg1_addr_o) begin
            reg1_o <= ex_wdata_i;
        end else if (mem_wreg_i == 1'b1 && mem_wd_i == reg1_addr_o) begin
            reg1_o <= mem_wdata_i;
        end else begin
            reg1_o <= reg1_data_i;
        end
    end else begin
        reg1_o <= imm_reg;
    end
end

// reg2, use the newest value
always @(*) begin
    if (rst == 1'b1) begin
        reg2_o <= 0;
    end else if (reg2_read_o == 1'b1) begin
        if (ex_wreg_i == 1'b1 && ex_wd_i == reg2_addr_o) begin
            reg2_o <= ex_wdata_i;
        end else if (mem_wreg_i == 1'b1 && mem_wd_i == reg2_addr_o) begin
            reg2_o <= mem_wdata_i;
        end else begin
            reg2_o <= reg2_data_i;
        end
    end else begin
        reg2_o <= imm_reg;
    end
end

wire stall_req_reg1, stall_req_reg2, pre_is_load;
assign pre_is_load = (pre_aluop == `EXE_LB_OP || pre_aluop == `EXE_LW_OP || pre_aluop == `EXE_LH_OP || pre_aluop == `EXE_LWPC_OP);
assign stall_req_reg1 = reg1_read_o == 1'b1 && pre_wd == reg1_addr_o;
assign stall_req_reg2 = reg2_read_o == 1'b1 && pre_wd == reg2_addr_o;
always @(*) begin
    if (rst == 1'b1) begin
        stall_req_o <= 0;
    end else begin
        stall_req_o <= pre_is_load == 1'b1 && pre_wreg == 1'b1 && pre_wd != 5'b00000 && (stall_req_reg1 || stall_req_reg2);
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        is_in_delayslot_o <= 0;
    end else begin
        is_in_delayslot_o <= is_in_delayslot_i;
    end
end
endmodule
