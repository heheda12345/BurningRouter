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
reg [WIDTH-1:0]  sync0, sync1;
always @(posedge clk_out) sync0 <= data_in;   // notice that we use clk_out
always @(posedge clk_out) sync1 <= sync0;   // notice that we use clk_out

assign data_out = sync1;  // new signal synchronized to (=ready to be used in) clk_out domain
endmodule

module pulse_crossdomain(
    input clk_in,
    input clk_out,
    input rst, 
    input pulse_in,   // this is a one-clock pulse from the clk_in domain
    output pulse_out   // from which we generate a one-clock pulse in clk_out domain
);

reg pulse_toggle_in;
always @(posedge clk_in or posedge rst) 
    pulse_toggle_in <= rst ? 0 : pulse_toggle_in ^ pulse_in;  // when flag is asserted, this signal toggles (clk_in domain)

reg [2:0] sync;
always @(posedge clk_out) sync <= {sync[1:0], pulse_toggle_in};  // now we cross the clock domains

assign pulse_out = (sync[2] ^ sync[1]);  // and create the clk_out flag
endmodule