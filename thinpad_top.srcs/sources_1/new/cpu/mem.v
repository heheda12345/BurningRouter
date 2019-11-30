`include "def_op.v"

module mem(
    input wire rst,

    input wire[4:0] wd_i,
    input wire wreg_i,
    input wire[31:0] wdata_i,
    input wire[7:0] alu_op_i,
    input wire[31:0] ram_addr_i,
    input wire cp0_reg_we_i,
    input wire[4:0] cp0_reg_write_addr_i,
    input wire[31:0] cp0_reg_data_i,
    input wire[31:0] excepttype_i,
    input wire is_in_delay_slot_i,
    input wire[31:0] current_inst_address_i,
    input wire[31:0] cp0_status_i,
    input wire[31:0] cp0_cause_i,
    input wire[31:0] cp0_epc_i,
    input wire wb_cp0_reg_we,
    input wire[4:0] wb_cp0_reg_write_addr,
    input wire[31:0] wb_cp0_reg_data,

    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] wdata_o,

    // with ram
    input wire[31:0] ram_data_i,
    output wire[31:0] ram_data_o, 
    output reg[31:0] ram_addr_o,
    output reg[3:0] ram_be_o, // byte enable
    output wire ram_we_o,        // write enable
    output reg ram_oe_o,        // read enable
    output reg cp0_reg_we_o,
    output reg[4:0] cp0_reg_write_addr_o,
    output reg[31:0] cp0_reg_data_o,
    output reg[31:0] excepttype_o,
    output wire[31:0] cp0_epc_o,
    output wire is_in_delay_slot_o,
    output wire[31:0] current_inst_address_o,
    output reg[31:0] syscall_bias
);

reg[31:0] data_to_write;
// assign ram_data_i = ram_oe_o ? 32'hzzzzzzzz : data_to_write;
assign ram_data_o = data_to_write;
reg ram_we;
assign ram_we_o = ram_we & (~(|excepttype_o));

reg[31:0] cp0_status;
reg[31:0] cp0_cause;
reg[31:0] cp0_epc;
assign is_in_delay_slot_o = is_in_delay_slot_i;
assign current_inst_address_o = current_inst_address_i;

always @(*) begin
    if (rst == 1'b1) begin
        wd_o <= 0;
        wreg_o <= 0;
        wdata_o <= 0;
        ram_addr_o <= ram_addr_i;
        cp0_reg_we_o <= 0;
        cp0_reg_write_addr_o <= 0;
        cp0_reg_data_o <= 0;
        ram_we <= 0;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        cp0_reg_we_o <= cp0_reg_we_i;
        cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
        cp0_reg_data_o <= cp0_reg_data_i;
        ram_be_o <= 0;
        ram_we <= 0;
        ram_oe_o <= 0;
        data_to_write <= 0;
        case (alu_op_i)
            `EXE_LB_OP: begin
                ram_addr_o <= ram_addr_i;
                ram_we <= 0;
                ram_oe_o <= 1;
                case (ram_addr_i[1:0])
                    2'b11: begin
                        ram_be_o <= 4'b1111;
                        wdata_o <= {{24{ram_data_i[31]}}, ram_data_i[31:24]};
                    end
                    2'b10: begin
                        ram_be_o <= 4'b1111;
                        wdata_o <= {{24{ram_data_i[23]}}, ram_data_i[23:16]};
                    end
                    2'b01: begin
                        ram_be_o <= 4'b1111;
                        wdata_o <= {{24{ram_data_i[15]}}, ram_data_i[15:8]};
                    end
                    2'b00: begin
                        ram_be_o <= 4'b1111;
                        wdata_o <= {{24{ram_data_i[7]}}, ram_data_i[7:0]};
                    end
                endcase
            end
            `EXE_LW_OP: begin
                ram_addr_o <= ram_addr_i;
                ram_we <= 0;
                ram_oe_o <= 1;
                ram_be_o <= 4'b1111;
                wdata_o <= ram_data_i;
            end
            `EXE_SB_OP: begin
                ram_addr_o <= ram_addr_i;
                ram_we <= 1;
                ram_oe_o <= 0;
                data_to_write <= 0;
                case (ram_addr_i[1:0])
                    2'b11: begin
                        ram_be_o <= 4'b1000;
                        data_to_write[31:24] <= wdata_i[7:0];
                    end
                    2'b10: begin
                        ram_be_o <= 4'b0100;
                        data_to_write[23:16] <= wdata_i[7:0];
                    end
                    2'b01: begin
                        ram_be_o <= 4'b0010;
                        data_to_write[15:8] <= wdata_i[7:0];
                    end
                    2'b00: begin
                        ram_be_o <= 4'b0001;
                        data_to_write[7:0] <= wdata_i[7:0];
                    end
                endcase
            end
            `EXE_SW_OP: begin
                ram_addr_o <= ram_addr_i;
                ram_we <= 1;
                ram_oe_o <= 0;
                ram_be_o <= 4'b1111;
                data_to_write <= wdata_i;
            end
        endcase
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        cp0_status <= 0;
    end else if (wb_cp0_reg_we == 1'b1 && wb_cp0_reg_write_addr == `CP0_REG_STATUS) begin
        cp0_status <= wb_cp0_reg_data;
    end else begin
        cp0_status <= cp0_status_i;
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        cp0_epc <= 0;
    end else if (wb_cp0_reg_we == 1'b1 && wb_cp0_reg_write_addr == `CP0_REG_EPC) begin
        cp0_epc <= wb_cp0_reg_data;
    end else begin
        cp0_epc <= cp0_epc_i;
    end
end
assign cp0_epc_o = cp0_epc;

always @(*) begin
    if (rst == 1'b1) begin
        cp0_cause <= 0;
    end else if (wb_cp0_reg_we == 1'b1 && wb_cp0_reg_write_addr == `CP0_REG_CAUSE) begin
        cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
        cp0_cause[23] <= wb_cp0_reg_data[23];
        cp0_cause[22] <= wb_cp0_reg_data[22];
    end else begin
        cp0_cause <= cp0_cause_i;
    end
end

// no ebase

always @(*) begin
    if (rst == 1'b1) begin
        excepttype_o <= 0;
    end else begin
        excepttype_o <= 0;
        if (current_inst_address_i != 32'h00000000) begin
            if ((cp0_cause[15:8] & cp0_status[15:8])!=8'h00 && cp0_status[1] == 1'b0 && cp0_status[0] == 1'b1) begin
                excepttype_o <= 32'h00000001;
            end else if (excepttype_i[8] == 1'b1) begin // syscall
                excepttype_o <= 32'h00000008;
                syscall_bias <= wdata_i;
            end else if (excepttype_i[12] == 1'b1) begin
                excepttype_o <= 32'h0000000e;
            end
        end
    end
end



endmodule