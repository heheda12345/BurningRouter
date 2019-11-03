module cpu(
    input wire clk,
    input wire rst,

    input wire[31:0] rom_data_i,
    output wire[31:0] rom_addr_o,
    output wire rom_ce_o
);


// if->id
wire [31:0] pc;
wire [31:0] id_pc_i;
wire [31:0] id_inst_i;

// id -> id-ex
wire [7:0] id_aluop_o;
wire [2:0] id_alusel_o;
wire [31:0] id_reg1_o;
wire [31:0] id_reg2_o;
wire id_wreg_o;
wire [4:0] id_wd_o;
wire id_is_in_delayslot;
wire[31:0] id_link_addr;
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

// ex -> ex-mem
wire ex_wreg_o;
wire [4:0] ex_wd_o;
wire [31:0] ex_wdata_o;

// ex-mem -> mem
wire mem_wreg_i;
wire [4:0] mem_wd_i;
wire [31:0] mem_wdata_i;

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

assign rom_addr_o = pc;

pc_reg PC_REG(
    .clk(clk),
    .rst(rst),

    .branch_flag_i(branch_flag),
    .branch_target_addr_i(branch_target_addr),

    .pc(pc),
    .ce(rom_ce_o)
);

if_id IF_ID(
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .if_inst(rom_data_i),
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
    .next_inst_in_delayslot_o(id_next_inst_in_delayslot)
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

    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
    .ex_is_in_delayslot(ex_is_in_delayslot),
    .ex_link_addr(ex_link_addr),
    .is_in_delayslot_o(id_back_is_in_delayslot)
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

    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o)
);

ex_mem EX_MEM(
    .clk(clk),
    .rst(rst),
    
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),

    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i)
);

mem MEM(
    .rst(rst),

    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),

    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o)
);

mem_wb MEM_WB(
    .clk(clk),
    .rst(rst),

    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),

    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

endmodule