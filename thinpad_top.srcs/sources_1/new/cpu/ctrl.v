module ctrl(
    input wire rst,

    input wire id_req,
    input wire if_req,
    input wire mem_req, 
    input wire[31:0] syscall_bias,

    output reg pc_stall,
    output reg if_stall,
    output reg id_stall,
    output reg ex_stall,
    output reg mem_stall,
    output reg wb_stall,

    input wire[31:0] excepttype_i,
    input wire[31:0] cp0_epc_i,
    input wire[31:0] cp0_ebase_i,
    output reg[31:0] new_pc,
    output reg flush
);


always @(*) begin
    new_pc <= 0;
    if (rst == 1'b1) begin
        pc_stall <= 0;
        if_stall <= 0;
        id_stall <= 0;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
        flush <= 0;
    end else if (excepttype_i != 32'h00000000) begin
        flush <= 1;
        pc_stall <= 0;
        if_stall <= 0;
        id_stall <= 0;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
        case (excepttype_i)
            32'h00000001: begin
                new_pc <= 32'h80001180;
            end
            32'h00000008: begin
                new_pc <= 32'h80001180;
            end
            32'h0000000e: begin
                new_pc <= cp0_epc_i;
            end
            default: begin
                $display("exception %h not support", excepttype_i);
            end
        endcase
    end else if (id_req == 1'b1) begin
        pc_stall <= 1;
        if_stall <= 1;
        id_stall <= 1;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
        flush <= 0;
    end else if (if_req == 1'b1) begin
        pc_stall <= 1;
        if_stall <= 1;
        id_stall <= 0;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
        flush <= 0;
    end else if (mem_req == 1'b1) begin
        pc_stall <= 1;
        if_stall <= 1;
        id_stall <= 1;
        ex_stall <= 1;
        mem_stall <= 1;
        wb_stall <= 0;
        flush <= 0;
    end else begin
        pc_stall <= 0;
        if_stall <= 0;
        id_stall <= 0;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
        flush <= 0;
    end
end
endmodule