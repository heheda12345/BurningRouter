module ctrl(
    input wire rst,

    input wire id_req,
    input wire if_req,
    input wire mem_req, 

    output reg pc_stall,
    output reg if_stall,
    output reg id_stall,
    output reg ex_stall,
    output reg mem_stall,
    output reg wb_stall
);


always @(*) begin
    if (rst == 1'b1) begin
        pc_stall <= 0;
        if_stall <= 0;
        id_stall <= 0;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
    end else if (id_req == 1'b1) begin
        pc_stall <= 1;
        if_stall <= 1;
        id_stall <= 1;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
    end else if (if_req == 1'b1) begin
        pc_stall <= 1;
        if_stall <= 1;
        id_stall <= 1;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
    end else if (mem_req == 1'b1) begin
        pc_stall <= 1;
        if_stall <= 1;
        id_stall <= 1;
        ex_stall <= 1;
        mem_stall <= 1;
        wb_stall <= 0;
    end else begin
        pc_stall <= 0;
        if_stall <= 0;
        id_stall <= 0;
        ex_stall <= 0;
        mem_stall <= 0;
        wb_stall <= 0;
    end
end
endmodule