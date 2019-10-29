
module async_setter
#( parameter LEN = 6, ADDR_WIDTH = 3)
(
    input [7:0] data_input,
    input [ADDR_WIDTH-1:0] index,
    input enable,
    input clk,
    output reg [LEN*8-1:0] value = 0
);

genvar i;
for (i = 0; i < LEN; i = i+1) begin
    always @ (posedge clk)begin
        if (enable && index == i) 
            value[8*(LEN-i-1)+7:8*(LEN-i-1)] <= data_input;
    end
end
endmodule

module async_getter
#( parameter LEN = 6, ADDR_WIDTH = 3)
(
    output [7:0] value,
    input [ADDR_WIDTH-1:0] index,
    input [LEN*8-1:0] data_input
);
wire [LEN*8-1:0] _value;

genvar i;
for (i = 1; i < LEN; i = i+1) begin
    assign _value[8*(LEN-i-1)+7: 8*(LEN-i-1)] = _value[8*(LEN-i)+7: 8*(LEN-i)] | (i == index ? data_input[8*(LEN-i-1)+7: 8*(LEN-i-1)] : 0);
end
assign _value[LEN*8-1:LEN*8-8] = 0 == index ? data_input[LEN*8-1:LEN*8-8] : 0;
assign value = _value[7:0];
endmodule

module async_equal
#( parameter LEN = 6)
(
    input [7:0] data_input,
    input [3:0] index,
    input enable,
    input clk,
    input [LEN*8-1:0] operand, 
    output reg result = 0
);

wire [LEN-1:0] eqif, prefix;
genvar i;
for (i = 0; i < LEN; i = i+1) begin
    assign eqif[i] = index != i || data_input == operand[i*8+7: i*8];
    assign prefix[i] = i == 0 ? eqif[0] : (eqif[i] || prefix[i-1]);
end

always @ (posedge clk) begin
    if (!enable)
        result <= 1;
    else begin
        result <= prefix[LEN-1];
    end
end

endmodule