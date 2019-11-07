module fifo_native2axis
(
    input clk, 
    input rst, 

    input native_empty,
    input [8:0]native_dout, 
    output native_rd_en,

    output [7:0] axis_tdata,
    output axis_tlast,
    output axis_tvalid,
    input axis_tready
);

reg [1:0] counter = 0;
reg zero_padding = 0;

always @(posedge clk or posedge rst) begin
    if (rst) counter <= 0;
    else if (native_rd_en)
        counter <= counter + 1;
    if (rst) zero_padding <= 0;
    else if (counter == 3) zero_padding <= 0;
    else if (axis_tlast) zero_padding <= 1;
end
assign axis_tdata = native_dout[8:1];
assign axis_tlast = native_dout[0] && axis_tvalid;
assign axis_tvalid = ~native_empty && ~zero_padding;
assign native_rd_en = axis_tvalid && axis_tready || zero_padding;

endmodule // fifo_native2axis

module fifo_axis2native(
    input clk, 
    input rst, 

    input [7:0] axis_tdata,
    input axis_tlast,
    input axis_tvalid,
    output axis_tready,

    input native_full,
    output [8:0]native_din, 
    output native_wr_en
);


reg [1:0] counter = 0;
reg zero_padding = 0;

always @(posedge clk or posedge rst) begin
    if (rst) counter <= 0;
    else if (native_wr_en)
        counter <= counter + 1;
    if (rst) zero_padding <= 0;
    else if (counter == 3) zero_padding <= 0;
    else if (axis_tlast) zero_padding <= 1;
end
assign native_din = zero_padding ? 9'b0 : {axis_tdata, axis_tlast};
assign axis_tready = axis_tvalid && ~native_full && ~zero_padding;
assign native_wr_en = axis_tready || zero_padding;

endmodule // fifo_axis2native