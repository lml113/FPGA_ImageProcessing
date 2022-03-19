`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2022 16:38:27
// Design Name: 
// Module Name: dig_seg
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


module dig_seg(
input			sys_clk,
input	[3:0]	num0,//各位
input	[3:0]	num1,//十位
input	[3:0]	num2,
output 	reg [5:0]	dig=6'b111111,
output 	reg [7:0]	seg=8'd0
    );

reg [14:0]	divclk_cnt=0;
reg 		divclk=0;

reg [3:0]	seg_data=4'd0;
reg [2:0]	dig_bit=3'd0;


always@(posedge sys_clk)begin
	if(divclk_cnt == 15'd25000)begin
		divclk_cnt = 0;
		divclk = ~divclk;
	end
	else 
		divclk_cnt = divclk_cnt+1'b1;
end
always@(posedge divclk)begin
	if(dig_bit==3'd5)
		dig_bit = 3'd0;
	else
		dig_bit = dig_bit+1'b1;
end

always@(dig_bit)begin
	case(dig_bit)
		3'd0:begin
			dig = 6'b111110;
			seg_data=num0;
		end
		3'd1:begin
			dig = 6'b111101;
			seg_data=num1;
		end
		3'd2:begin
			dig = 6'b111011;
			seg_data=num2;
		end
		default:begin
			dig = 6'b111111;
			seg_data=8'd0;
		end
	endcase
end
always@(seg_data)begin
	case(seg_data)
		4'h0:seg = 8'h3f;
		4'h1:seg = 8'h06;
		4'h2:seg = 8'h5b;
		4'h3:seg = 8'h4f;
		4'h4:seg = 8'h66;
		4'h5:seg = 8'h6d;
		4'h6:seg = 8'h7d;
		4'h7:seg = 8'h07;
		4'h8:seg = 8'h7f;
		4'h9:seg = 8'h6f;
		4'ha:seg = 8'h77;
		4'hb:seg = 8'h7c;
		4'hc:seg = 8'h39;
		4'hd:seg = 8'h5e;
		4'he:seg = 8'h79;
		4'hf:seg = 8'h71;
	endcase
end

endmodule
