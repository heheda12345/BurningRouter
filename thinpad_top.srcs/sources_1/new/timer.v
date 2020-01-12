module timer
# (parameter FREQ = 50000)
(
    input wire clk,
    input wire rst,

    output reg [63:0] out
);
reg [31:0] milCounter;
always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        out = 0;
        milCounter = 0;
    end
    else begin
        milCounter = milCounter + 1;
        if (milCounter == FREQ) begin
            milCounter = 0;
            out = out + 1;
        end
    end
end

endmodule // timer