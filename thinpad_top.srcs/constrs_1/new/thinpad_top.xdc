#Clock
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports clk_50M]
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33} [get_ports clk_11M0592]

create_clock -period 20.000 -name clk_50M -waveform {0.000 10.000} [get_ports clk_50M]
create_clock -period 90.422 -name clk_11M0592 -waveform {0.000 45.211} [get_ports clk_11M0592]

#Touch Button
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {touch_btn[0]}]
set_property -dict {PACKAGE_PIN E25 IOSTANDARD LVCMOS33} [get_ports {touch_btn[1]}]
set_property -dict {PACKAGE_PIN F23 IOSTANDARD LVCMOS33} [get_ports {touch_btn[2]}]
set_property -dict {PACKAGE_PIN E23 IOSTANDARD LVCMOS33} [get_ports {touch_btn[3]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports clock_btn]
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports reset_btn]

#required if touch button used as manual clock source
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets reset_btn_IBUF]

#CPLD
set_property -dict {PACKAGE_PIN L8 IOSTANDARD LVCMOS33} [get_ports uart_wrn]
set_property -dict {PACKAGE_PIN M6 IOSTANDARD LVCMOS33} [get_ports uart_rdn]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports uart_tbre]
set_property -dict {PACKAGE_PIN L7 IOSTANDARD LVCMOS33} [get_ports uart_tsre]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports uart_dataready]

#Ext serial
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN L19} [get_ports txd]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K21} [get_ports rxd]

# USB + SD
set_property -dict {PACKAGE_PIN K7 IOSTANDARD LVCMOS33} [get_ports ch376t_sdo]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports ch376t_sdi]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports ch376t_sck]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports ch376t_cs_n]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports ch376t_rst]
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports ch376t_int_n]

# KSZ8795 Ethernet Switch
set_property -dict {PACKAGE_PIN J6 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_rd[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_rd[1]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_rd[2]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_rd[3]}]
set_property -dict {PACKAGE_PIN H8 IOSTANDARD LVCMOS33} [get_ports eth_rgmii_rx_ctl]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports eth_rgmii_rxc]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_td[0]}]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_td[1]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_td[2]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {eth_rgmii_td[3]}]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports eth_rgmii_tx_ctl]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports eth_rgmii_txc]

set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports eth_rst_n]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports eth_int_n]

set_property -dict {PACKAGE_PIN K6 IOSTANDARD LVCMOS33} [get_ports eth_spi_mosi]
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports eth_spi_miso]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports eth_spi_sck]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS33} [get_ports eth_spi_ss_n]

#Digital Video
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS33} [get_ports video_clk]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {video_red[2]}]
set_property -dict {PACKAGE_PIN N21 IOSTANDARD LVCMOS33} [get_ports {video_red[1]}]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports {video_red[0]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {video_green[2]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {video_green[1]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {video_green[0]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {video_blue[1]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {video_blue[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports video_hsync]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports video_vsync]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports video_de]

#LEDS
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {leds[0]}]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {leds[1]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {leds[2]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {leds[3]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {leds[4]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {leds[5]}]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {leds[6]}]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports {leds[7]}]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports {leds[8]}]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports {leds[9]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {leds[10]}]
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {leds[11]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {leds[12]}]
set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS33} [get_ports {leds[13]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {leds[14]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {leds[15]}]

#DPY0
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33} [get_ports {dpy0[0]}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {dpy0[1]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {dpy0[2]}]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {dpy0[3]}]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {dpy0[4]}]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {dpy0[5]}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {dpy0[6]}]
set_property -dict {PACKAGE_PIN J8 IOSTANDARD LVCMOS33} [get_ports {dpy0[7]}]

#DPY1
set_property -dict {PACKAGE_PIN H9 IOSTANDARD LVCMOS33} [get_ports {dpy1[0]}]
set_property -dict {PACKAGE_PIN G8 IOSTANDARD LVCMOS33} [get_ports {dpy1[1]}]
set_property -dict {PACKAGE_PIN G7 IOSTANDARD LVCMOS33} [get_ports {dpy1[2]}]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {dpy1[3]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33} [get_ports {dpy1[4]}]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports {dpy1[5]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {dpy1[6]}]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports {dpy1[7]}]

