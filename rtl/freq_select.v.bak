module freq_select
(
	input   wire 		clk,
	input   wire		rst_n,
		
	output  reg 		status, //蜂鸣器1/0
	output  reg [2:0]	spec_flag//音符
 
);
 
parameter NOTE_NUM=6'd50;  //50个音符
//中
parameter   DO  	= 20'd95600		;//1
parameter   RE  	= 20'd83150		;//2
parameter   MI  	= 20'd75850		;//3
parameter   FA  	= 20'd71600		;//4
parameter   SO  	= 20'd63750		;//5
parameter   LA    = 20'd56800		;//6
parameter   XI    = 20'd50600		;//7
//高
parameter   HDO  	= 16'd47750		;//1
parameter   HRE  	= 16'd42250		;//2
parameter   HMI  	= 16'd37900		;//3
parameter   HFA  	= 16'd37550		;//4
parameter   HSO  	= 16'd31850		;//5
parameter   HLA   = 16'd28400		;//6
parameter   HXI   = 16'd25400		;//7
//低
parameter   LDO  	= 20'd190800	;//1
parameter   LRE  	= 20'd170050	;//2
parameter   LMI  	= 20'd151500	;//3
parameter   LFA  	= 20'd143250	;//4
parameter   LSO  	= 20'd127550	;//5
parameter   LLA    = 20'd113600	;//6
parameter   LXI    = 20'd101200	;//7
 
 
reg [25:0] 	inte_cnt;  		//300ms,间隔
reg [19:0] 	note_cnt;		//音符持续时间计时
reg [5:0] 	spec_cnt;		//音谱个数计数
reg [19:0] 	spec_data;		//音符频率
reg [25:0] 	continue_time;	//持续时间
reg [27:0] 	blank_time; 		//空白时间 
 
wire[18:0] 	duty_data;		//占空比数据
wire 			end_note; 		//音符结束时间
wire 			end_spectrum;	//音谱结束时间
 
//音符之间间隔时间计数
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		inte_cnt<=26'b0;
	else if(inte_cnt==continue_time+blank_time)
		inte_cnt<=26'b0;
	else begin
		inte_cnt<=inte_cnt+1'b1;
	end
end
//单个音符频率计数
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		note_cnt <= 20'd0;//20
	end 
	else if(end_note)begin
		note_cnt <= 20'd0;
	end 
	else begin
		note_cnt <= note_cnt + 1'd1;
	end 
end
 
//音符数计时
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		spec_cnt <= 6'd0;
	end 
	else if(end_spectrum)begin
		spec_cnt <= 6'd0;
	end 
	else if(inte_cnt == continue_time+blank_time)begin
		spec_cnt <= spec_cnt + 1'd1;
	end 
	else begin
		spec_cnt <= spec_cnt;
	end 
