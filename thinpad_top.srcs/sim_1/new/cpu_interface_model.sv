`timescale 1ns / 1ps
module cpu_interface_model (
    input clk_cpu,
    
    input [31:0] cpu_rx_qword_tdata,
    input [3:0] cpu_rx_qword_tlast,
    input cpu_rx_qword_tvalid,
    output cpu_rx_qword_tready,
    // CPU transmitting FIFO
    output reg [31:0] cpu_tx_qword_tdata,
    output reg [3:0] cpu_tx_qword_tlast,
    output reg cpu_tx_qword_tvalid,
    input cpu_tx_qword_tready
);
    localparam BUFFER_SIZE = 2000;
    localparam FRAME_COUNT = 10;

    logic packet_clk;
    logic trans, out_en;
    logic [7:0] frame_index = 0;
    logic [3:0] data1;
    logic [3:0] data2;
    logic [3:0] out1;
    logic [3:0] out2;
    logic [7:0] frame_data [FRAME_COUNT-1:0][BUFFER_SIZE-1:0];
    logic [8*BUFFER_SIZE-1:0] buffer;
    logic [15:0] count;
    logic [15:0] frame_size [FRAME_COUNT-1:0];
    integer fd, fout, index, res, frame_count;

    initial begin
        packet_clk = 0;
        fd = $fopen("example_frame_cpu.mem", "r");
        fout = $fopen("receive_data_cpu.mem", "w");

        index = 0;
        frame_count = 0;
        for (integer i = 0;i < FRAME_COUNT;i++) begin
            frame_size[i] = 0;
            for (integer j = 0;j < BUFFER_SIZE;j++) begin
                frame_data[i][j] = 0;
            end
        end

        while (!$feof(fd)) begin
            res = $fscanf(fd, "%x", frame_data[frame_count][index]);
            if (res != 1) begin
                // end of a frame
                // read a line
                $fgets(buffer, fd);
                if (index > 0) begin
                    frame_size[frame_count] = index + 1;
                    frame_count = frame_count + 1;
                end
                index = 0;
            end else begin
                index = index + 1;
            end
        end

        if (index > 0) begin
            frame_size[frame_count] = index + 1;
            frame_count = frame_count + 1;
        end
    end

    always packet_clk = #1000 ~packet_clk;
    always_ff @ (posedge clk_cpu) begin
        count <= packet_clk ? count + 4 : 0;
        if (packet_clk && count < frame_size[frame_index] - 1) begin
            cpu_tx_qword_tdata <= {
                frame_data[frame_index][count], 
                frame_data[frame_index][count + 1], 
                frame_data[frame_index][count + 2], 
                frame_data[frame_index][count + 3]
            };
            cpu_tx_qword_tlast <= {
                count + 1 == frame_size[frame_index] - 1, 
                count + 2 == frame_size[frame_index] - 1, 
                count + 3 == frame_size[frame_index] - 1, 
                count + 4 == frame_size[frame_index] - 1
            };
            cpu_tx_qword_tvalid <= 1'b1;
        end else begin
            cpu_tx_qword_tdata <= 32'b0;
            cpu_tx_qword_tlast <= 4'b0;
            cpu_tx_qword_tvalid <= 1'b0;
        end
    end
    always_ff @ (negedge packet_clk) begin
        frame_index = (frame_index + 1) % frame_count;
    end
/*
    always_ff @ (posedge clk_125M) begin
        if (count < frame_size[frame_index] - 1) begin
            count <= count + 1;
            trans <= 1'b1;
            data1 <= frame_data[frame_index][count][3:0];
            data2 <= frame_data[frame_index][count][7:4];
        end else begin
            trans <= 1'b0;
            data1 <= 4'b0;
            data2 <= 4'b0;
            count <= 0;
            frame_index <= (frame_index + 1) % frame_count;
        end
    end
    */
    reg receiving;
    assign cpu_rx_qword_tready = cpu_rx_qword_tvalid;
    always @ (posedge clk_cpu) begin
        if (cpu_rx_qword_tready) begin
            $fwrite(fout, "%x ", cpu_rx_qword_tdata);
            if (cpu_rx_qword_tlast != 0) begin
                $fwrite(fout, "\n");
                $fflush(fout);
                receiving <= 0;
            end else begin
                receiving <= 1;
            end
        end
    end

endmodule