#DIP_SW
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {dip_sw[0]}]
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports {dip_sw[1]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {dip_sw[2]}]
set_property -dict {PACKAGE_PIN P4 IOSTANDARD LVCMOS33} [get_ports {dip_sw[3]}]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports {dip_sw[4]}]
set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVCMOS33} [get_ports {dip_sw[5]}]
set_property -dict {PACKAGE_PIN R8 IOSTANDARD LVCMOS33} [get_ports {dip_sw[6]}]
set_property -dict {PACKAGE_PIN T8 IOSTANDARD LVCMOS33} [get_ports {dip_sw[7]}]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {dip_sw[8]}]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {dip_sw[9]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {dip_sw[10]}]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {dip_sw[11]}]
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {dip_sw[12]}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {dip_sw[13]}]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {dip_sw[14]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {dip_sw[15]}]
set_property -dict {PACKAGE_PIN U6 IOSTANDARD LVCMOS33} [get_ports {dip_sw[16]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {dip_sw[17]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {dip_sw[18]}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {dip_sw[19]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {dip_sw[20]}]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {dip_sw[21]}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {dip_sw[22]}]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports {dip_sw[23]}]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports {dip_sw[24]}]
set_property -dict {PACKAGE_PIN P6 IOSTANDARD LVCMOS33} [get_ports {dip_sw[25]}]
set_property -dict {PACKAGE_PIN P8 IOSTANDARD LVCMOS33} [get_ports {dip_sw[26]}]
set_property -dict {PACKAGE_PIN N8 IOSTANDARD LVCMOS33} [get_ports {dip_sw[27]}]
set_property -dict {PACKAGE_PIN N6 IOSTANDARD LVCMOS33} [get_ports {dip_sw[28]}]
set_property -dict {PACKAGE_PIN N7 IOSTANDARD LVCMOS33} [get_ports {dip_sw[29]}]
set_property -dict {PACKAGE_PIN M7 IOSTANDARD LVCMOS33} [get_ports {dip_sw[30]}]
set_property -dict {PACKAGE_PIN M5 IOSTANDARD LVCMOS33} [get_ports {dip_sw[31]}]

set_property -dict {PACKAGE_PIN K8 IOSTANDARD LVCMOS33} [get_ports {flash_a[0]}]
set_property -dict {PACKAGE_PIN C26 IOSTANDARD LVCMOS33} [get_ports {flash_a[1]}]
set_property -dict {PACKAGE_PIN B26 IOSTANDARD LVCMOS33} [get_ports {flash_a[2]}]
set_property -dict {PACKAGE_PIN B25 IOSTANDARD LVCMOS33} [get_ports {flash_a[3]}]
set_property -dict {PACKAGE_PIN A25 IOSTANDARD LVCMOS33} [get_ports {flash_a[4]}]
set_property -dict {PACKAGE_PIN D24 IOSTANDARD LVCMOS33} [get_ports {flash_a[5]}]
set_property -dict {PACKAGE_PIN C24 IOSTANDARD LVCMOS33} [get_ports {flash_a[6]}]
set_property -dict {PACKAGE_PIN B24 IOSTANDARD LVCMOS33} [get_ports {flash_a[7]}]
set_property -dict {PACKAGE_PIN A24 IOSTANDARD LVCMOS33} [get_ports {flash_a[8]}]
set_property -dict {PACKAGE_PIN C23 IOSTANDARD LVCMOS33} [get_ports {flash_a[9]}]
set_property -dict {PACKAGE_PIN D23 IOSTANDARD LVCMOS33} [get_ports {flash_a[10]}]
set_property -dict {PACKAGE_PIN A23 IOSTANDARD LVCMOS33} [get_ports {flash_a[11]}]
set_property -dict {PACKAGE_PIN C21 IOSTANDARD LVCMOS33} [get_ports {flash_a[12]}]
set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33} [get_ports {flash_a[13]}]
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33} [get_ports {flash_a[14]}]
set_property -dict {PACKAGE_PIN E21 IOSTANDARD LVCMOS33} [get_ports {flash_a[15]}]
set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33} [get_ports {flash_a[16]}]
set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports {flash_a[17]}]
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports {flash_a[18]}]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {flash_a[19]}]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33} [get_ports {flash_a[20]}]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS33} [get_ports {flash_a[21]}]
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports {flash_a[22]}]

