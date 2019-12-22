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












connect_debug_port dbg_hub/clk [get_nets clk_20M]



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
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {router_inst/router_core_i/arp_module_inst/arp_write_state[0]} {router_inst/router_core_i/arp_module_inst/arp_write_state[1]} {router_inst/router_core_i/arp_module_inst/arp_write_state[2]} {router_inst/router_core_i/arp_module_inst/arp_write_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 4 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {router_inst/router_core_i/arp_module_inst/arp_read_state[0]} {router_inst/router_core_i/arp_module_inst/arp_read_state[1]} {router_inst/router_core_i/arp_module_inst/arp_read_state[2]} {router_inst/router_core_i/arp_module_inst/arp_read_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {router_inst/router_core_i/arp_module_inst/next_read_state[0]} {router_inst/router_core_i/arp_module_inst/next_read_state[1]} {router_inst/router_core_i/arp_module_inst/next_read_state[2]} {router_inst/router_core_i/arp_module_inst/next_read_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {router_inst/router_core_i/arp_module_inst/next_write_state[0]} {router_inst/router_core_i/arp_module_inst/next_write_state[1]} {router_inst/router_core_i/arp_module_inst/next_write_state[2]} {router_inst/router_core_i/arp_module_inst/next_write_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {router_inst/router_core_i/lookup_table_trie_inst/query_out_nextport[0]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nextport[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[0]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[1]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[2]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[3]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[4]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[5]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[6]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[7]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[8]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[9]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[10]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[11]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[12]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[13]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[14]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[15]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[16]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[17]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[18]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[19]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[20]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[21]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[22]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[23]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[24]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[25]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[26]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[27]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[28]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[29]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[30]} {router_inst/router_core_i/lookup_table_trie_inst/query_out_nexthop[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[0]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[1]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[2]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[3]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[4]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[5]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[6]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[7]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[8]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[9]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[10]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[11]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[12]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[13]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[14]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[15]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[16]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[17]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[18]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[19]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[20]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[21]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[22]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[23]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[24]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[25]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[26]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[27]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[28]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[29]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[30]} {router_inst/router_core_i/lookup_table_trie_inst/query_in_addr[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 3 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {router_inst/router_core_i/pkg_classify_inst/read_state[0]} {router_inst/router_core_i/pkg_classify_inst/read_state[1]} {router_inst/router_core_i/pkg_classify_inst/read_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 3 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {router_inst/router_core_i/pkg_classify_inst/next_read_state[0]} {router_inst/router_core_i/pkg_classify_inst/next_read_state[1]} {router_inst/router_core_i/pkg_classify_inst/next_read_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 8 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {router_inst/cpu_rx_axis_tdata[0]} {router_inst/cpu_rx_axis_tdata[1]} {router_inst/cpu_rx_axis_tdata[2]} {router_inst/cpu_rx_axis_tdata[3]} {router_inst/cpu_rx_axis_tdata[4]} {router_inst/cpu_rx_axis_tdata[5]} {router_inst/cpu_rx_axis_tdata[6]} {router_inst/cpu_rx_axis_tdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {router_inst/lookup_modify_in_addr_router[0]} {router_inst/lookup_modify_in_addr_router[1]} {router_inst/lookup_modify_in_addr_router[2]} {router_inst/lookup_modify_in_addr_router[3]} {router_inst/lookup_modify_in_addr_router[4]} {router_inst/lookup_modify_in_addr_router[5]} {router_inst/lookup_modify_in_addr_router[6]} {router_inst/lookup_modify_in_addr_router[7]} {router_inst/lookup_modify_in_addr_router[8]} {router_inst/lookup_modify_in_addr_router[9]} {router_inst/lookup_modify_in_addr_router[10]} {router_inst/lookup_modify_in_addr_router[11]} {router_inst/lookup_modify_in_addr_router[12]} {router_inst/lookup_modify_in_addr_router[13]} {router_inst/lookup_modify_in_addr_router[14]} {router_inst/lookup_modify_in_addr_router[15]} {router_inst/lookup_modify_in_addr_router[16]} {router_inst/lookup_modify_in_addr_router[17]} {router_inst/lookup_modify_in_addr_router[18]} {router_inst/lookup_modify_in_addr_router[19]} {router_inst/lookup_modify_in_addr_router[20]} {router_inst/lookup_modify_in_addr_router[21]} {router_inst/lookup_modify_in_addr_router[22]} {router_inst/lookup_modify_in_addr_router[23]} {router_inst/lookup_modify_in_addr_router[24]} {router_inst/lookup_modify_in_addr_router[25]} {router_inst/lookup_modify_in_addr_router[26]} {router_inst/lookup_modify_in_addr_router[27]} {router_inst/lookup_modify_in_addr_router[28]} {router_inst/lookup_modify_in_addr_router[29]} {router_inst/lookup_modify_in_addr_router[30]} {router_inst/lookup_modify_in_addr_router[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 9 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {router_inst/fifo_router2cpu_din[0]} {router_inst/fifo_router2cpu_din[1]} {router_inst/fifo_router2cpu_din[2]} {router_inst/fifo_router2cpu_din[3]} {router_inst/fifo_router2cpu_din[4]} {router_inst/fifo_router2cpu_din[5]} {router_inst/fifo_router2cpu_din[6]} {router_inst/fifo_router2cpu_din[7]} {router_inst/fifo_router2cpu_din[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 32 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {router_inst/lookup_modify_in_nexthop_router[0]} {router_inst/lookup_modify_in_nexthop_router[1]} {router_inst/lookup_modify_in_nexthop_router[2]} {router_inst/lookup_modify_in_nexthop_router[3]} {router_inst/lookup_modify_in_nexthop_router[4]} {router_inst/lookup_modify_in_nexthop_router[5]} {router_inst/lookup_modify_in_nexthop_router[6]} {router_inst/lookup_modify_in_nexthop_router[7]} {router_inst/lookup_modify_in_nexthop_router[8]} {router_inst/lookup_modify_in_nexthop_router[9]} {router_inst/lookup_modify_in_nexthop_router[10]} {router_inst/lookup_modify_in_nexthop_router[11]} {router_inst/lookup_modify_in_nexthop_router[12]} {router_inst/lookup_modify_in_nexthop_router[13]} {router_inst/lookup_modify_in_nexthop_router[14]} {router_inst/lookup_modify_in_nexthop_router[15]} {router_inst/lookup_modify_in_nexthop_router[16]} {router_inst/lookup_modify_in_nexthop_router[17]} {router_inst/lookup_modify_in_nexthop_router[18]} {router_inst/lookup_modify_in_nexthop_router[19]} {router_inst/lookup_modify_in_nexthop_router[20]} {router_inst/lookup_modify_in_nexthop_router[21]} {router_inst/lookup_modify_in_nexthop_router[22]} {router_inst/lookup_modify_in_nexthop_router[23]} {router_inst/lookup_modify_in_nexthop_router[24]} {router_inst/lookup_modify_in_nexthop_router[25]} {router_inst/lookup_modify_in_nexthop_router[26]} {router_inst/lookup_modify_in_nexthop_router[27]} {router_inst/lookup_modify_in_nexthop_router[28]} {router_inst/lookup_modify_in_nexthop_router[29]} {router_inst/lookup_modify_in_nexthop_router[30]} {router_inst/lookup_modify_in_nexthop_router[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 9 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {router_inst/fifo_cpu2router_dout[0]} {router_inst/fifo_cpu2router_dout[1]} {router_inst/fifo_cpu2router_dout[2]} {router_inst/fifo_cpu2router_dout[3]} {router_inst/fifo_cpu2router_dout[4]} {router_inst/fifo_cpu2router_dout[5]} {router_inst/fifo_cpu2router_dout[6]} {router_inst/fifo_cpu2router_dout[7]} {router_inst/fifo_cpu2router_dout[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 12 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[0]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[1]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[2]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[3]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[4]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[5]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[6]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[7]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[8]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[9]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[10]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 3 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/next_state[0]} {router_inst/router_core_i/buffer_pushing_i/next_state[1]} {router_inst/router_core_i/buffer_pushing_i/next_state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 12 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/start_addr[0]} {router_inst/router_core_i/buffer_pushing_i/start_addr[1]} {router_inst/router_core_i/buffer_pushing_i/start_addr[2]} {router_inst/router_core_i/buffer_pushing_i/start_addr[3]} {router_inst/router_core_i/buffer_pushing_i/start_addr[4]} {router_inst/router_core_i/buffer_pushing_i/start_addr[5]} {router_inst/router_core_i/buffer_pushing_i/start_addr[6]} {router_inst/router_core_i/buffer_pushing_i/start_addr[7]} {router_inst/router_core_i/buffer_pushing_i/start_addr[8]} {router_inst/router_core_i/buffer_pushing_i/start_addr[9]} {router_inst/router_core_i/buffer_pushing_i/start_addr[10]} {router_inst/router_core_i/buffer_pushing_i/start_addr[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 12 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[0]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[1]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[2]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[3]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[4]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[5]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[6]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[7]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[8]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[9]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[10]} {router_inst/router_core_i/buffer_pushing_i/mem_read_addr[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 12 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[0]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[1]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[2]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[3]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[4]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[5]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[6]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[7]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[8]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[9]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[10]} {router_inst/router_core_i/buffer_pushing_i/job_cur_mem_addr[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 8 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/mem_read_data[0]} {router_inst/router_core_i/buffer_pushing_i/mem_read_data[1]} {router_inst/router_core_i/buffer_pushing_i/mem_read_data[2]} {router_inst/router_core_i/buffer_pushing_i/mem_read_data[3]} {router_inst/router_core_i/buffer_pushing_i/mem_read_data[4]} {router_inst/router_core_i/buffer_pushing_i/mem_read_data[5]} {router_inst/router_core_i/buffer_pushing_i/mem_read_data[6]} {router_inst/router_core_i/buffer_pushing_i/mem_read_data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 3 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/state[0]} {router_inst/router_core_i/buffer_pushing_i/state[1]} {router_inst/router_core_i/buffer_pushing_i/state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 12 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[0]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[1]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[2]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[3]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[4]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[5]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[6]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[7]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[8]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[9]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[10]} {router_inst/router_core_i/buffer_pushing_i/job_end_mem_addr_r[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 8 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[0]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[1]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[2]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[3]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[4]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[5]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[6]} {router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 8 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[0]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[1]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[2]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[3]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[4]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[5]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[6]} {router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 5 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {router_inst/router_core_i/ipv4_module_inst/ipv4_read_state[0]} {router_inst/router_core_i/ipv4_module_inst/ipv4_read_state[1]} {router_inst/router_core_i/ipv4_module_inst/ipv4_read_state[2]} {router_inst/router_core_i/ipv4_module_inst/ipv4_read_state[3]} {router_inst/router_core_i/ipv4_module_inst/ipv4_read_state[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 5 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {router_inst/router_core_i/ipv4_module_inst/ipv4_write_state[0]} {router_inst/router_core_i/ipv4_module_inst/ipv4_write_state[1]} {router_inst/router_core_i/ipv4_module_inst/ipv4_write_state[2]} {router_inst/router_core_i/ipv4_module_inst/ipv4_write_state[3]} {router_inst/router_core_i/ipv4_module_inst/ipv4_write_state[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 24 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {router_inst/router_core_i/ipv4_module_inst/checksum[0]} {router_inst/router_core_i/ipv4_module_inst/checksum[1]} {router_inst/router_core_i/ipv4_module_inst/checksum[2]} {router_inst/router_core_i/ipv4_module_inst/checksum[3]} {router_inst/router_core_i/ipv4_module_inst/checksum[4]} {router_inst/router_core_i/ipv4_module_inst/checksum[5]} {router_inst/router_core_i/ipv4_module_inst/checksum[6]} {router_inst/router_core_i/ipv4_module_inst/checksum[7]} {router_inst/router_core_i/ipv4_module_inst/checksum[8]} {router_inst/router_core_i/ipv4_module_inst/checksum[9]} {router_inst/router_core_i/ipv4_module_inst/checksum[10]} {router_inst/router_core_i/ipv4_module_inst/checksum[11]} {router_inst/router_core_i/ipv4_module_inst/checksum[12]} {router_inst/router_core_i/ipv4_module_inst/checksum[13]} {router_inst/router_core_i/ipv4_module_inst/checksum[14]} {router_inst/router_core_i/ipv4_module_inst/checksum[15]} {router_inst/router_core_i/ipv4_module_inst/checksum[16]} {router_inst/router_core_i/ipv4_module_inst/checksum[17]} {router_inst/router_core_i/ipv4_module_inst/checksum[18]} {router_inst/router_core_i/ipv4_module_inst/checksum[19]} {router_inst/router_core_i/ipv4_module_inst/checksum[20]} {router_inst/router_core_i/ipv4_module_inst/checksum[21]} {router_inst/router_core_i/ipv4_module_inst/checksum[22]} {router_inst/router_core_i/ipv4_module_inst/checksum[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 5 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {router_inst/router_core_i/ipv4_module_inst/next_read_state[0]} {router_inst/router_core_i/ipv4_module_inst/next_read_state[1]} {router_inst/router_core_i/ipv4_module_inst/next_read_state[2]} {router_inst/router_core_i/ipv4_module_inst/next_read_state[3]} {router_inst/router_core_i/ipv4_module_inst/next_read_state[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 5 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {router_inst/router_core_i/ipv4_module_inst/next_write_state[0]} {router_inst/router_core_i/ipv4_module_inst/next_write_state[1]} {router_inst/router_core_i/ipv4_module_inst/next_write_state[2]} {router_inst/router_core_i/ipv4_module_inst/next_write_state[3]} {router_inst/router_core_i/ipv4_module_inst/next_write_state[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list router_inst/cpu_rx_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list router_inst/cpu_rx_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list router_inst/cpu_rx_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list router_inst/cpu_tx_axis_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list router_inst/cpu_tx_axis_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list router_inst/cpu_tx_axis_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list router_inst/fifo_cpu2router_empty]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list router_inst/fifo_cpu2router_rd_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list router_inst/fifo_router2cpu_full]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list router_inst/fifo_router2cpu_wr_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list router_inst/ip_modify_req_router]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list router_inst/router_core_i/buffer_pushing_i/is_last]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list router_inst/lookup_modify_in_ready_router]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list router_inst/router_core_i/buffer_pushing_i/mem_read_ena]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list router_inst/router_core_i/lookup_table_trie_inst/query_in_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list router_inst/router_core_i/lookup_table_trie_inst/query_out_ready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe47]
set_property port_width 1 [get_debug_ports u_ila_0/probe47]
connect_debug_port u_ila_0/probe47 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/rx_axis_fifo_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe48]
set_property port_width 1 [get_debug_ports u_ila_0/probe48]
connect_debug_port u_ila_0/probe48 [get_nets [list router_inst/router_core_i/buffer_pushing_i/to_cpu]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe49]
set_property port_width 1 [get_debug_ports u_ila_0/probe49]
connect_debug_port u_ila_0/probe49 [get_nets [list router_inst/router_core_i/buffer_pushing_i/to_cpu_r]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe50]
set_property port_width 1 [get_debug_ports u_ila_0/probe50]
connect_debug_port u_ila_0/probe50 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe51]
set_property port_width 1 [get_debug_ports u_ila_0/probe51]
connect_debug_port u_ila_0/probe51 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe52]
set_property port_width 1 [get_debug_ports u_ila_0/probe52]
connect_debug_port u_ila_0/probe52 [get_nets [list router_inst/router_core_i/eth_mac_wraper_i/tx_axis_fifo_tvalid]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list clock_gen/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 32 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {CPU/wb_wdata_i[0]} {CPU/wb_wdata_i[1]} {CPU/wb_wdata_i[2]} {CPU/wb_wdata_i[3]} {CPU/wb_wdata_i[4]} {CPU/wb_wdata_i[5]} {CPU/wb_wdata_i[6]} {CPU/wb_wdata_i[7]} {CPU/wb_wdata_i[8]} {CPU/wb_wdata_i[9]} {CPU/wb_wdata_i[10]} {CPU/wb_wdata_i[11]} {CPU/wb_wdata_i[12]} {CPU/wb_wdata_i[13]} {CPU/wb_wdata_i[14]} {CPU/wb_wdata_i[15]} {CPU/wb_wdata_i[16]} {CPU/wb_wdata_i[17]} {CPU/wb_wdata_i[18]} {CPU/wb_wdata_i[19]} {CPU/wb_wdata_i[20]} {CPU/wb_wdata_i[21]} {CPU/wb_wdata_i[22]} {CPU/wb_wdata_i[23]} {CPU/wb_wdata_i[24]} {CPU/wb_wdata_i[25]} {CPU/wb_wdata_i[26]} {CPU/wb_wdata_i[27]} {CPU/wb_wdata_i[28]} {CPU/wb_wdata_i[29]} {CPU/wb_wdata_i[30]} {CPU/wb_wdata_i[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 32 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {CPU/reg1_data[0]} {CPU/reg1_data[1]} {CPU/reg1_data[2]} {CPU/reg1_data[3]} {CPU/reg1_data[4]} {CPU/reg1_data[5]} {CPU/reg1_data[6]} {CPU/reg1_data[7]} {CPU/reg1_data[8]} {CPU/reg1_data[9]} {CPU/reg1_data[10]} {CPU/reg1_data[11]} {CPU/reg1_data[12]} {CPU/reg1_data[13]} {CPU/reg1_data[14]} {CPU/reg1_data[15]} {CPU/reg1_data[16]} {CPU/reg1_data[17]} {CPU/reg1_data[18]} {CPU/reg1_data[19]} {CPU/reg1_data[20]} {CPU/reg1_data[21]} {CPU/reg1_data[22]} {CPU/reg1_data[23]} {CPU/reg1_data[24]} {CPU/reg1_data[25]} {CPU/reg1_data[26]} {CPU/reg1_data[27]} {CPU/reg1_data[28]} {CPU/reg1_data[29]} {CPU/reg1_data[30]} {CPU/reg1_data[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 5 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {CPU/reg2_addr[0]} {CPU/reg2_addr[1]} {CPU/reg2_addr[2]} {CPU/reg2_addr[3]} {CPU/reg2_addr[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 32 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {CPU/reg2_data[0]} {CPU/reg2_data[1]} {CPU/reg2_data[2]} {CPU/reg2_data[3]} {CPU/reg2_data[4]} {CPU/reg2_data[5]} {CPU/reg2_data[6]} {CPU/reg2_data[7]} {CPU/reg2_data[8]} {CPU/reg2_data[9]} {CPU/reg2_data[10]} {CPU/reg2_data[11]} {CPU/reg2_data[12]} {CPU/reg2_data[13]} {CPU/reg2_data[14]} {CPU/reg2_data[15]} {CPU/reg2_data[16]} {CPU/reg2_data[17]} {CPU/reg2_data[18]} {CPU/reg2_data[19]} {CPU/reg2_data[20]} {CPU/reg2_data[21]} {CPU/reg2_data[22]} {CPU/reg2_data[23]} {CPU/reg2_data[24]} {CPU/reg2_data[25]} {CPU/reg2_data[26]} {CPU/reg2_data[27]} {CPU/reg2_data[28]} {CPU/reg2_data[29]} {CPU/reg2_data[30]} {CPU/reg2_data[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 32 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list {CPU/pc_data_i[0]} {CPU/pc_data_i[1]} {CPU/pc_data_i[2]} {CPU/pc_data_i[3]} {CPU/pc_data_i[4]} {CPU/pc_data_i[5]} {CPU/pc_data_i[6]} {CPU/pc_data_i[7]} {CPU/pc_data_i[8]} {CPU/pc_data_i[9]} {CPU/pc_data_i[10]} {CPU/pc_data_i[11]} {CPU/pc_data_i[12]} {CPU/pc_data_i[13]} {CPU/pc_data_i[14]} {CPU/pc_data_i[15]} {CPU/pc_data_i[16]} {CPU/pc_data_i[17]} {CPU/pc_data_i[18]} {CPU/pc_data_i[19]} {CPU/pc_data_i[20]} {CPU/pc_data_i[21]} {CPU/pc_data_i[22]} {CPU/pc_data_i[23]} {CPU/pc_data_i[24]} {CPU/pc_data_i[25]} {CPU/pc_data_i[26]} {CPU/pc_data_i[27]} {CPU/pc_data_i[28]} {CPU/pc_data_i[29]} {CPU/pc_data_i[30]} {CPU/pc_data_i[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 5 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list {CPU/reg1_addr[0]} {CPU/reg1_addr[1]} {CPU/reg1_addr[2]} {CPU/reg1_addr[3]} {CPU/reg1_addr[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 5 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list {CPU/wb_wd_i[0]} {CPU/wb_wd_i[1]} {CPU/wb_wd_i[2]} {CPU/wb_wd_i[3]} {CPU/wb_wd_i[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 32 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list {CPU/REGFILE/rdata2[0]} {CPU/REGFILE/rdata2[1]} {CPU/REGFILE/rdata2[2]} {CPU/REGFILE/rdata2[3]} {CPU/REGFILE/rdata2[4]} {CPU/REGFILE/rdata2[5]} {CPU/REGFILE/rdata2[6]} {CPU/REGFILE/rdata2[7]} {CPU/REGFILE/rdata2[8]} {CPU/REGFILE/rdata2[9]} {CPU/REGFILE/rdata2[10]} {CPU/REGFILE/rdata2[11]} {CPU/REGFILE/rdata2[12]} {CPU/REGFILE/rdata2[13]} {CPU/REGFILE/rdata2[14]} {CPU/REGFILE/rdata2[15]} {CPU/REGFILE/rdata2[16]} {CPU/REGFILE/rdata2[17]} {CPU/REGFILE/rdata2[18]} {CPU/REGFILE/rdata2[19]} {CPU/REGFILE/rdata2[20]} {CPU/REGFILE/rdata2[21]} {CPU/REGFILE/rdata2[22]} {CPU/REGFILE/rdata2[23]} {CPU/REGFILE/rdata2[24]} {CPU/REGFILE/rdata2[25]} {CPU/REGFILE/rdata2[26]} {CPU/REGFILE/rdata2[27]} {CPU/REGFILE/rdata2[28]} {CPU/REGFILE/rdata2[29]} {CPU/REGFILE/rdata2[30]} {CPU/REGFILE/rdata2[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 5 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list {CPU/REGFILE/raddr1[0]} {CPU/REGFILE/raddr1[1]} {CPU/REGFILE/raddr1[2]} {CPU/REGFILE/raddr1[3]} {CPU/REGFILE/raddr1[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 5 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list {CPU/REGFILE/raddr2[0]} {CPU/REGFILE/raddr2[1]} {CPU/REGFILE/raddr2[2]} {CPU/REGFILE/raddr2[3]} {CPU/REGFILE/raddr2[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe10]
set_property port_width 32 [get_debug_ports u_ila_1/probe10]
connect_debug_port u_ila_1/probe10 [get_nets [list {CPU/REGFILE/rdata1[0]} {CPU/REGFILE/rdata1[1]} {CPU/REGFILE/rdata1[2]} {CPU/REGFILE/rdata1[3]} {CPU/REGFILE/rdata1[4]} {CPU/REGFILE/rdata1[5]} {CPU/REGFILE/rdata1[6]} {CPU/REGFILE/rdata1[7]} {CPU/REGFILE/rdata1[8]} {CPU/REGFILE/rdata1[9]} {CPU/REGFILE/rdata1[10]} {CPU/REGFILE/rdata1[11]} {CPU/REGFILE/rdata1[12]} {CPU/REGFILE/rdata1[13]} {CPU/REGFILE/rdata1[14]} {CPU/REGFILE/rdata1[15]} {CPU/REGFILE/rdata1[16]} {CPU/REGFILE/rdata1[17]} {CPU/REGFILE/rdata1[18]} {CPU/REGFILE/rdata1[19]} {CPU/REGFILE/rdata1[20]} {CPU/REGFILE/rdata1[21]} {CPU/REGFILE/rdata1[22]} {CPU/REGFILE/rdata1[23]} {CPU/REGFILE/rdata1[24]} {CPU/REGFILE/rdata1[25]} {CPU/REGFILE/rdata1[26]} {CPU/REGFILE/rdata1[27]} {CPU/REGFILE/rdata1[28]} {CPU/REGFILE/rdata1[29]} {CPU/REGFILE/rdata1[30]} {CPU/REGFILE/rdata1[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe11]
set_property port_width 5 [get_debug_ports u_ila_1/probe11]
connect_debug_port u_ila_1/probe11 [get_nets [list {CPU/REGFILE/waddr[0]} {CPU/REGFILE/waddr[1]} {CPU/REGFILE/waddr[2]} {CPU/REGFILE/waddr[3]} {CPU/REGFILE/waddr[4]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe12]
set_property port_width 32 [get_debug_ports u_ila_1/probe12]
connect_debug_port u_ila_1/probe12 [get_nets [list {CPU/REGFILE/wdata[0]} {CPU/REGFILE/wdata[1]} {CPU/REGFILE/wdata[2]} {CPU/REGFILE/wdata[3]} {CPU/REGFILE/wdata[4]} {CPU/REGFILE/wdata[5]} {CPU/REGFILE/wdata[6]} {CPU/REGFILE/wdata[7]} {CPU/REGFILE/wdata[8]} {CPU/REGFILE/wdata[9]} {CPU/REGFILE/wdata[10]} {CPU/REGFILE/wdata[11]} {CPU/REGFILE/wdata[12]} {CPU/REGFILE/wdata[13]} {CPU/REGFILE/wdata[14]} {CPU/REGFILE/wdata[15]} {CPU/REGFILE/wdata[16]} {CPU/REGFILE/wdata[17]} {CPU/REGFILE/wdata[18]} {CPU/REGFILE/wdata[19]} {CPU/REGFILE/wdata[20]} {CPU/REGFILE/wdata[21]} {CPU/REGFILE/wdata[22]} {CPU/REGFILE/wdata[23]} {CPU/REGFILE/wdata[24]} {CPU/REGFILE/wdata[25]} {CPU/REGFILE/wdata[26]} {CPU/REGFILE/wdata[27]} {CPU/REGFILE/wdata[28]} {CPU/REGFILE/wdata[29]} {CPU/REGFILE/wdata[30]} {CPU/REGFILE/wdata[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe13]
set_property port_width 4 [get_debug_ports u_ila_1/probe13]
connect_debug_port u_ila_1/probe13 [get_nets [list {router_inst/cpu_rx_qword_tlast[0]} {router_inst/cpu_rx_qword_tlast[1]} {router_inst/cpu_rx_qword_tlast[2]} {router_inst/cpu_rx_qword_tlast[3]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe14]
set_property port_width 36 [get_debug_ports u_ila_1/probe14]
connect_debug_port u_ila_1/probe14 [get_nets [list {router_inst/fifo_cpu2router_din[0]} {router_inst/fifo_cpu2router_din[1]} {router_inst/fifo_cpu2router_din[2]} {router_inst/fifo_cpu2router_din[3]} {router_inst/fifo_cpu2router_din[4]} {router_inst/fifo_cpu2router_din[5]} {router_inst/fifo_cpu2router_din[6]} {router_inst/fifo_cpu2router_din[7]} {router_inst/fifo_cpu2router_din[8]} {router_inst/fifo_cpu2router_din[9]} {router_inst/fifo_cpu2router_din[10]} {router_inst/fifo_cpu2router_din[11]} {router_inst/fifo_cpu2router_din[12]} {router_inst/fifo_cpu2router_din[13]} {router_inst/fifo_cpu2router_din[14]} {router_inst/fifo_cpu2router_din[15]} {router_inst/fifo_cpu2router_din[16]} {router_inst/fifo_cpu2router_din[17]} {router_inst/fifo_cpu2router_din[18]} {router_inst/fifo_cpu2router_din[19]} {router_inst/fifo_cpu2router_din[20]} {router_inst/fifo_cpu2router_din[21]} {router_inst/fifo_cpu2router_din[22]} {router_inst/fifo_cpu2router_din[23]} {router_inst/fifo_cpu2router_din[24]} {router_inst/fifo_cpu2router_din[25]} {router_inst/fifo_cpu2router_din[26]} {router_inst/fifo_cpu2router_din[27]} {router_inst/fifo_cpu2router_din[28]} {router_inst/fifo_cpu2router_din[29]} {router_inst/fifo_cpu2router_din[30]} {router_inst/fifo_cpu2router_din[31]} {router_inst/fifo_cpu2router_din[32]} {router_inst/fifo_cpu2router_din[33]} {router_inst/fifo_cpu2router_din[34]} {router_inst/fifo_cpu2router_din[35]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe15]
set_property port_width 7 [get_debug_ports u_ila_1/probe15]
connect_debug_port u_ila_1/probe15 [get_nets [list {router_controller_inst/router_controller_in_inst/cur_index[0]} {router_controller_inst/router_controller_in_inst/cur_index[1]} {router_controller_inst/router_controller_in_inst/cur_index[2]} {router_controller_inst/router_controller_in_inst/cur_index[3]} {router_controller_inst/router_controller_in_inst/cur_index[4]} {router_controller_inst/router_controller_in_inst/cur_index[5]} {router_controller_inst/router_controller_in_inst/cur_index[6]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe16]
set_property port_width 32 [get_debug_ports u_ila_1/probe16]
connect_debug_port u_ila_1/probe16 [get_nets [list {router_inst/cpu_rx_qword_tdata[0]} {router_inst/cpu_rx_qword_tdata[1]} {router_inst/cpu_rx_qword_tdata[2]} {router_inst/cpu_rx_qword_tdata[3]} {router_inst/cpu_rx_qword_tdata[4]} {router_inst/cpu_rx_qword_tdata[5]} {router_inst/cpu_rx_qword_tdata[6]} {router_inst/cpu_rx_qword_tdata[7]} {router_inst/cpu_rx_qword_tdata[8]} {router_inst/cpu_rx_qword_tdata[9]} {router_inst/cpu_rx_qword_tdata[10]} {router_inst/cpu_rx_qword_tdata[11]} {router_inst/cpu_rx_qword_tdata[12]} {router_inst/cpu_rx_qword_tdata[13]} {router_inst/cpu_rx_qword_tdata[14]} {router_inst/cpu_rx_qword_tdata[15]} {router_inst/cpu_rx_qword_tdata[16]} {router_inst/cpu_rx_qword_tdata[17]} {router_inst/cpu_rx_qword_tdata[18]} {router_inst/cpu_rx_qword_tdata[19]} {router_inst/cpu_rx_qword_tdata[20]} {router_inst/cpu_rx_qword_tdata[21]} {router_inst/cpu_rx_qword_tdata[22]} {router_inst/cpu_rx_qword_tdata[23]} {router_inst/cpu_rx_qword_tdata[24]} {router_inst/cpu_rx_qword_tdata[25]} {router_inst/cpu_rx_qword_tdata[26]} {router_inst/cpu_rx_qword_tdata[27]} {router_inst/cpu_rx_qword_tdata[28]} {router_inst/cpu_rx_qword_tdata[29]} {router_inst/cpu_rx_qword_tdata[30]} {router_inst/cpu_rx_qword_tdata[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe17]
set_property port_width 36 [get_debug_ports u_ila_1/probe17]
connect_debug_port u_ila_1/probe17 [get_nets [list {router_inst/fifo_router2cpu_dout[0]} {router_inst/fifo_router2cpu_dout[1]} {router_inst/fifo_router2cpu_dout[2]} {router_inst/fifo_router2cpu_dout[3]} {router_inst/fifo_router2cpu_dout[4]} {router_inst/fifo_router2cpu_dout[5]} {router_inst/fifo_router2cpu_dout[6]} {router_inst/fifo_router2cpu_dout[7]} {router_inst/fifo_router2cpu_dout[8]} {router_inst/fifo_router2cpu_dout[9]} {router_inst/fifo_router2cpu_dout[10]} {router_inst/fifo_router2cpu_dout[11]} {router_inst/fifo_router2cpu_dout[12]} {router_inst/fifo_router2cpu_dout[13]} {router_inst/fifo_router2cpu_dout[14]} {router_inst/fifo_router2cpu_dout[15]} {router_inst/fifo_router2cpu_dout[16]} {router_inst/fifo_router2cpu_dout[17]} {router_inst/fifo_router2cpu_dout[18]} {router_inst/fifo_router2cpu_dout[19]} {router_inst/fifo_router2cpu_dout[20]} {router_inst/fifo_router2cpu_dout[21]} {router_inst/fifo_router2cpu_dout[22]} {router_inst/fifo_router2cpu_dout[23]} {router_inst/fifo_router2cpu_dout[24]} {router_inst/fifo_router2cpu_dout[25]} {router_inst/fifo_router2cpu_dout[26]} {router_inst/fifo_router2cpu_dout[27]} {router_inst/fifo_router2cpu_dout[28]} {router_inst/fifo_router2cpu_dout[29]} {router_inst/fifo_router2cpu_dout[30]} {router_inst/fifo_router2cpu_dout[31]} {router_inst/fifo_router2cpu_dout[32]} {router_inst/fifo_router2cpu_dout[33]} {router_inst/fifo_router2cpu_dout[34]} {router_inst/fifo_router2cpu_dout[35]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe18]
set_property port_width 32 [get_debug_ports u_ila_1/probe18]
connect_debug_port u_ila_1/probe18 [get_nets [list {mem_data_o[0]} {mem_data_o[1]} {mem_data_o[2]} {mem_data_o[3]} {mem_data_o[4]} {mem_data_o[5]} {mem_data_o[6]} {mem_data_o[7]} {mem_data_o[8]} {mem_data_o[9]} {mem_data_o[10]} {mem_data_o[11]} {mem_data_o[12]} {mem_data_o[13]} {mem_data_o[14]} {mem_data_o[15]} {mem_data_o[16]} {mem_data_o[17]} {mem_data_o[18]} {mem_data_o[19]} {mem_data_o[20]} {mem_data_o[21]} {mem_data_o[22]} {mem_data_o[23]} {mem_data_o[24]} {mem_data_o[25]} {mem_data_o[26]} {mem_data_o[27]} {mem_data_o[28]} {mem_data_o[29]} {mem_data_o[30]} {mem_data_o[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe19]
set_property port_width 32 [get_debug_ports u_ila_1/probe19]
connect_debug_port u_ila_1/probe19 [get_nets [list {mem_data_i[0]} {mem_data_i[1]} {mem_data_i[2]} {mem_data_i[3]} {mem_data_i[4]} {mem_data_i[5]} {mem_data_i[6]} {mem_data_i[7]} {mem_data_i[8]} {mem_data_i[9]} {mem_data_i[10]} {mem_data_i[11]} {mem_data_i[12]} {mem_data_i[13]} {mem_data_i[14]} {mem_data_i[15]} {mem_data_i[16]} {mem_data_i[17]} {mem_data_i[18]} {mem_data_i[19]} {mem_data_i[20]} {mem_data_i[21]} {mem_data_i[22]} {mem_data_i[23]} {mem_data_i[24]} {mem_data_i[25]} {mem_data_i[26]} {mem_data_i[27]} {mem_data_i[28]} {mem_data_i[29]} {mem_data_i[30]} {mem_data_i[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe20]
set_property port_width 32 [get_debug_ports u_ila_1/probe20]
connect_debug_port u_ila_1/probe20 [get_nets [list {pc_addr[0]} {pc_addr[1]} {pc_addr[2]} {pc_addr[3]} {pc_addr[4]} {pc_addr[5]} {pc_addr[6]} {pc_addr[7]} {pc_addr[8]} {pc_addr[9]} {pc_addr[10]} {pc_addr[11]} {pc_addr[12]} {pc_addr[13]} {pc_addr[14]} {pc_addr[15]} {pc_addr[16]} {pc_addr[17]} {pc_addr[18]} {pc_addr[19]} {pc_addr[20]} {pc_addr[21]} {pc_addr[22]} {pc_addr[23]} {pc_addr[24]} {pc_addr[25]} {pc_addr[26]} {pc_addr[27]} {pc_addr[28]} {pc_addr[29]} {pc_addr[30]} {pc_addr[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe21]
set_property port_width 32 [get_debug_ports u_ila_1/probe21]
connect_debug_port u_ila_1/probe21 [get_nets [list {pc_data[0]} {pc_data[1]} {pc_data[2]} {pc_data[3]} {pc_data[4]} {pc_data[5]} {pc_data[6]} {pc_data[7]} {pc_data[8]} {pc_data[9]} {pc_data[10]} {pc_data[11]} {pc_data[12]} {pc_data[13]} {pc_data[14]} {pc_data[15]} {pc_data[16]} {pc_data[17]} {pc_data[18]} {pc_data[19]} {pc_data[20]} {pc_data[21]} {pc_data[22]} {pc_data[23]} {pc_data[24]} {pc_data[25]} {pc_data[26]} {pc_data[27]} {pc_data[28]} {pc_data[29]} {pc_data[30]} {pc_data[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe22]
set_property port_width 32 [get_debug_ports u_ila_1/probe22]
connect_debug_port u_ila_1/probe22 [get_nets [list {mem_addr[0]} {mem_addr[1]} {mem_addr[2]} {mem_addr[3]} {mem_addr[4]} {mem_addr[5]} {mem_addr[6]} {mem_addr[7]} {mem_addr[8]} {mem_addr[9]} {mem_addr[10]} {mem_addr[11]} {mem_addr[12]} {mem_addr[13]} {mem_addr[14]} {mem_addr[15]} {mem_addr[16]} {mem_addr[17]} {mem_addr[18]} {mem_addr[19]} {mem_addr[20]} {mem_addr[21]} {mem_addr[22]} {mem_addr[23]} {mem_addr[24]} {mem_addr[25]} {mem_addr[26]} {mem_addr[27]} {mem_addr[28]} {mem_addr[29]} {mem_addr[30]} {mem_addr[31]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe23]
set_property port_width 1 [get_debug_ports u_ila_1/probe23]
connect_debug_port u_ila_1/probe23 [get_nets [list bus_inst/bus_judger_inst/cpu_mem_ok]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe24]
set_property port_width 1 [get_debug_ports u_ila_1/probe24]
connect_debug_port u_ila_1/probe24 [get_nets [list bus_inst/bus_judger_inst/cpu_mem_req]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe25]
set_property port_width 1 [get_debug_ports u_ila_1/probe25]
connect_debug_port u_ila_1/probe25 [get_nets [list bus_inst/bus_judger_inst/cpu_mem_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe26]
set_property port_width 1 [get_debug_ports u_ila_1/probe26]
connect_debug_port u_ila_1/probe26 [get_nets [list router_inst/cpu_rx_qword_tready]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe27]
set_property port_width 1 [get_debug_ports u_ila_1/probe27]
connect_debug_port u_ila_1/probe27 [get_nets [list router_inst/cpu_rx_qword_tvalid]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe28]
set_property port_width 1 [get_debug_ports u_ila_1/probe28]
connect_debug_port u_ila_1/probe28 [get_nets [list router_inst/cpu_tx_qword_tready]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe29]
set_property port_width 1 [get_debug_ports u_ila_1/probe29]
connect_debug_port u_ila_1/probe29 [get_nets [list router_inst/cpu_tx_qword_tvalid]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe30]
set_property port_width 1 [get_debug_ports u_ila_1/probe30]
connect_debug_port u_ila_1/probe30 [get_nets [list CPU/CTRL/ex_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe31]
set_property port_width 1 [get_debug_ports u_ila_1/probe31]
connect_debug_port u_ila_1/probe31 [get_nets [list router_inst/fifo_cpu2router_full]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe32]
set_property port_width 1 [get_debug_ports u_ila_1/probe32]
connect_debug_port u_ila_1/probe32 [get_nets [list router_inst/fifo_router2cpu_empty]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe33]
set_property port_width 1 [get_debug_ports u_ila_1/probe33]
connect_debug_port u_ila_1/probe33 [get_nets [list CPU/CTRL/id_req]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe34]
set_property port_width 1 [get_debug_ports u_ila_1/probe34]
connect_debug_port u_ila_1/probe34 [get_nets [list CPU/CTRL/id_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe35]
set_property port_width 1 [get_debug_ports u_ila_1/probe35]
connect_debug_port u_ila_1/probe35 [get_nets [list CPU/CTRL/if_req]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe36]
set_property port_width 1 [get_debug_ports u_ila_1/probe36]
connect_debug_port u_ila_1/probe36 [get_nets [list CPU/CTRL/if_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe37]
set_property port_width 1 [get_debug_ports u_ila_1/probe37]
connect_debug_port u_ila_1/probe37 [get_nets [list CPU/CTRL/mem_req]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe38]
set_property port_width 1 [get_debug_ports u_ila_1/probe38]
connect_debug_port u_ila_1/probe38 [get_nets [list CPU/CTRL/mem_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe39]
set_property port_width 1 [get_debug_ports u_ila_1/probe39]
connect_debug_port u_ila_1/probe39 [get_nets [list router_controller_inst/router_controller_in_inst/mem_write_en]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe40]
set_property port_width 1 [get_debug_ports u_ila_1/probe40]
connect_debug_port u_ila_1/probe40 [get_nets [list CPU/not_align]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe41]
set_property port_width 1 [get_debug_ports u_ila_1/probe41]
connect_debug_port u_ila_1/probe41 [get_nets [list router_controller_inst/router_controller_out_inst/out_state]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe42]
set_property port_width 1 [get_debug_ports u_ila_1/probe42]
connect_debug_port u_ila_1/probe42 [get_nets [list CPU/CTRL/pc_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe43]
set_property port_width 1 [get_debug_ports u_ila_1/probe43]
connect_debug_port u_ila_1/probe43 [get_nets [list CPU/REGFILE/re1]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe44]
set_property port_width 1 [get_debug_ports u_ila_1/probe44]
connect_debug_port u_ila_1/probe44 [get_nets [list CPU/REGFILE/re2]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe45]
set_property port_width 1 [get_debug_ports u_ila_1/probe45]
connect_debug_port u_ila_1/probe45 [get_nets [list CPU/reg1_read]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe46]
set_property port_width 1 [get_debug_ports u_ila_1/probe46]
connect_debug_port u_ila_1/probe46 [get_nets [list CPU/reg2_read]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe47]
set_property port_width 1 [get_debug_ports u_ila_1/probe47]
connect_debug_port u_ila_1/probe47 [get_nets [list router_controller_inst/router_controller_in_inst/restart]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe48]
set_property port_width 1 [get_debug_ports u_ila_1/probe48]
connect_debug_port u_ila_1/probe48 [get_nets [list bus_inst/bus_judger_inst/router_read_ok]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe49]
set_property port_width 1 [get_debug_ports u_ila_1/probe49]
connect_debug_port u_ila_1/probe49 [get_nets [list bus_inst/bus_judger_inst/router_read_req]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe50]
set_property port_width 1 [get_debug_ports u_ila_1/probe50]
connect_debug_port u_ila_1/probe50 [get_nets [list bus_inst/bus_judger_inst/router_read_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe51]
set_property port_width 1 [get_debug_ports u_ila_1/probe51]
connect_debug_port u_ila_1/probe51 [get_nets [list bus_inst/bus_judger_inst/router_write_ok]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe52]
set_property port_width 1 [get_debug_ports u_ila_1/probe52]
connect_debug_port u_ila_1/probe52 [get_nets [list bus_inst/bus_judger_inst/router_write_req]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe53]
set_property port_width 1 [get_debug_ports u_ila_1/probe53]
connect_debug_port u_ila_1/probe53 [get_nets [list bus_inst/bus_judger_inst/router_write_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe54]
set_property port_width 1 [get_debug_ports u_ila_1/probe54]
connect_debug_port u_ila_1/probe54 [get_nets [list CPU/CTRL/wb_stall]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe55]
set_property port_width 1 [get_debug_ports u_ila_1/probe55]
connect_debug_port u_ila_1/probe55 [get_nets [list CPU/wb_wreg_i]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe56]
set_property port_width 1 [get_debug_ports u_ila_1/probe56]
connect_debug_port u_ila_1/probe56 [get_nets [list CPU/REGFILE/we]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_10M]
