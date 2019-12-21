module cpu(
    input wire clk,
    input wire rst,

    input wire[31:0] pc_data_i,
    output wire[31:0] pc_addr_o,
    input wire if_stall_req, 
    input wire [5:0] int_i,

    input wire[31:0] ram_data_i,
    output wire[31:0] ram_data_o,
    output wire[31:0] ram_addr_o,
    output wire[3:0] ram_be_o,
    output wire ram_we_o,
    output wire ram_oe_o,
    input wire mem_stall_req,
    output wire[15:0] leds
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
wire [31:0] id_inst_o;
wire id_is_in_delayslot;
wire[31:0] id_link_addr;
wire [31:0] id_ram_offset;
wire id_next_inst_in_delayslot;
wire[31:0] id_excepttype_o;
wire[31:0] id_current_inst_address_o;

// id-ex -> ex
wire [7:0] ex_aluop_i;
wire [2:0] ex_alusel_i;
wire [31:0] ex_reg1_i;
wire [31:0] ex_reg2_i;
wire ex_wreg_i;
wire [4:0] ex_wd_i;
wire [31:0] ex_inst_i;
wire ex_is_in_delayslot;
wire [31:0] ex_link_addr;
wire [31:0] ex_ram_offset;
wire[31:0] ex_excepttype_i;	
wire[31:0] ex_current_inst_address_i;

// ex -> ex-mem
wire ex_wreg_o;
wire [4:0] ex_wd_o;
wire [31:0] ex_wdata_o;
wire [7:0] ex_aluop_o;
wire [31:0] ex_ram_addr_o;
wire ex_cp0_reg_we_o;
wire [4:0] ex_cp0_reg_write_addr_o;
wire [31:0] ex_cp0_reg_data_o;
wire[31:0] ex_excepttype_o;
wire[31:0] ex_current_inst_address_o;
wire ex_is_in_delayslot_o;

// ex-mem -> mem
wire mem_wreg_i;
wire [4:0] mem_wd_i;
wire [31:0] mem_wdata_i;
wire [7:0] mem_alu_op_i;
wire [31:0] mem_ram_addr_i;
wire mem_cp0_reg_we_i;
wire[4:0] mem_cp0_reg_write_addr_i;
wire[31:0] mem_cp0_reg_data_i;
wire[31:0] mem_excepttype_i;
wire mem_is_in_delayslot_i;
wire[31:0] mem_current_inst_address_i;

// mem -> mem-wb
wire mem_wreg_o;
wire [4:0] mem_wd_o;
wire [31:0] mem_wdata_o;
wire mem_cp0_reg_we_o;
wire [4:0] mem_cp0_reg_write_addr_o;
wire [31:0] mem_cp0_reg_data_o;
wire[31:0] mem_excepttype_o;
wire mem_is_in_delayslot_o;
wire[31:0] mem_current_inst_address_o;
wire mem_not_align_o;

// mem-wb -> writeback
(*mark_debug="true"*)wire wb_wreg_i;
(*mark_debug="true"*)wire [4:0] wb_wd_i;
(*mark_debug="true"*)wire [31:0] wb_wdata_i;
wire[31:0] wb_excepttype_i;
wire wb_is_in_delayslot_i;
wire[31:0] wb_current_inst_address_i;

// id -> regfile
(*mark_debug="true"*)wire reg1_read;
(*mark_debug="true"*)wire reg2_read;
(*mark_debug="true"*)wire [31:0] reg1_data;
(*mark_debug="true"*)wire [31:0] reg2_data;
(*mark_debug="true"*)wire [4:0] reg1_addr;
(*mark_debug="true"*)wire [4:0] reg2_addr;

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


assign pc_addr_o = pc;//[21:2];

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
assign ram_addr_o = mem_ram_addr_o;//[21:2];
wire mem_ram_we_o;
assign ram_we_o = mem_ram_we_o;


// cp0 <-> other
wire wb_cp0_reg_we_i;
wire [4:0] wb_cp0_reg_write_addr_i;
wire [4:0] cp0_raddr_i;
wire [31:0] wb_cp0_reg_data_i;

wire [31:0] cp0_data_o;
wire[31:0]	cp0_status;
wire[31:0]	cp0_cause;
wire[31:0]	cp0_epc;
wire[31:0]	cp0_ebase; 

// for exception
wire flush;
wire[31:0] new_pc;
wire[31:0] latest_epc;
wire[31:0] mem_syscall_bias;

wire not_align;

assign leds[15:1] = 15'b0000000000000000;
assign leds[0] = not_align;

pc_reg PC_REG(
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .pc_stall(pc_stall_i),

    .branch_flag_i(branch_flag),
    .branch_target_addr_i(branch_target_addr),

    .pc(pc),
    .new_pc(new_pc),
    .ce(if_pc_ce_o)
);

if_id IF_ID(
    .clk(clk),
    .rst(rst),
    .flush(flush),

    .if_ce(if_pc_ce_o),
    .if_pc(pc),
    .if_inst(pc_data_i),

    .if_stall(if_stall_i),
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

    .stall_req_o(id_stall_req_o),
    .inst_o(id_inst_o),
    .excepttype_o(id_excepttype_o),
    .current_inst_address_o(id_current_inst_address_o)
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
    .flush(flush),
    
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
    .id_inst(id_inst_o),
	.id_current_inst_address(id_current_inst_address_o),
    .id_excepttype(id_excepttype_o),

    .id_stall(id_stall_i),
    .ex_stall(ex_stall_i),

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
    .ex_inst(ex_inst_i),
	.ex_current_inst_address(ex_current_inst_address_i),
    .ex_excepttype(ex_excepttype_i),

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
    .inst_i(ex_inst_i),
    .cp0_reg_data_i(cp0_data_o),
    .mem_cp0_reg_we(mem_cp0_reg_we_o),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
	.mem_cp0_reg_data(mem_cp0_reg_data_o),
  	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i),
    .excepttype_i(ex_excepttype_i),
	.current_inst_address_i(ex_current_inst_address_i),

    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .aluop_o(ex_aluop_o),
    .ram_addr_o(ex_ram_addr_o),
    .cp0_reg_read_addr_o(cp0_raddr_i),
    .cp0_reg_we_o(ex_cp0_reg_we_o),
	.cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
	.cp0_reg_data_o(ex_cp0_reg_data_o),
    .excepttype_o(ex_excepttype_o),
	.is_in_delayslot_o(ex_is_in_delayslot_o),
	.current_inst_address_o(ex_current_inst_address_o)
);

