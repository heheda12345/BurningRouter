
module lookup_table 
#( parameter STATIC_LOOKUP_TABLE_SIZE = 4)
(
    input wire lku_clk, lku_rst,
    input wire [31:0] lku_in_addr,
    input wire lku_in_ready,
    output reg [31:0] lku_out_nexthop,
    output reg [1:0] lku_out_interface,
    output reg lku_out_ready, 

    // hard-code static route lookup table
    input wire [0:32*STATIC_LOOKUP_TABLE_SIZE-1] static_table_addr,
    input wire [0:32*STATIC_LOOKUP_TABLE_SIZE-1] static_table_mask,
    input wire [0:32*STATIC_LOOKUP_TABLE_SIZE-1] static_table_nexthop,
    input wire [0:2*STATIC_LOOKUP_TABLE_SIZE-1] static_table_interface
);

    parameter LOOKUP_TABLE_SCALE = 3;
    parameter LOOKUP_TABLE_SIZE = 2 ** LOOKUP_TABLE_SCALE;
    parameter WAIT_s = 2'b00;
    parameter PROCESSING_s = 2'b01;
    parameter FINISH_s = 2'b10;

    reg [1:0] lku_state = WAIT_s;
    reg [31:0] lookup_addr;
    reg [LOOKUP_TABLE_SCALE-1:0] select_id, current_id, max_id = STATIC_LOOKUP_TABLE_SIZE;

    // 2bit interface | 32bit next hop | 32bit mask | 32bit dest addr
    reg [97:0] table_entry[0:LOOKUP_TABLE_SIZE-1];

    initial begin
        table_entry[0] <= 98'b0;
    end

    always @ (posedge lku_rst)
    begin
        lku_state <= WAIT_s;
        max_id <= STATIC_LOOKUP_TABLE_SIZE;
    end

    // first entry of the table <= 0.0.0.0/0
    // next STATIC_LOOKUP_TABLE_SIZE entries <= static_table
    genvar i;
    for (i = 0;i < STATIC_LOOKUP_TABLE_SIZE; i=i+1) begin
        always @ (posedge lku_clk)
        begin
            table_entry[i+1] <= {
                static_table_interface[2*i : 2*i+1], 
                static_table_nexthop[32*i : 32*i+31], 
                static_table_mask[32*i : 32*i+31], 
                static_table_addr[32*i : 32*i+31]
            };
        end
    end

    always @ (posedge lku_clk)
    begin
        case (lku_state)
            WAIT_s: begin
                if (lku_in_ready == 1'b1) begin
                    // start lookup
                    lku_state <= PROCESSING_s;
                    lookup_addr <= lku_in_addr;
                    current_id <= 0;
                    select_id <= 0;
                end
                else begin
                    lku_state <= WAIT_s;
                end
            end
            PROCESSING_s: begin
                if (lku_in_ready == 1'b0) begin
                    lku_state <= WAIT_s;
                end
                else begin
                    // processing...
                    if ( ((table_entry[current_id][31:0] ^ lookup_addr) & table_entry[current_id][63:32]) == 32'b0
                            && (table_entry[current_id][63:32] | table_entry[select_id][63:32]) == table_entry[current_id][63:32] )
                    begin
                        select_id <= current_id;
                    end
                    if (current_id == max_id) begin
                        lku_state <= FINISH_s;
                    end
                    else begin
                        lku_state <= PROCESSING_s;
                        current_id <= current_id + 1;
                    end
                end
            end
            FINISH_s: begin
                if (lku_in_ready == 1'b0) begin
                    lku_state <= WAIT_s;
                end
                else begin
                    lku_state <= FINISH_s;
                end
            end
        endcase
    end

    // output
    always @ (lku_state) begin
        case (lku_state)
            WAIT_s: begin
                lku_out_nexthop <= 32'b0;
                lku_out_interface <= 2'b0;
            end
            FINISH_s: begin
                {lku_out_interface, lku_out_nexthop} <= table_entry[select_id][97:64];
            end
        endcase
        lku_out_ready <= lku_state == FINISH_s;
    end
/*
    always @ (posedge lku_clk) begin
        lku_out_ready <= lku_state == FINISH_s;
    end*/

endmodule
