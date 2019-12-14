// 
// https://www.fpga4fun.com/CrossClockDomain1.html
// Modified
// 

module data_crossdomain
#(parameter WIDTH=1)
(
    input clk_in,   // we actually don't need clk_in in that example, but it is here for completeness as we'll need it in further examples
    input clk_out,
    input [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);

// We use a two-stages shift-register to synchronize 'sync' to the clk_out clock domain
(*ASYNC_REG="TRUE"*)reg [WIDTH-1:0] cdom_sync0, cdom_sync1;
reg [WIDTH-1:0] cdom_buffer;
always @(posedge clk_out) cdom_sync0 <= cdom_buffer;   // notice that we use clk_out
always @(posedge clk_out) cdom_sync1 <= cdom_sync0;   // notice that we use clk_out
always @(posedge clk_in) cdom_buffer <= data_in; // ** swh: Will this work?

assign data_out = cdom_sync1;  // new signal synchronized to (=ready to be used in) clk_out domain
endmodule

module pulse_crossdomain(
    input clk_in,
    input clk_out,
    input rst, 
    input pulse_in,   // this is a one-clock pulse from the clk_in domain
    output pulse_out   // from which we generate a one-clock pulse in clk_out domain
);

reg cdom_pulse_toggle_in;
always @(posedge clk_in or posedge rst) begin
    if (rst) cdom_pulse_toggle_in <= 0;
    else cdom_pulse_toggle_in <= cdom_pulse_toggle_in ^ pulse_in;  // when flag is asserted, this signal toggles (clk_in domain)
end

(*ASYNC_REG="TRUE"*)reg [2:0] cdom_pulse_sync;
always @(posedge clk_out) cdom_pulse_sync <= {cdom_pulse_sync[1:0], cdom_pulse_toggle_in};  // now we cross the clock domains

assign pulse_out = (cdom_pulse_sync[2] ^ cdom_pulse_sync[1]);  // and create the clk_out flag
endmodule