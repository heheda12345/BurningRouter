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

reg[31:0] ins_mem[3:0];

// simulate ROM
always @(*) begin
    if (ce == 0) begin
        rom_data <= 0;
    end else begin
        rom_data <= ins_mem[rom_addr[3:2]]; // only 2 bits of pc
    end
end


initial begin
    ins_mem[0] <= 32'h34011000; // ori $1, $0, 0x1000 -> 1000
    ins_mem[1] <= 32'h34220100; // ori $2, $1, 0x0100 -> 1100
    ins_mem[2] <= 32'h34011000; // ori $1, $0, 0x1000 -> 1000
    ins_mem[3] <= 32'h34430001; // ori $3, $2, 0x0001 -> 1101
    rst <= 1;
    #10000
    rst <= 0;
end

endmodule