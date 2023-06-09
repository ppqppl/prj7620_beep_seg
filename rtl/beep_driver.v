module beep_drive (
    input   wire    clk,
    input   wire    rst_n,
    input   wire    flag,       //蜂鸣器开始鸣叫
    input   wire    flag_buying,       //蜂鸣器开始鸣叫
    input   wire    flag_hand, 
    input   wire    status,
    output  reg     beep
);
 
parameter MAX_TIME = 24'd10_000_000;        //鸣叫时间
parameter MAX_TIME_MUSIC = 28'd250_000_000; //音乐播放时间
 
reg [23:0] cnt_time;        //计时
reg [27:0] cnt_time_music;  //音乐播放计时器
reg flag_beep_time_out;     // 计时是否结束
 
 
//音乐播放计时
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_time_music <= 28'd0;
    end
    else if(flag_buying)begin
        cnt_time_music <= 28'd0;
    end
    else if(cnt_time_music < MAX_TIME_MUSIC) begin
        cnt_time_music <= cnt_time_music + 28'd1;
    end
 
    else 
        cnt_time_music <= cnt_time_music;
end
 
//蜂鸣器输出
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_time <= 0;
        beep <= 1;
        flag_beep_time_out <= 1;
    end
 
    else if(!status && cnt_time_music < MAX_TIME_MUSIC) begin
        beep <= 0;
    end
 
    else if(status && cnt_time_music < MAX_TIME_MUSIC) begin
        beep <= 1;
    end
    else if((flag||flag_hand) && flag_beep_time_out && !flag_buying) begin //开始鸣叫
        cnt_time <= MAX_TIME;
        flag_beep_time_out <= 0;
    end
    else if(cnt_time >=1 && !flag_beep_time_out) begin
        cnt_time <= cnt_time -24'd1;
        beep <= 0;
    end
    else if(cnt_time == 0) begin//计时结束
		beep <= 1;
		flag_beep_time_out <= 1;
	end
	else begin
		cnt_time <= cnt_time ;
		beep <= beep;
        flag_beep_time_out <= flag_beep_time_out;
	end
end












//

parameter MAX_buying = 26'd40_000_000;

reg [25:0] cnt_time_buying;

endmodule