set_property -dict {PACKAGE_PIN F8 IOSTANDARD LVCMOS33} [get_ports {flash_d[0]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {flash_d[1]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33} [get_ports {flash_d[2]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {flash_d[3]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {flash_d[4]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {flash_d[5]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {flash_d[6]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {flash_d[7]}]
set_property -dict {PACKAGE_PIN F7 IOSTANDARD LVCMOS33} [get_ports {flash_d[8]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {flash_d[9]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {flash_d[10]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {flash_d[11]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33} [get_ports {flash_d[12]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {flash_d[13]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {flash_d[14]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {flash_d[15]}]

set_property -dict {PACKAGE_PIN G9 IOSTANDARD LVCMOS33} [get_ports flash_byte_n]
set_property -dict {PACKAGE_PIN A22 IOSTANDARD LVCMOS33} [get_ports flash_ce_n]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports flash_oe_n]
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS33} [get_ports flash_rp_n]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS33} [get_ports flash_vpen]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports flash_we_n]

set_property -dict {PACKAGE_PIN F24 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[0]}]
set_property -dict {PACKAGE_PIN G24 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[1]}]
set_property -dict {PACKAGE_PIN L24 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[2]}]
set_property -dict {PACKAGE_PIN L23 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[3]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[4]}]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[5]}]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[6]}]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[7]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[8]}]
set_property -dict {PACKAGE_PIN H23 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[9]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[10]}]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[11]}]
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[12]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[13]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[14]}]
set_property -dict {PACKAGE_PIN M24 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[15]}]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[16]}]
set_property -dict {PACKAGE_PIN N23 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[17]}]
set_property -dict {PACKAGE_PIN N24 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[18]}]
set_property -dict {PACKAGE_PIN P23 IOSTANDARD LVCMOS33} [get_ports {base_ram_addr[19]}]
set_property -dict {PACKAGE_PIN M26 IOSTANDARD LVCMOS33} [get_ports {base_ram_be_n[0]}]
set_property -dict {PACKAGE_PIN L25 IOSTANDARD LVCMOS33} [get_ports {base_ram_be_n[1]}]
set_property -dict {PACKAGE_PIN D26 IOSTANDARD LVCMOS33} [get_ports {base_ram_be_n[2]}]
set_property -dict {PACKAGE_PIN D25 IOSTANDARD LVCMOS33} [get_ports {base_ram_be_n[3]}]
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[0]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[1]}]
set_property -dict {PACKAGE_PIN N22 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[2]}]
set_property -dict {PACKAGE_PIN R20 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[3]}]
set_property -dict {PACKAGE_PIN M25 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[4]}]
set_property -dict {PACKAGE_PIN N26 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[5]}]
set_property -dict {PACKAGE_PIN P26 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[6]}]
set_property -dict {PACKAGE_PIN P25 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[7]}]
set_property -dict {PACKAGE_PIN J23 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[8]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[9]}]
set_property -dict {PACKAGE_PIN E26 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[10]}]
set_property -dict {PACKAGE_PIN H21 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[11]}]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[12]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[13]}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[14]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[15]}]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[16]}]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[17]}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[18]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[19]}]
set_property -dict {PACKAGE_PIN K20 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[20]}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[21]}]
set_property -dict {PACKAGE_PIN L22 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[22]}]
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[23]}]
set_property -dict {PACKAGE_PIN K26 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[24]}]
set_property -dict {PACKAGE_PIN K25 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[25]}]
set_property -dict {PACKAGE_PIN J26 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[26]}]
set_property -dict {PACKAGE_PIN J25 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[27]}]
set_property -dict {PACKAGE_PIN H26 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[28]}]
set_property -dict {PACKAGE_PIN G26 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[29]}]
set_property -dict {PACKAGE_PIN G25 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[30]}]
set_property -dict {PACKAGE_PIN F25 IOSTANDARD LVCMOS33} [get_ports {base_ram_data[31]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports base_ram_ce_n]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports base_ram_oe_n]
set_property -dict {PACKAGE_PIN P24 IOSTANDARD LVCMOS33} [get_ports base_ram_we_n]

