`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电�?，按下时�?1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电�?，按下时�?1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按�?开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时�?1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信�?
    output wire uart_rdn,         //读串口信号，低有�?
    output wire uart_wrn,         //写串口信号，低有�?
    input wire uart_dataready,    //串口数据准�?�好
    input wire uart_tbre,         //发送数�?标志
    input wire uart_tsre,         //数据发送完毕标�?

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共�?
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。�?�果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有�?
    output wire base_ram_oe_n,       //BaseRAM读使能，低有�?
    output wire base_ram_we_n,       //BaseRAM写使能，低有�?

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。�?�果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有�?
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有�?
    output wire ext_ram_we_n,       //ExtRAM写使能，低有�?

    //直连串口信号
    output wire txd,  //直连串口发送�??
    input  wire rxd,  //直连串口接收�?

    //Flash存储器信号，参�? JS28F640 �?片手�?
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效�?16bit模式无意�?
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧�?
    output wire flash_ce_n,         //Flash片选信号，低有�?
    output wire flash_oe_n,         //Flash读使能信号，低有�?
    output wire flash_we_n,         //Flash写使能信号，低有�?
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash�?16位模式时请�?�为1

    //USB+SD 控制器信号，参�? CH376T �?片手�?
    output wire ch376t_sdi,
    output wire ch376t_sck,
    output wire ch376t_cs_n,
    output wire ch376t_rst,
    input  wire ch376t_int_n,
    input  wire ch376t_sdo,

    //网络交换机信号，参�? KSZ8795 �?片手册及 RGMII 规范
    input  wire [3:0] eth_rgmii_rd,
    input  wire eth_rgmii_rx_ctl,
    input  wire eth_rgmii_rxc,
    output wire [3:0] eth_rgmii_td,
    output wire eth_rgmii_tx_ctl,
    output wire eth_rgmii_txc,
    output wire eth_rst_n,
    input  wire eth_int_n,

    input  wire eth_spi_miso,
    output wire eth_spi_mosi,
    output wire eth_spi_sck,
    output wire eth_spi_ss_n,

    //ͼ������ź�
    output wire[2:0] video_red,    //��ɫ���أ�3λ
    output wire[2:0] video_green,  //��ɫ���أ�3λ
    output wire[1:0] video_blue,   //��ɫ���أ�2λ
    output wire video_hsync,       //��ͬ����ˮƽͬ�����ź�
    output wire video_vsync,       //��ͬ������ֱͬ�����ź�
    output wire video_clk,         //����ʱ�����
    output wire video_de           //��������Ч�źţ���������������
);

/* =========== Demo code begin =========== */

// PLL��Ƶʾ��
wire locked, clk_10M, clk_20M, clk_125M, clk_200M;
pll_example clock_gen 
 (
  // Clock out ports
  .clk_out1(clk_10M), // ʱ�����1��Ƶ����IP���ý���������
  .clk_out2(clk_20M), // ʱ�����2��Ƶ����IP���ý���������
  .clk_out3(clk_125M), // ʱ�����3��Ƶ����IP���ý���������
  .clk_out4(clk_200M), // ʱ�����4��Ƶ����IP���ý���������
  // Status and control signals
  .reset(reset_btn), // PLL��λ����
  .locked(locked), // ���������"1"��ʾʱ���ȶ�������Ϊ�󼶵�·��λ
 // Clock in ports
  .clk_in1(clk_50M) // �ⲿʱ������
 );

assign eth_rst_n = ~reset_btn;
// 以太网交换机寄存器配�?
eth_conf conf(
    .clk(clk_50M),
    .rst_in_n(locked),

    .eth_spi_miso(eth_spi_miso),
    .eth_spi_mosi(eth_spi_mosi),
    .eth_spi_sck(eth_spi_sck),
    .eth_spi_ss_n(eth_spi_ss_n),

    .done()
);

reg reset_of_clk10M;
// �첽��λ��ͬ���ͷ�
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end

// ��ʹ���ڴ桢����ʱ��������ʹ���ź�
assign base_ram_ce_n = 1'b1;
assign base_ram_oe_n = 1'b1;
assign base_ram_we_n = 1'b1;

assign ext_ram_ce_n = 1'b1;
assign ext_ram_oe_n = 1'b1;
assign ext_ram_we_n = 1'b1;

assign uart_rdn = 1'b1;
assign uart_wrn = 1'b1;

// ��������ӹ�ϵʾ��ͼ��dpy1ͬ��
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7���������������ʾ����number��16������ʾ�����������
reg[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0�ǵ�λ�����
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1�Ǹ�λ�����

reg[15:0] led_bits;
assign leds = led_bits;

always@(posedge clock_btn or posedge reset_btn) begin
    if(reset_btn)begin //��λ���£�����LED�������Ϊ��ʼֵ
        number<=0;
        led_bits <= 16'h1;
    end
    else begin //ÿ�ΰ���ʱ�Ӱ�ť���������ʾֵ��1��LEDѭ������
        number <= number+1;
        led_bits <= {led_bits[14:0],led_bits[15]};
    end
end

//ֱ�����ڽ��շ�����ʾ����ֱ�������յ��������ٷ��ͳ�ȥ
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_ready, ext_uart_busy;
reg ext_uart_start, ext_uart_avai;

async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
    ext_uart_r(
        .clk(clk_50M),                       //�ⲿʱ���ź�
        .RxD(rxd),                           //�ⲿ�����ź�����
        .RxD_data_ready(ext_uart_ready),  //���ݽ��յ���־
        .RxD_clear(ext_uart_ready),       //������ձ�־
        .RxD_data(ext_uart_rx)             //���յ���һ�ֽ�����
    );
    
always @(posedge clk_50M) begin //���յ�������ext_uart_buffer
    if(ext_uart_ready)begin
        ext_uart_buffer <= ext_uart_rx;
        ext_uart_avai <= 1;
    end else if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_avai <= 0;
    end
end
always @(posedge clk_50M) begin //��������ext_uart_buffer���ͳ�ȥ
    if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_tx <= ext_uart_buffer;
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
    ext_uart_t(
        .clk(clk_50M),                  //�ⲿʱ���ź�
        .TxD(txd),                      //�����ź����
        .TxD_busy(ext_uart_busy),       //������æ״ָ̬ʾ
        .TxD_start(ext_uart_start),    //��ʼ�����ź�
        .TxD_data(ext_uart_tx)        //�����͵�����
    );

//ͼ�������ʾ���ֱ���800x600@75Hz������ʱ��Ϊ50MHz
wire [11:0] hdata;
assign video_red = hdata < 266 ? 3'b111 : 0; //��ɫ����
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //��ɫ����
assign video_blue = hdata >= 532 ? 2'b11 : 0; //��ɫ����
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //������
    .vdata(),      //������
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);

// 以太�? MAC 配置演示
wire [7:0] eth_rx_axis_mac_tdata;
wire eth_rx_axis_mac_tvalid;
wire eth_rx_axis_mac_tlast;
wire eth_rx_axis_mac_tuser;
wire [7:0] eth_tx_axis_mac_tdata;
wire eth_tx_axis_mac_tvalid;
wire eth_tx_axis_mac_tlast = 0;
wire eth_tx_axis_mac_tuser = 0;
wire eth_tx_axis_mac_tready;

wire eth_rx_mac_aclk;
wire eth_tx_mac_aclk;

eth_mac eth_mac_inst (
    .gtx_clk(clk_125M),
    .refclk(clk_200M),

    .glbl_rstn(eth_rst_n),
    .rx_axi_rstn(eth_rst_n),
    .tx_axi_rstn(eth_rst_n),

    .rx_mac_aclk(eth_rx_mac_aclk),
    .rx_axis_mac_tdata(eth_rx_axis_mac_tdata),
    .rx_axis_mac_tvalid(eth_rx_axis_mac_tvalid),
    .rx_axis_mac_tlast(eth_rx_axis_mac_tlast),
    .rx_axis_mac_tuser(eth_rx_axis_mac_tuser),

    .tx_ifg_delay(8'b0),
    .tx_mac_aclk(eth_tx_mac_aclk),
    .tx_axis_mac_tdata(eth_tx_axis_mac_tdata),
    .tx_axis_mac_tvalid(eth_tx_axis_mac_tvalid),
    .tx_axis_mac_tlast(eth_tx_axis_mac_tlast),
    .tx_axis_mac_tuser(eth_tx_axis_mac_tuser),
    .tx_axis_mac_tready(eth_tx_axis_mac_tready),

    .pause_req(1'b0),
    .pause_val(16'b0),

    .rgmii_txd(eth_rgmii_td),
    .rgmii_tx_ctl(eth_rgmii_tx_ctl),
    .rgmii_txc(eth_rgmii_txc),
    .rgmii_rxd(eth_rgmii_rd),
    .rgmii_rx_ctl(eth_rgmii_rx_ctl),
    .rgmii_rxc(eth_rgmii_rxc),

    // receive 1Gb/s | promiscuous | flow control | fcs | vlan | enable
    .rx_configuration_vector(80'b10100000101110),
    // transmit 1Gb/s | vlan | enable
    .tx_configuration_vector(80'b10000000000110)
);
/* =========== Demo code end =========== */


wire [7:0] axis_fifo_din;
wire [7:0] axis_fifo_dout;
wire axis_fifo_rd_en; 
wire axis_fifo_rd_clk; 
wire axis_fifo_empty; 
wire axis_fifo_wr_en; 
wire axis_fifo_wr_clk; 
wire axis_fifo_full;
reg axis_fifo_rst = 1;
reg[1:0] axis_fifo_rst_state = 0;

tabn_axis_fifo fifo_1 (
    .rd_en(axis_fifo_rd_en),
    .wr_en(axis_fifo_wr_en),
    .rst(axis_fifo_rst),
    .rd_clk(axis_fifo_rd_clk),
    .din(axis_fifo_din),
    .empty(axis_fifo_empty),
    .wr_clk(axis_fifo_wr_clk),
    .dout(axis_fifo_dout),
    .full(axis_fifo_full)
);

assign axis_fifo_wr_clk = eth_rx_mac_aclk;
assign axis_fifo_rd_clk = eth_tx_mac_aclk;

assign axis_fifo_din = eth_rx_axis_mac_tdata;
assign eth_tx_axis_mac_tdata = axis_fifo_dout;
assign axis_fifo_wr_en = eth_rx_axis_mac_tvalid & ~axis_fifo_full;
assign axis_fifo_rd_en = eth_tx_axis_mac_tready & ~axis_fifo_empty;
assign eth_tx_axis_mac_tvalid = ~axis_fifo_empty;

reg [31:0] destination;
reg [31:0] source;
parameter sleep_state = 3'b000;
parameter destination_fifo2reg_state = 3'b001;
parameter source_fifo2reg_state = 3'b010;
parameter source_reg2axis_state = 3'b011;
parameter destination_fifo2reg_state = 3'b100;
parameter fifo2axis_state = 3'b101;
parameter pause_state = 3'b110;
reg [2:0] state = sleep_state;
always @ (negedge eth_tx_mac_aclk) begin
    case (state):
        sleep_state: begin
            // if (fifo�ĳ��� >= 64)
        end
        destination_fifo2reg_state: begin
        end
        source_fifo2reg_state: begin
        end
        source_reg2axis_state: begin
        end
        destination_fifo2reg_state: begin
        end
        fifo2axis_state: begin
            // if �����˰������һ��Ԫ��
        end
        pause_state: begin
        end
    endcase
end

endmodule