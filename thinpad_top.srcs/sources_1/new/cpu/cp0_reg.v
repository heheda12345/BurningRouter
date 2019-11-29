`include "def_op.v"
module cp0_reg(
    input wire clk,
    input wire rst,

    input wire we_i,
    input wire[4:0] waddr_i,
    input wire[4:0] raddr_i,
    input wire[31:0] data_i,
    input wire[5:0] int_i,
    input wire[31:0] excepttype_i,
    input wire[31:0] current_inst_addr_i,
    input wire is_in_delay_slot_i,

    output reg[31:0] data_o,
    output reg[31:0] status_o,
    output reg[31:0] cause_o,
    output reg[31:0] ebase_o,
    output reg[31:0] epc_o
);

always @(posedge clk) begin
    if (rst == 1'b1) begin
        data_o <= 0;
        status_o <= 32'b00010000000000000000000000000000;
        cause_o <= 0;
        ebase_o <= 0;
        epc_o <= 0;
    end else begin
        cause_o[15:10] <= int_i;
        if (we_i == 1'b1) begin
            case (waddr_i)
                `CP0_REG_STATUS: begin // status
                    status_o <= data_i;
                end
                `CP0_REG_CAUSE: begin // cause
                    cause_o[9:8] <= data_i[9:8];
                    cause_o[23] <= data_i[23];
                    cause_o[22] <= data_i[22];
                end
                `CP0_REG_EPC: begin // epc
                    epc_o <= data_i;
                end
                `CP0_REG_EBASE: begin // ebase
                    ebase_o <= data_i | 32'h80000000;
                end
            endcase
        end

        case (excepttype_i)
            32'h00000001: begin
                if (is_in_delay_slot_i == 1'b1) begin
                    epc_o <= current_inst_addr_i - 4;
                    cause_o[31] <= 1'b1;
                end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b00000;
            end

            32'h00000008: begin
                if (status_o[1] == 1'b0) begin
                    if (is_in_delay_slot_i == 1'b1) begin
                        epc_o <= current_inst_addr_i - 4;
                        cause_o[31] <= 1'b1;
                    end else begin
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b01000;
            end

            32'h0000000e: begin
                status_o[1] <= 1'b0;
            end
        endcase
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        data_o <= 0;
    end else begin
        case (raddr_i)
            `CP0_REG_STATUS: begin // status
                data_o <= status_o;
            end
            `CP0_REG_CAUSE: begin // cause
                data_o <= cause_o;
            end
            `CP0_REG_EPC: begin // epc
                data_o <= epc_o;
            end
            `CP0_REG_EBASE: begin // ebase
                data_o <= ebase_o;
            end
        endcase
    end
end

endmodule