module cpu(
    input wire clk,
    input wire rst,

    input wire[31:0] pc_data_i,
    output wire[19:0] pc_addr_o,

    input wire[31:0] ram_data_i,
    output wire[19:0] ram_addr_o,
    output wire[3:0] ram_be_o,
    output wire ram_we_o,
    output wire ram_oe_o
);


// if->id
wire [31:0] pc;
wire [31:0] id_pc_i;
wire [31:0] id_inst_i;
wire if_pc_ce_o;

// id -> id-ex
wire [7:0] id_aluop_o;
wire [2:0] id_alusel_o;
wire [31:0] id_reg1_o;
wire [31:0] id_reg2_o;
wire id_wreg_o;
wire [4:0] id_wd_o;
wire id_is_in_delayslot;
wire[31:0] id_link_addr;
wire [31:0] id_ram_offset;
wire id_next_inst_in_delayslot;

// id-ex -> ex
wire [7:0] ex_aluop_i;
wire [2:0] ex_alusel_i;
wire [31:0] ex_reg1_i;
wire [31:0] ex_reg2_i;
wire ex_wreg_i;
wire [4:0] ex_wd_i;
wire ex_is_in_delayslot;
wire [31:0] ex_link_addr;
wire [31:0] ex_ram_offset;

// ex -> ex-mem
wire ex_wreg_o;
wire [4:0] ex_wd_o;
wire [31:0] ex_wdata_o;
wire [7:0] ex_aluop_o;
wire [31:0] ex_ram_addr_o;

// ex-mem -> mem
wire mem_wreg_i;
wire [4:0] mem_wd_i;
wire [31:0] mem_wdata_i;
wire [7:0] mem_alu_op_i;
wire [31:0] mem_ram_addr_i;

// mem -> mem-wb
wire mem_wreg_o;
wire [4:0] mem_wd_o;
wire [31:0] mem_wdata_o;

// mem-wb -> writeback
wire wb_wreg_i;
wire [4:0] wb_wd_i;
wire [31:0] wb_wdata_i;

// id -> regfile
wire reg1_read;
wire reg2_read;
wire [31:0] reg1_data;
wire [31:0] reg2_data;
wire [4:0] reg1_addr;
wire [4:0] reg2_addr;

// id -> pc
wire [31:0] branch_target_addr;
wire branch_flag;

// id-ex -> id
wire id_back_is_in_delayslot;
wire [7:0] id_pre_aluop_oi;
wire id_reg1_read_oi;
wire [4:0] id_reg1_addr_oi;
wire id_reg2_read_oi;
wire [4:0] id_reg2_addr_oi;
wire id_wreg_oi;
wire [4:0] id_wd_oi;


assign pc_addr_o = pc[21:2];

// ctrl with other
wire id_stall_req_o;
wire pc_stall_i;
wire if_stall_i;
wire id_stall_i;
wire ex_stall_i;
wire mem_stall_i;
wire wb_stall_i;

// mem <-> ram
wire [31:0] mem_ram_addr_o;
assign ram_addr_o = mem_ram_addr_o[21:2];
wire mem_ram_we_o;
assign ram_we_o = clk & mem_ram_we_o;

pc_reg PC_REG(
    .clk(clk),
    .rst(rst),
    .ce(if_pc_ce_o),

    .branch_flag_i(branch_flag),
    .branch_target_addr_i(branch_target_addr),

    .pc(pc),

    .pc_stall(pc_stall_i)
);

if_id IF_ID(
    .clk(clk),
    .rst(rst),
    .if_ce(if_pc_ce_o),
    .if_pc(pc),
    .if_inst(pc_data_i),

    .id_stall(id_stall_i),

    .id_pc(id_pc_i),
    .id_inst(id_inst_i)      	
);

