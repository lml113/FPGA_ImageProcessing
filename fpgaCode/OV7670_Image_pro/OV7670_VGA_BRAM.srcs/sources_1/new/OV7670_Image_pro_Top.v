`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2022 11:24:08
// Design Name: 
// Module Name: OV7670_VGA_BRAM_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OV7670_Image_pro_Top(
input 			sys_clk,
//开关
input	[7:0]	rin,
//数码管
output  [5:0]	dig,
output  [7:0]	seg,
//VGA
output			Hsync,
output			Vsync,
output	[3:0]	vgaRed,
output	[3:0]	vgaGreen,
output	[3:0]	vgaBlue,
//OV7670
output			sioc,	//I2C CLOCK
inout           siod,	//I2C DATA
input 			pclk,
input 			vsync,
input 			href,
input [7:0] 	data_pin,

output 			xclk,
output 			pwdn,
output 			reset_pin
);

wire[11:0]	pixel_data;
wire[9:0]	pixel_xpos;
wire[9:0]	pixel_ypos;

reg rst = 1'b1;

wire[15:0]	dout;
reg [16:0]	addr;
wire[15:0]	dout_1;
wire[16:0]	addr_1;
reg [16:0]	addr_1_1;
reg [16:0]	addr_1_2;
wire wr;
wire [16:0] capture_addr;
wire [15:0] capture_data;
wire [7:0]	capture_gray_data;

reg 		clk_25=0;

assign xclk = clk_25;
always@(posedge sys_clk)begin
	clk_25 = ~clk_25;
end

//VGA_drice
VGA_drice uu_1(
.vga_clk(sys_clk),
.Hsync(Hsync),
.Vsync(Vsync),
.vgaRed(vgaRed),
.vgaGreen(vgaGreen),
.vgaBlue(vgaBlue),

.pixel_data(pixel_data),   //像素点数据RGB
.pixel_xpos(pixel_xpos),   //像素点横坐标
.pixel_ypos(pixel_ypos)    //像素点纵坐标
);

assign pwdn = 1'b0;//功耗选择模式（正常使用拉低）
assign reset_pin = 1'b1;//复位端口（正常使用拉高）
// OV7670 Configuration
ov7670_init u_ov7670_init
(
.iCLK(sys_clk),		//50MHz
.iRST_N(rst),        //Global Reset

//I2C Side
.I2C_SCLK(sioc),    //I2C CLOCK
.I2C_SDAT(siod),    //I2C DATA

.Config_Done()//Config Done
);
//OV7670RGB565图像采集
ov7670_capture u_ov7670_capture(
.pclk(pclk),
.vsync(vsync),
.href(href),
.d(data_pin),
.addr(capture_addr),
.dout(capture_data),
.wr(wr)
);

//BRAM
blk_mem_gen_0 uu_2(
.clka(clk_25), 
.ena(1'b1),
.wea(wr),
.addra(capture_addr),
.dina(capture_data), 
//读BRAM数据图片
.clkb(sys_clk), 
.enb(1'b1),
.addrb(addr),
.doutb(dout)
);
assign capture_gray_data = (156*capture_data[15:11]+150*capture_data[10:5]+58*capture_data[4:0])>>6;
blk_mem_gen_1 uu_3(
.clka(clk_25), 
.ena(1'b1),
.wea(wr),
.addra(capture_addr),
.dina(capture_gray_data), 
//读BRAM数据图片
.clkb(sys_clk), 
.enb(1'b1),
.addrb(addr_1),
.doutb(dout_1)
);

//显示320*240的RGB照片
parameter x_start = 10'd60,y_start = 10'd40;
parameter x_width = 10'd320,y_height = 10'd240;
wire 	pic_flag;
reg     pic_flag0;
reg     pic_flag1;
assign pic_flag = ((pixel_xpos>=x_start)&&(pixel_xpos<=(x_start+x_width))&&(pixel_ypos>=y_start)&&(pixel_ypos<=y_start+y_height));
assign pixel_data = pic_flag1?{dout[15:12],dout[10:7],dout[4:1]}:pixel_data_1;
always@(negedge sys_clk)begin
	if(pic_flag)begin
		addr <= (pixel_xpos-x_start)+(pixel_ypos-y_start)*x_width;
	end
end
always@(posedge sys_clk)begin
	pic_flag0<=pic_flag;
	pic_flag1<=pic_flag0;
end
//显示320*240的灰度值照片
parameter x_start_1 = 10'd420,y_start_1 = 10'd40;
parameter x_width_1 = 10'd320,y_height_1 = 10'd240;
wire 	pic_flag_1;
reg     pic_flag0_1;
reg     pic_flag1_1;
wire[11:0]	pixel_data_1;
assign pic_flag_1 = ((pixel_xpos>=x_start_1)&&(pixel_xpos<=(x_start_1+x_width_1))&&(pixel_ypos>=y_start_1)&&(pixel_ypos<=y_start_1+y_height_1));
assign pixel_data_1 = pic_flag1_1?{3{dout_1[7:4]}}:pixel_data_2;
assign addr_1 = pic_flag_1?addr_1_1:addr_1_2;
always@(negedge sys_clk)begin
	if(pic_flag_1)begin
		addr_1_1 <= (pixel_xpos-x_start_1)+(pixel_ypos-y_start_1)*x_width_1;
	end
end
always@(posedge sys_clk)begin
	pic_flag0_1<=pic_flag_1;
	pic_flag1_1<=pic_flag0_1;
end
//显示320*240的二值图像照片
parameter x_start_2 = 10'd60,y_start_2 = 10'd320;
parameter x_width_2 = 10'd320,y_height_2 = 10'd240;
wire[7:0]	ref_value;
wire 	pic_flag_2;
reg     pic_flag0_2;
reg     pic_flag1_2;
wire[11:0]	pixel_data_2;
wire [11:0]	data;
assign pic_flag_2 = ((pixel_xpos>=x_start_2)&&(pixel_xpos<=(x_start_2+x_width_2))&&(pixel_ypos>=y_start_2)&&(pixel_ypos<=y_start_2+y_height_2));
assign ref_value = rin;
assign data = dout_1>ref_value ? 12'b1111_1111_1111:12'd0;
assign pixel_data_2 = pic_flag1_2?data:12'd0;
always@(negedge sys_clk)begin
	if(pic_flag_2)begin
		addr_1_2 <= (pixel_xpos-x_start_2)+(pixel_ypos-y_start_2)*x_width_2;
	end
end
always@(posedge sys_clk)begin
	pic_flag0_2<=pic_flag_2;
	pic_flag1_2<=pic_flag0_2;
end

//数码管显示二值化阈值
dig_seg dig_seg_u(
.sys_clk(sys_clk),
.num0(rin%10),//各位
.num1(rin/10%10),//十位
.num2(rin/100),
.dig(dig),
.seg(seg)
    );

endmodule