ex_mem EX_MEM(
    .clk(clk),
    .rst(rst),
    .flush(flush),
    
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_alu_op(ex_aluop_o),
    .ex_ram_addr(ex_ram_addr_o),
    .ex_cp0_reg_we(ex_cp0_reg_we_o),
	.ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
	.ex_cp0_reg_data(ex_cp0_reg_data_o),
    .ex_excepttype(ex_excepttype_o),
	.ex_is_in_delayslot(ex_is_in_delayslot_o),
	.ex_current_inst_address(ex_current_inst_address_o),

    .ex_stall(ex_stall_i),
    .mem_stall(mem_stall_i),

    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_alu_op(mem_alu_op_i),
    .mem_ram_addr(mem_ram_addr_i),
    .mem_cp0_reg_we(mem_cp0_reg_we_i),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
	.mem_cp0_reg_data(mem_cp0_reg_data_i),
    .mem_excepttype(mem_excepttype_i),
  	.mem_is_in_delayslot(mem_is_in_delayslot_i),
	.mem_current_inst_address(mem_current_inst_address_i)
);

mem MEM(
    .rst(rst),

    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .alu_op_i(mem_alu_op_i),
    .ram_addr_i(mem_ram_addr_i),
    .cp0_reg_we_i(mem_cp0_reg_we_i),
	.cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
	.cp0_reg_data_i(mem_cp0_reg_data_i),
    .excepttype_i(mem_excepttype_i),
	.is_in_delay_slot_i(mem_is_in_delayslot_i),
	.current_inst_address_i(mem_current_inst_address_i),
	.cp0_status_i(cp0_status),
	.cp0_cause_i(cp0_cause),
	.cp0_epc_i(cp0_epc),
	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i), 

    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),

    .ram_data_i(ram_data_i),
    .ram_data_o(ram_data_o),
    .ram_addr_o(mem_ram_addr_o),
    .ram_be_o(ram_be_o),
    .ram_we_o(mem_ram_we_o),
    .ram_oe_o(ram_oe_o),
    .cp0_reg_we_o(mem_cp0_reg_we_o),
	.cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
	.cp0_reg_data_o(mem_cp0_reg_data_o),
    .excepttype_o(mem_excepttype_o),
	.cp0_epc_o(latest_epc),
	.is_in_delay_slot_o(mem_is_in_delayslot_o),
	.current_inst_address_o(mem_current_inst_address_o),
    .syscall_bias(mem_syscall_bias),
    .not_align(mem_not_align_o)
);

mem_wb MEM_WB(
    .clk(clk),
    .rst(rst),
    .flush(flush),

    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    .mem_cp0_reg_we(mem_cp0_reg_we_o),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
	.mem_cp0_reg_data(mem_cp0_reg_data_o),
    .mem_not_align_in(mem_not_align_o),

    .mem_stall(mem_stall_i),
    .wb_stall(wb_stall_i),

    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i),
    .wb_cp0_reg_we(wb_cp0_reg_we_i),
    .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_data(wb_cp0_reg_data_i),
    .not_align_out(not_align)
);

ctrl CTRL(
    .rst(rst),
    
    .id_req(id_stall_req_o),
    .mem_req(mem_stall_req),
    .if_req(if_stall_req),
    .syscall_bias(mem_syscall_bias),

    .pc_stall(pc_stall_i),
    .if_stall(if_stall_i),
    .id_stall(id_stall_i),
    .ex_stall(ex_stall_i),
    .mem_stall(mem_stall_i),
    .wb_stall(wb_stall_i),

    .excepttype_i(mem_excepttype_o),
    .cp0_epc_i(latest_epc),
    .cp0_ebase_i(cp0_ebase),
    .new_pc(new_pc),
	.flush(flush)
);

cp0_reg CP0_REG(
    .clk(clk),
    .rst(rst),
    
    .we_i(wb_cp0_reg_we_i),
	.waddr_i(wb_cp0_reg_write_addr_i),
	.raddr_i(cp0_raddr_i),
	.data_i(wb_cp0_reg_data_i),
	.int_i(int_i),
    .excepttype_i(mem_excepttype_o),
	.current_inst_addr_i(mem_current_inst_address_o),
	.is_in_delay_slot_i(mem_is_in_delayslot_o),

	.data_o(cp0_data_o),
    .status_o(cp0_status),
    .cause_o(cp0_cause),
    .ebase_o(cp0_ebase),
    .epc_o(cp0_epc)
);

endmodule
