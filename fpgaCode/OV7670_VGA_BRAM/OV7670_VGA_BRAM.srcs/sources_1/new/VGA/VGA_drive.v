//���ص����곬ǰ����ʱ�ӣ�����ӣ�1��1����ʼ
module VGA_drice(
input 			vga_clk,
output			Hsync,
output			Vsync,
output	[3:0]	vgaRed,
output	[3:0]	vgaGreen,
output	[3:0]	vgaBlue,

input   [11:0]  pixel_data,   //���ص�����RGB
output  [9:0]  pixel_xpos,   //���ص������
output  [9:0]  pixel_ypos    //���ص�������
);

parameter ta=80,tb=160,tc=800,td=16,te=1056,to=3,tp=21,tq=600,tr=1,ts=625;//800x600@75
// parameter ta=112,tb=248,tc=1280,td=48,te=1688,to=3,tp=38,tq=1024,tr=1,ts=1066;//1280x1024@60

reg [10:0] 	x_counter=0;
reg	[10:0] 	y_counter=0;

wire       vga_en;
wire       data_req; 

assign Hsync = !(x_counter<ta);
assign Vsync = !(y_counter<to);

//ʹ��RGB565�������
assign vga_en  = ((y_counter>to+tp-1'b1)&&(y_counter<ts-tr)&&(x_counter>ta+tb-1'b1)&&(x_counter<te-td))
                 ?  1'b1 : 1'b0;
//RGB565�������                 
assign {vgaRed,vgaGreen,vgaBlue} = vga_en ? pixel_data : 12'd0;

//�������ص���ɫ��������                
assign data_req = ((y_counter>to+tp-1'b1)&&(y_counter<ts-tr)&&(x_counter>to+tp-2'd3)&&(x_counter<te-td-2'd2))
                  ?  1'b1 : 1'b0;

//���ص�����                
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
