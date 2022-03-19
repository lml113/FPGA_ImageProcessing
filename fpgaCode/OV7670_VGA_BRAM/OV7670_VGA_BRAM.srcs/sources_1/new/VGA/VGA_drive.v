//像素点坐标超前两个时钟，坐标从（1，1）开始
module VGA_drice(
input 			vga_clk,
output			Hsync,
output			Vsync,
output	[3:0]	vgaRed,
output	[3:0]	vgaGreen,
output	[3:0]	vgaBlue,

input   [11:0]  pixel_data,   //像素点数据RGB
output  [9:0]  pixel_xpos,   //像素点横坐标
output  [9:0]  pixel_ypos    //像素点纵坐标
);

parameter ta=80,tb=160,tc=800,td=16,te=1056,to=3,tp=21,tq=600,tr=1,ts=625;//800x600@75
// parameter ta=112,tb=248,tc=1280,td=48,te=1688,to=3,tp=38,tq=1024,tr=1,ts=1066;//1280x1024@60

reg [10:0] 	x_counter=0;
reg	[10:0] 	y_counter=0;

wire       vga_en;
wire       data_req; 

assign Hsync = !(x_counter<ta);
assign Vsync = !(y_counter<to);

//使能RGB565数据输出
assign vga_en  = ((y_counter>to+tp-1'b1)&&(y_counter<ts-tr)&&(x_counter>ta+tb-1'b1)&&(x_counter<te-td))
                 ?  1'b1 : 1'b0;
//RGB565数据输出                 
assign {vgaRed,vgaGreen,vgaBlue} = vga_en ? pixel_data : 12'd0;

//请求像素点颜色数据输入                
assign data_req = ((y_counter>to+tp-1'b1)&&(y_counter<ts-tr)&&(x_counter>to+tp-2'd3)&&(x_counter<te-td-2'd2))
                  ?  1'b1 : 1'b0;

//像素点坐标                
assign pixel_xpos = data_req ? (x_counter - (ta+tb - 2'd3)) : 10'd0;
assign pixel_ypos = data_req ? (y_counter - (to+tp - 1'b1)) : 10'd0;

always@(posedge vga_clk)begin
	if(x_counter==te-1)begin
		x_counter = 0;
		if(y_counter==ts-1)
			y_counter=0;
		else
			y_counter=y_counter+1;
		end
	else
		x_counter=x_counter+1;
end

endmodule