id ID(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),

    .ex_wreg_i(ex_wreg_o),
    .ex_wd_i(ex_wd_o),
    .ex_wdata_i(ex_wdata_o),

    .mem_wreg_i(mem_wreg_o),
    .mem_wd_i(mem_wd_o),
    .mem_wdata_i(mem_wdata_o),

    .is_in_delayslot_i(id_back_is_in_delayslot),

    .pre_aluop(id_pre_aluop_oi),
    .pre_reg1_read(id_reg1_read_oi),
    .pre_reg1_addr(id_reg1_addr_oi),
    .pre_reg2_read(id_reg2_read_oi),
    .pre_reg2_addr(id_reg2_addr_oi),
    .pre_wreg(id_wreg_oi),
    .pre_wd(id_wd_oi),

    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),

    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),
    
    .branch_target_addr_o(branch_target_addr),
    .branch_flag_o(branch_flag),
    .is_in_delayslot_o(id_is_in_delayslot),
    .link_addr_o(id_link_addr),
    .next_inst_in_delayslot_o(id_next_inst_in_delayslot),
    .ram_offset_o(id_ram_offset),

    .stall_req_o(id_stall_req_o)
);

regfile REGFILE(
    .clk (clk),
    .rst (rst),
    .we	(wb_wreg_i),
    .waddr (wb_wd_i),
    .wdata (wb_wdata_i),
    .re1 (reg1_read),
    .raddr1 (reg1_addr),
    .rdata1 (reg1_data),
    .re2 (reg2_read),
    .raddr2 (reg2_addr),
    .rdata2 (reg2_data)
);

id_ex ID_EX(
    .clk(clk),
    .rst(rst),
    
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
    .id_is_in_delayslot(id_is_in_delayslot),
    .id_link_addr(id_link_addr),
    .next_inst_in_delayslot_i(id_next_inst_in_delayslot),
    .id_ram_offset(id_ram_offset),

    .id_stall(id_stall_i),

    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
    .ex_is_in_delayslot(ex_is_in_delayslot),
    .ex_link_addr(ex_link_addr),
    .is_in_delayslot_o(id_back_is_in_delayslot),
    .ex_ram_offset(ex_ram_offset),

    .cur_aluop(id_aluop_o),
    .cur_reg1_read(reg1_read),
    .cur_reg1_addr(reg1_addr),
    .cur_reg2_read(reg2_read),
    .cur_reg2_addr(reg2_addr),
    .cur_wd(id_wd_o),
    .cur_wreg(id_wreg_o),

    .pre_aluop(id_pre_aluop_oi),
    .pre_reg1_read(id_reg1_read_oi),
    .pre_reg1_addr(id_reg1_addr_oi),
    .pre_reg2_read(id_reg2_read_oi),
    .pre_reg2_addr(id_reg2_addr_oi),
    .pre_wd(id_wd_oi),
    .pre_wreg(id_wreg_oi)
);		

ex EX(
    .rst(rst),

    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    .link_addr_i(ex_link_addr),
    .is_in_delayslot(ex_is_in_delayslot),
    .ram_offset_i(ex_ram_offset),

    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .aluop_o(ex_aluop_o),
    .ram_addr_o(ex_ram_addr_o)
);

ex_mem EX_MEM(
    .clk(clk),
    .rst(rst),
    
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_alu_op(ex_aluop_o),
    .ex_ram_addr(ex_ram_addr_o),

    .mem_stall(mem_stall_i),

    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_alu_op(mem_alu_op_i),
    .mem_ram_addr(mem_ram_addr_i)
);

mem MEM(
    .rst(rst),

    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .alu_op_i(mem_alu_op_i),
    .ram_addr_i(mem_ram_addr_i),

    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),

    .ram_data_i(ram_data_i),
    .ram_addr_o(mem_ram_addr_o),
    .ram_be_o(ram_be_o),
    .ram_we_o(mem_ram_we_o),
    .ram_oe_o(ram_oe_o)
);

mem_wb MEM_WB(
    .clk(clk),
    .rst(rst),

    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),

    .wb_stall(wb_stall_i),

    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

ctrl CTRL(
    .rst(rst),
    
    .id_req(id_stall_req_o),


    .pc_stall(pc_stall_i),
    .if_stall(if_stall_i),
    .id_stall(id_stall_i),
    .ex_stall(ex_stall_i),
    .mem_stall(mem_stall_i),
    .wb_stall(wb_stall_i)
);

endmodule