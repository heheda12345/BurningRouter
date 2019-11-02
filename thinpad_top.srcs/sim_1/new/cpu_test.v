module cpu_test(
    input wire clk
);

reg [31:0] rom_data;
wire [31:0] rom_addr;
wire ce;
reg rst;

cpu CPU(
    .clk(clk),
    .rst(rst),
    .rom_data_i(rom_data),
    .rom_addr_o(rom_addr),
    .rom_ce_o(ce)
);

reg[31:0] ins_mem[7:0];

// simulate ROM
always @(*) begin
    if (ce == 0) begin
        rom_data <= 0;
    end else begin
        rom_data <= ins_mem[rom_addr[4:2]]; // only 2 bits of pc
    end
end


initial begin
    ins_mem[0] <= 32'h3c020404; // lui $2, 0x0404 -> 04040000
    ins_mem[1] <= 32'h34420404; // ori $2, $2, 0x0404 -> 04040404
    ins_mem[2] <= 32'h00021200; // sll $2, $2, 8 -> 04040400
    ins_mem[3] <= 32'h00021202; // srl $2, $2, 8 -> 00040404

    rst <= 1;
    #10000
    rst <= 0;
end

endmodule