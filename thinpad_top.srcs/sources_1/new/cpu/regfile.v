module regfile(
    input wire clk,
    input wire rst,

    (*mark_debug="true"*)input wire we,
    (*mark_debug="true"*)input wire [4:0] waddr,
    (*mark_debug="true"*)input wire [31:0] wdata,

    (*mark_debug="true"*)input wire re1,
    (*mark_debug="true"*)input wire [4:0] raddr1,
    (*mark_debug="true"*)output reg [31:0] rdata1,

    (*mark_debug="true"*)input wire re2,
    (*mark_debug="true"*)input wire [4:0] raddr2,
    (*mark_debug="true"*)output reg [31:0] rdata2
);

reg[31:0] regs[31:0];

// write
always @(posedge clk) begin
    if (rst == 1'b0) begin
        if (we == 1'b1 && waddr != 5'b00000) begin
            regs[waddr] <= wdata;
            $display("write %h to reg %d", wdata, waddr);
        end
    end
end

// read1
always @(*) begin
    if (rst == 1'b1) begin
        rdata1 <= 0;
    end else if (re1 ==  1'b1) begin
        if (raddr1 == 5'b00000) begin // must check first, think waddr = 0, we = 1, wdata != 0
            rdata1 <= 0;
        end else if (raddr1 == waddr && we == 1'b1) begin
            rdata1 <= wdata;
        end else begin
            rdata1 <= regs[raddr1];
        end
    end else begin
        rdata1 <= 0;
    end
end

// read2, copy from read1, change 1 to 2
always @(*) begin
    if (rst == 1'b1) begin
        rdata2 <= 0;
    end else if (re2 == 1'b1) begin
        if (raddr2 == 5'b00000) begin // must check first, think waddr = 0, we = 1, wdata != 0
            rdata2 <= 0;
        end else if (raddr2 == waddr && we == 1'b1) begin
            rdata2 <= wdata;
        end else begin
            rdata2 <= regs[raddr2];
        end
    end else begin
        rdata2 <= 0;
    end
end

endmodule