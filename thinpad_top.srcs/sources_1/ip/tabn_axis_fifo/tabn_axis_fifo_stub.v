// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Sep 23 21:31:57 2019
// Host        : DESKTOP-BS588P3 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               F:/router/router/thinpad_top/thinpad_top.srcs/sources_1/ip/tabn_axis_fifo/tabn_axis_fifo_stub.v
// Design      : tabn_axis_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg676-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_3,Vivado 2018.3" *)
module tabn_axis_fifo(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[8:0],wr_en,rd_en,dout[8:0],full,empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [8:0]din;
  input wr_en;
  input rd_en;
  output [8:0]dout;
  output full;
  output empty;
endmodule