set_property -dict {PACKAGE_PIN Y21 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[0]}]
set_property -dict {PACKAGE_PIN Y26 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[1]}]
set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[2]}]
set_property -dict {PACKAGE_PIN Y22 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[3]}]
set_property -dict {PACKAGE_PIN Y23 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[4]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[5]}]
set_property -dict {PACKAGE_PIN T23 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[6]}]
set_property -dict {PACKAGE_PIN T24 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[7]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[8]}]
set_property -dict {PACKAGE_PIN V24 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[9]}]
set_property -dict {PACKAGE_PIN W26 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[10]}]
set_property -dict {PACKAGE_PIN W24 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[11]}]
set_property -dict {PACKAGE_PIN Y25 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[12]}]
set_property -dict {PACKAGE_PIN W23 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[13]}]
set_property -dict {PACKAGE_PIN W21 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[14]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[15]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[16]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[17]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[18]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {ext_ram_addr[19]}]
set_property -dict {PACKAGE_PIN U26 IOSTANDARD LVCMOS33} [get_ports {ext_ram_be_n[0]}]
set_property -dict {PACKAGE_PIN T25 IOSTANDARD LVCMOS33} [get_ports {ext_ram_be_n[1]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {ext_ram_be_n[2]}]
set_property -dict {PACKAGE_PIN R21 IOSTANDARD LVCMOS33} [get_ports {ext_ram_be_n[3]}]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[0]}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[1]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[2]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[3]}]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[4]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[5]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[6]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[7]}]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[8]}]
set_property -dict {PACKAGE_PIN W25 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[9]}]
set_property -dict {PACKAGE_PIN V23 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[10]}]
set_property -dict {PACKAGE_PIN V21 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[11]}]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[12]}]
set_property -dict {PACKAGE_PIN V26 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[13]}]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[14]}]
set_property -dict {PACKAGE_PIN U25 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[15]}]
set_property -dict {PACKAGE_PIN AC24 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[16]}]
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[17]}]
set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[18]}]
set_property -dict {PACKAGE_PIN AB24 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[19]}]
set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[20]}]
set_property -dict {PACKAGE_PIN AA24 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[21]}]
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[22]}]
set_property -dict {PACKAGE_PIN AA23 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[23]}]
set_property -dict {PACKAGE_PIN R25 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[24]}]
set_property -dict {PACKAGE_PIN R23 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[25]}]
set_property -dict {PACKAGE_PIN R26 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[26]}]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[27]}]
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[28]}]
set_property -dict {PACKAGE_PIN R22 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[29]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[30]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {ext_ram_data[31]}]
set_property -dict {PACKAGE_PIN Y20 IOSTANDARD LVCMOS33} [get_ports ext_ram_ce_n]
set_property -dict {PACKAGE_PIN U24 IOSTANDARD LVCMOS33} [get_ports ext_ram_oe_n]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports ext_ram_we_n]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]



set_max_delay -datapath_only -from [get_cells -hierarchical *cdom_buffer*] -to [get_cells -hierarchical *cdom_sync0*] 10.000


set_max_delay -datapath_only -from [get_cells -hierarchical *cdom_pulse_toggle_in_reg*] -to [get_cells -hierarchical {*cdom_pulse_sync_reg[0]*}] 10.000


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list eth_mac_inst/inst/tri_mode_ethernet_mac_i/rgmii_interface/CLK]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[0]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[1]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[2]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[3]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[4]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[5]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[6]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[0]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[1]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[2]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[3]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[4]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[5]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[6]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list router_inst/router_core_i/to_cpu]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets eth_rx_mac_aclk]