end 
always@(posedge clk or negedge rst_n)begin
	case(spec_cnt)
			6'd0:	continue_time<=26'd10_000_000;//你爱我
			6'd1:	continue_time<=26'd_000_000;
			6'd2:	continue_time<=26'd10_000_000;						
			6'd3:	continue_time<=26'd20_000_000;
		
			6'd4:	continue_time<=26'd10_000_000;//我爱你蜜雪					
			6'd5:	continue_time<=26'd10_000_000;					
			6'd6:	continue_time<=26'd20_000_000;					
			6'd7:	continue_time<=26'd10_000_000;
			6'd8:	continue_time<=26'd10_000_000;
			
			6'd9:	continue_time<=26'd10_000_000;//冰城甜蜜				
			6'd10:continue_time<=26'd15_000_000;
			6'd11:continue_time<=26'd10_000_000;
			6'd12:continue_time<=26'd9_000_000;
			
			6'd13:continue_time<=26'd25_000_000;//蜜
			
			6'd14:continue_time<=26'd10_000_000;//你爱我
			6'd15:continue_time<=26'd10_000_000;
			6'd16:continue_time<=26'd10_000_000;
			6'd17:continue_time<=26'd20_000_000;
			
			6'd18:continue_time<=26'd10_000_000;//我爱你蜜雪
			6'd19:continue_time<=26'd10_000_000;
			6'd20:continue_time<=26'd20_000_000;
			6'd21:continue_time<=26'd10_000_000;
			6'd22:continue_time<=26'd10_000_000;
			6'd23:continue_time<=26'd10_000_000;//冰城甜蜜
			6'd24:continue_time<=26'd15_000_000;
			6'd25:continue_time<=26'd10_000_000;
			6'd26:continue_time<=26'd9_000_000;
			6'd27:continue_time<=26'd25_000_000;//蜜
			
			6'd28:continue_time<=26'd20_000_000;//你爱
			6'd29:continue_time<=26'd20_000_000;
			6'd30:continue_time<=26'd20_000_000;//我呀
			6'd31:continue_time<=26'd10_000_000;
			6'd32:continue_time<=26'd10_000_000;
			
			6'd33:continue_time<=26'd20_000_000;//我爱
			6'd34:continue_time<=26'd10_000_000;
			6'd35:continue_time<=26'd10_000_000;
			6'd36:continue_time<=26'd50_000_000;//你
			
		   6'd37:continue_time<=26'd10_000_000;//你爱我
			6'd38:continue_time<=26'd10_000_000;
			6'd39:continue_time<=26'd10_000_000;						
			6'd40:continue_time<=26'd20_000_000;
		
			6'd41:continue_time<=26'd10_000_000;//我爱你蜜雪					
			6'd42:continue_time<=26'd10_000_000;					
			6'd43:continue_time<=26'd20_000_000;					
			6'd44:continue_time<=26'd10_000_000;
			6'd45:continue_time<=26'd10_000_000;
			
			6'd46:continue_time<=26'd10_000_000;//冰城甜蜜				
			6'd47:continue_time<=26'd25_000_000;
			6'd48:continue_time<=26'd10_000_000;
			6'd49:continue_time<=26'd9_000_000;
			
			6'd50:continue_time<=26'd25_000_000;//蜜
			default:	continue_time<=26'd24_000_000;
		endcase
end
//空白时间
always@(spec_cnt)begin
	case(spec_cnt)
			6'd0:	blank_time<=26'd2_000_000;//你爱我
			6'd1:	blank_time<=26'd2_000_000;
			6'd2:	blank_time<=26'd2_000_000;						
			6'd3:	blank_time<=26'd5_000_000;
	
			6'd4:	blank_time<=26'd2_000_000;	//我爱你蜜雪					
			6'd5:	blank_time<=26'd2_000_000;					
			6'd6:	blank_time<=26'd5_000_000;					
			6'd7:	blank_time<=26'd2_000_000;
			6'd8:	blank_time<=26'd2_000_000;	
			
			6'd9:	blank_time<=26'd2_000_000;	//冰城甜蜜					
			6'd10:blank_time<=26'd5_000_000;
			6'd11:blank_time<=26'd2_000_000;
			6'd12:blank_time<=26'd2_000_000;
			
			6'd13:blank_time<=26'd5_000_000;//蜜
			
			6'd14:blank_time<=26'd2_000_000;//你爱我
			6'd15:blank_time<=26'd2_000_000;
			6'd16:blank_time<=26'd2_000_000;
			6'd17:blank_time<=26'd2_000_000;
			
			6'd18:blank_time<=26'd2_000_000;//我爱你蜜雪
			6'd19:blank_time<=26'd2_000_000;
			6'd20:blank_time<=26'd5_000_000;
			6'd21:blank_time<=26'd2_000_000;
			6'd22:blank_time<=26'd2_000_000;
		
			6'd23:blank_time<=26'd2_000_000;//冰城甜蜜
			6'd24:blank_time<=26'd5_000_000;
			6'd25:blank_time<=26'd2_000_000;
			6'd26:blank_time<=26'd2_000_000;
 
			6'd27:blank_time<=26'd5_000_000;//蜜
			
			6'd28:blank_time<=26'd2_000_000;//你爱
			6'd29:blank_time<=26'd5_000_000;
			
			6'd30:blank_time<=26'd2_000_000;//我呀
			6'd31:blank_time<=26'd2_000_000;
			6'd32:blank_time<=26'd5_000_000;
			
			6'd33:blank_time<=26'd2_000_000;//我爱
			6'd34:blank_time<=26'd2_000_000;
			6'd35:blank_time<=26'd5_000_000;
 
			6'd36:blank_time<=26'd10_000_000;//你
			
			6'd37:blank_time<=26'd2_000_000;//你爱我
			6'd38:blank_time<=26'd2_000_000;
			6'd49:blank_time<=26'd2_000_000;						
			6'd40:blank_time<=26'd5_000_000;
	
			6'd41:blank_time<=26'd2_000_000;	//我爱你蜜雪					
			6'd42:blank_time<=26'd2_000_000;					
			6'd43:blank_time<=26'd5_000_000;					
			6'd44:blank_time<=26'd2_000_000;
			6'd45:blank_time<=26'd2_000_000;	
			
			6'd46:blank_time<=26'd2_000_000;	//冰城甜蜜					
			6'd47:blank_time<=26'd5_000_000;
			6'd48:blank_time<=26'd2_000_000;
			6'd49:blank_time<=26'd2_000_000;
			
			6'd50:blank_time<=26'd5_000_000;//蜜
			default:blank_time<=26'd1_000_000;
		endcase
