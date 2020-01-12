module id_ex (
    input wire clk,
    input wire rst,
    input wire flush,

    input wire [7:0] id_aluop,
    input wire [2:0] id_alusel,
    input wire [31:0] id_reg1,
    input wire [31:0] id_reg2,
    input wire [4:0] id_wd,
    input wire id_wreg,
    input wire id_is_in_delayslot,
    input wire [31:0] id_link_addr,
    input wire [31:0] id_ram_offset,
    input wire [31:0] id_inst,
    input wire [31:0] id_current_inst_address,
    input wire [31:0] id_excepttype,

    input wire id_stall,
    input wire ex_stall,

    output reg [7:0] ex_aluop,
    output reg [2:0] ex_alusel,
    output reg [31:0] ex_reg1,
    output reg [31:0] ex_reg2,
    output reg [4:0] ex_wd,
    output reg ex_wreg,
    output reg ex_is_in_delayslot,
    output reg [31:0] ex_link_addr,
    output reg [31:0] ex_ram_offset,
    output reg [31:0] ex_inst,
    output reg [31:0] ex_current_inst_address,
    output reg [31:0] ex_excepttype,
    
    input wire next_inst_in_delayslot_i,
    output reg is_in_delayslot_o, // id's input

    input wire [7:0]cur_aluop,
    input wire cur_reg1_read,
    input wire [4:0] cur_reg1_addr,
    input wire cur_reg2_read,
    input wire [4:0] cur_reg2_addr,
    input wire cur_wreg,
    input wire [4:0] cur_wd,

    output reg [7:0]pre_aluop,
    output reg pre_reg1_read,
    output reg [4:0] pre_reg1_addr,
    output reg pre_reg2_read,
    output reg [4:0] pre_reg2_addr,
    output reg pre_wreg,
    output reg [4:0] pre_wd
);

always @(posedge clk) begin
    if (rst == 1'b1) begin
        ex_aluop <= 0;
        ex_alusel <=0;
        ex_reg1 <= 0;
        ex_reg2 <= 0;
        ex_wd <= 0;
        ex_wreg <= 0;
        ex_is_in_delayslot <= 0;
        ex_link_addr <= 0;
        ex_ram_offset <= 0;
        ex_inst <= 0;
        ex_excepttype <= 0;
        ex_current_inst_address <= 0;
        is_in_delayslot_o <= 0;
        pre_aluop <= 0;
        pre_reg1_addr <= 0;
        pre_reg1_read <= 0;
        pre_reg2_addr <= 0;
        pre_reg2_read <= 0;
        pre_wreg <= 0;
        pre_wd <= 0;
    end else if (flush == 1'b1) begin
        ex_aluop <= 0;
        ex_alusel <=0;
        ex_reg1 <= 0;
        ex_reg2 <= 0;
        ex_wd <= 0;
        ex_wreg <= 0;
        ex_is_in_delayslot <= 0;
        ex_link_addr <= 0;
        ex_ram_offset <= 0;
        ex_inst <= 0;
        ex_excepttype <= 0;
        ex_current_inst_address <= 0;
        is_in_delayslot_o <= 0;
        // not clear pre
    end else if (id_stall == 1'b1 && ex_stall == 1'b0) begin
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= 0;
        ex_reg2 <= 0;
        ex_wd <= 0;
        ex_wreg <= 0;
        ex_is_in_delayslot <= 0;
        ex_link_addr <= 0;
        ex_ram_offset <= 0;
        ex_inst <= 0;
        ex_excepttype <= 0;
        ex_current_inst_address <= 0;
        is_in_delayslot_o <= 0;
        pre_aluop <= 0;
        pre_reg1_addr <= 0;
        pre_reg1_read <= 0;
        pre_reg2_addr <= 0;
        pre_reg2_read <= 0;
        pre_wreg <= 0;
        pre_wd <= 0;
    end else if (id_stall == 1'b0) begin
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ex_is_in_delayslot <= id_is_in_delayslot;
        ex_link_addr <= id_link_addr;
        ex_ram_offset <= id_ram_offset;
        ex_inst <= id_inst;
        ex_excepttype <= id_excepttype;
        ex_current_inst_address <= id_current_inst_address;
        is_in_delayslot_o <= next_inst_in_delayslot_i;
        pre_aluop <= cur_aluop;
        pre_reg1_addr <= cur_reg1_addr;
        pre_reg1_read <= cur_reg1_read;
        pre_reg2_addr <= cur_reg2_addr;
        pre_reg2_read <= cur_reg2_read;
        pre_wreg <= cur_wreg;
        pre_wd <= cur_wd;
    end
end

endmodule