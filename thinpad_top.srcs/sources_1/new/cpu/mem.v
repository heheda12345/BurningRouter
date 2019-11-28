`include "def_op.v"

module mem(
    input wire rst,

    input wire[4:0] wd_i,
    input wire wreg_i,
    input wire[31:0] wdata_i,
    input wire[7:0] alu_op_i,
    input wire[31:0] ram_addr_i,

    output reg[4:0] wd_o,
    output reg wreg_o,
    output reg[31:0] wdata_o,

    // with ram
    input wire[31:0] ram_data_i,
    output wire[31:0] ram_data_o, 
    output reg[31:0] ram_addr_o,
    output reg[3:0] ram_be_o, // byte enable
    output reg ram_we_o,        // write enable
    output reg ram_oe_o         // read enable
);

reg[31:0] data_to_write;
// assign ram_data_i = ram_oe_o ? 32'hzzzzzzzz : data_to_write;
assign ram_data_o = data_to_write;

always @(*) begin
    if (rst == 1'b1) begin
        wd_o <= 0;
        wreg_o <= 0;
        wdata_o <= 0;
        ram_addr_o <= ram_addr_i;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        ram_be_o <= 0;
        ram_we_o <= 0;
        ram_oe_o <= 0;
        data_to_write <= 0;
        case (alu_op_i)
            `EXE_LB_OP: begin
                ram_addr_o <= ram_addr_i;
                ram_we_o <= 0;
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
                ram_we_o <= 0;
                ram_oe_o <= 1;
                ram_be_o <= 4'b1111;
                wdata_o <= ram_data_i;
            end
            `EXE_SB_OP: begin
                ram_addr_o <= ram_addr_i;
                ram_we_o <= 1;
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
                ram_we_o <= 1;
                ram_oe_o <= 0;
                ram_be_o <= 4'b1111;
                data_to_write <= wdata_i;
            end
        endcase
    end
end

endmodule