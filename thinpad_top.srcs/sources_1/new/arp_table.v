module arp_table
#(parameter VLAN_PORT_WIDTH = 8, TABLE_ENTRY_WIDTH = 4) ////////////////////////////
(
    input clk,
    input syn_rst, 
    
    input update,
    input insert,
    output exist,
    input [VLAN_PORT_WIDTH-1:0] input_vlan_port, 
    input [31:0] input_ipv4_addr, 
    input [47:0] input_mac_addr,
    
    input [VLAN_PORT_WIDTH-1:0] query_vlan_port,
    input [31:0] query_ipv4_addr,
    output reg [47:0] output_mac_addr,
    output reg query_exist
);

localparam  TABLE_SIZE = 2 ** TABLE_ENTRY_WIDTH,
            ENTRY_WIDTH = 48+32+VLAN_PORT_WIDTH;

reg [ENTRY_WIDTH-1 : 0] table_entry [TABLE_SIZE-1:0]; // vlan port - ip - mac

wire [TABLE_SIZE+TABLE_SIZE-1:0] _exist, _qexist;
assign _exist[TABLE_SIZE+TABLE_SIZE] = 0;
assign _qexist[TABLE_SIZE+TABLE_SIZE] = 0;
// assign _output[TABLE_SIZE*48 + 47 : TABLE_SIZE*48] = 0;
reg [TABLE_ENTRY_WIDTH-1:0] pointer = 0;
wire [(TABLE_SIZE+TABLE_SIZE) * 48 - 1 : 0] _output;
genvar i;
for (i = 0; i < TABLE_SIZE; i=i+1) begin
    assign _exist[i+TABLE_SIZE] = table_entry[i] == {input_vlan_port, input_ipv4_addr, input_mac_addr};
    assign _exist[i] = i == 0 ? 0 : _exist[i*2] | _exist[i*2+1];
    assign _qexist[TABLE_SIZE + i] = table_entry[i][ENTRY_WIDTH-1 : 48] == {query_vlan_port, query_ipv4_addr} && table_entry[i][47:0] != 0;
    assign _qexist[i] = i == 0 ? 0 : _qexist[i*2] | _qexist[i*2+1];
    assign _output[(TABLE_SIZE + i) * 48 + 47 : (TABLE_SIZE + i) * 48] = 
            (table_entry[i][ENTRY_WIDTH-1 : 48] == {query_vlan_port, query_ipv4_addr} ? table_entry[i][47:0] : 0);
    assign _output[i * 48 + 47 : i * 48] = i == 0 ? 0 : 
            _output[2 * i * 48 + 47 : 2 * i * 48] | _output[(2 * i + 1) * 48 + 47 : (2 * i + 1) * 48];
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
    query_exist <= _qexist[1];
    output_mac_addr <= _output[47+48:48];
end
assign exist = _exist[1];
// assign query_exist = _qexist[0];
// assign output_mac_addr = _output[47:0];

endmodule // arp_table