end
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		spec_data<=DO;
	else
		case(spec_cnt)
			6'd0:	spec_data <= MI;//你爱我
			6'd1:	spec_data <= SO;
			6'd2:	spec_data <= SO;						
			6'd3:	spec_data <= LA;
	
			6'd4:	spec_data <= SO;	//我爱你蜜雪				
			6'd5:	spec_data <= MI;					
			6'd6:	spec_data <= DO;					
			6'd7:	spec_data <= DO;
			6'd8:	spec_data <= RE;
 
			6'd9:	spec_data <= MI;	//冰城甜蜜				
			6'd10:spec_data <= MI;
			6'd11:spec_data <= RE;
			6'd12:spec_data <= DO;
	
			6'd13:spec_data <= RE;  //蜜
			6'd14:spec_data <= MI;  //你爱我
			6'd15:spec_data <= SO;
			6'd16:spec_data <= SO;
			6'd17:spec_data <= LA;
			6'd18:spec_data <= SO;  //我爱你蜜雪	
			6'd19:spec_data <= MI;
			6'd20:spec_data <= DO;
			6'd21:spec_data <= DO;
			6'd22:spec_data <= RE;
 
			6'd23:spec_data <= MI;  //冰城甜蜜
			6'd24:spec_data <= MI;
			6'd25:spec_data <= RE;
			6'd26:spec_data <= RE;
 
			6'd27:spec_data <= DO;  //蜜
			6'd28:spec_data <= FA;  //你爱
			6'd29:spec_data <= FA;
			6'd30:spec_data <= FA;  //我呀
			6'd31:spec_data <= LA;
			6'd32:spec_data <= LA;
			
			6'd33:spec_data <= SO;  //我爱
			6'd34:spec_data <= SO;
			6'd35:spec_data <= MI;
			
			6'd36:spec_data <= RE;  //你
			
			6'd37:spec_data <= MI;  //你爱我
			6'd38:spec_data <= SO;
			6'd39:spec_data <= SO;
			6'd40:spec_data <= LA;
			
			6'd41:spec_data <= SO;  //我爱你蜜雪	
			6'd42:spec_data <= MI;
			6'd43:spec_data <= DO;
			6'd44:spec_data <= DO;
			6'd45:spec_data <= RE;
			6'd46:spec_data <= MI;  //冰城甜蜜
			6'd47:spec_data <= MI;
			6'd48:spec_data <= RE;
			6'd49:spec_data <= RE;
			6'd50:spec_data <= DO;  //蜜
			default:spec_data <= DO;
 
		endcase
end
//当前音符spec_flag
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		spec_flag<=3'd0;
	else
		case(spec_data)
			DO:spec_flag<=3'd1;
			RE:spec_flag<=3'd2;
			MI:spec_flag<=3'd3;
			FA:spec_flag<=3'd4;
			SO:spec_flag<=3'd5;
			LA:spec_flag<=3'd6;
			XI:spec_flag<=3'd7;
			default:spec_flag<=3'd0;
		endcase
end
assign duty_data = spec_data >> 4;
assign end_note = note_cnt== spec_data; //spec_dara对音谱计数
assign end_spectrum = spec_cnt == NOTE_NUM && inte_cnt == continue_time;
//pwm信号产生模块
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		status <= 1'b0;
	end 
 
	else	
		status <= (note_cnt >= duty_data) ? 1'b1 : 1'b0; 
end         
 
 
endmodule
 