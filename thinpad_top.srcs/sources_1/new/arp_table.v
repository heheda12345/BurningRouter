module arp_table
#(parameter VLAN_PORT_WIDTH = 8, TABLE_ENTRY_WIDTH = 4)
(
    input clk,
    input syn_rst, 
    
    input update,
    input insert,
    output exist,
    input [VLAN_PORT_WIDTH-1:0] input_vlan_port, 
    input [31:0] input_ipv4_addr, 
    input [47:0] input_mac_addr,
    /*
    input [TABLE_ENTRY_WIDTH-1:0] query_index,
    output reg [VLAN_PORT_WIDTH-1:0] output_vlan_port = 0,
    output reg [31:0] output_ipv4_addr = 0,
    */
    output [47:0] output_mac_addr
);

localparam  TABLE_SIZE = 2 ** TABLE_ENTRY_WIDTH,
            ENTRY_WIDTH = 48+32+VLAN_PORT_WIDTH;

reg [ENTRY_WIDTH-1 : 0] table_entry [TABLE_SIZE-1:0]; // vlan port - ip - mac

wire [TABLE_SIZE:0] _exist;
assign _exist[TABLE_SIZE] = 1;
reg [TABLE_ENTRY_WIDTH-1:0] pointer = 0;
wire [(1+TABLE_SIZE) * 48 - 1 : 0] _output;
genvar i;
for (i = 0; i < TABLE_SIZE; i=i+1) begin
    assign _exist[i] = _exist[i+1] && table_entry[i] == {input_vlan_port, input_ipv4_addr, input_mac_addr};
    assign _output[i * 48 + 47 : i * 48] = _output[(1+i)*48 + 47 : i*48 + 48] | 
        (table_entry[i][ENTRY_WIDTH-1 : 48] == {input_vlan_port, input_ipv4_addr} ? table_entry[i][47:0] : 0);
    always @ (posedge clk) begin
        if (syn_rst) begin
            table_entry[i] <= 0;
        end
        else if (update && table_entry[i][ENTRY_WIDTH-1:48] == {input_vlan_port, input_ipv4_addr}) begin
            table_entry[i][47:0] <= input_mac_addr;
        end
        else if (insert && i == pointer) begin
            table_entry[i] <= {input_vlan_port, input_ipv4_addr, input_mac_addr};
        end
    end
end
always @ (posedge clk) begin
    if (syn_rst) pointer <= 0;
    else if (insert) pointer <= pointer + 1;
end
assign exist = _exist[0];
assign output_mac_addr = _output[47:0];

endmodule // arp_table