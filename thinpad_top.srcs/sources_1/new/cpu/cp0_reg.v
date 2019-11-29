module cp0_reg(
    input wire clk,
    input wire rst,

    input wire we_i,
    input wire[4:0] waddr_i,
    input wire[4:0] raddr_i,
    input wire[31:0] data_i,
    input wire[5:0] int_i,

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
                5'b01100: begin // status
                    status_o <= data_i;
                end
                5'b01101: begin // cause
                    cause_o[15:8] <= data_i[15:8]; // different from openmips, as ip4 can be set
                    cause_o[23] <= data_i[23];
                    cause_o[22] <= data_i[22];
                end
                5'b01110: begin // epc
                    epc_o <= data_i;
                end
                5'b01111: begin // ebase
                    ebase_o <= data_i;
                end
            endcase
        end
    end
end

always @(*) begin
    if (rst == 1'b1) begin
        data_o <= 0;
    end else begin
        case (raddr_i)
            5'b01100: begin // status
                data_o <= status_o;
            end
            5'b01101: begin // cause
                data_o <= cause_o;
            end
            5'b01110: begin // epc
                data_o <= epc_o;
            end
            5'b01111: begin // ebase
                data_o <= ebase_o;
            end
        endcase
    end
end

endmodule