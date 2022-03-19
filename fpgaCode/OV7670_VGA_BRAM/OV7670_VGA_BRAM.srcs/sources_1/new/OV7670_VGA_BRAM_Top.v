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


module OV7670_VGA_BRAM_Top(
input 			sys_clk,
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
wire wr;
wire [16:0] capture_addr;
wire [15:0] capture_data;

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

//显示320*240的照片
parameter x_start = 10'd240,y_start = 10'd180;
parameter x_width = 10'd320,y_height = 10'd240;
wire 	pic_flag;
reg     pic_flag0;
reg     pic_flag1;
assign pic_flag = ((pixel_xpos>=x_start)&&(pixel_xpos<=(x_start+x_width))&&(pixel_ypos>=y_start)&&(pixel_ypos<=y_start+y_height));
assign pixel_data = pic_flag1?{dout[15:12],dout[10:7],dout[4:1]}:12'd0;
always@(negedge sys_clk)begin
	if(pic_flag)begin
		addr <= (pixel_xpos-x_start)+(pixel_ypos-y_start)*x_width;
	end
end
always@(posedge sys_clk)begin
	pic_flag0<=pic_flag;
	pic_flag1<=pic_flag0;
end

endmodule
