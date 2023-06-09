module beep_led_drive (
    input   wire          clk  ,//时钟信号
    input   wire          rst_n,//复位信号
    input   wire    [3:0] value,//LED显示状态
 
    output  reg     [3:0] led   //4个LED输出
);
/*
    value       效果
 
    0           全灭
    1           全亮
    2           只亮led[0]
    3           只亮led[1]
    4           只亮led[2]
    5           只亮led[3]
    6           流水灯
    7           闪烁
*/
parameter MAX_TIME_RUNNING = 28'd4_000_000;     //流水灯频率0.08s
parameter MAX_TIME_FLASH =  28'd10_000_000;     //闪烁频率0.2s
 
 
reg [27:0] cnt_time_running ;       //流水灯计时器
reg [27:0] cnt_time_flash;          //闪烁灯计时器
 
reg [7:0] led_running;              //流水灯状态寄存器
reg [3:0] led_flash;                //闪烁灯状态寄存器
 
//流水灯计数器0.08s
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_time_running <=28'd1;
    else if(value == 4'd6) begin
        if(cnt_time_running == MAX_TIME_RUNNING)
            cnt_time_running <=28'd1;
        else
            cnt_time_running <= cnt_time_running+28'd1;
    end
    else 
        cnt_time_running <= 28'd1;
end
//闪烁灯计数器0.2s
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_time_flash <=28'd1;
    else if (value == 4'd7) begin
        if(cnt_time_flash == MAX_TIME_FLASH )
            cnt_time_flash <=28'd1;
        else
            cnt_time_flash <= cnt_time_flash+28'd1;
    end
    else 
        cnt_time_flash <= 28'd1;
end
 
//流水灯状态切换 间隔0.08s
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        led_running <= 8'b00001111;
    else if(cnt_time_running == MAX_TIME_RUNNING)begin
        led_running <= {led_running[0],led_running[7:1]};
    end
    else 
        led_running <=led_running;
	
end
//闪烁状态切换 间隔0.2s
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        led_flash <= 4'b0000;
    else if(cnt_time_flash == MAX_TIME_FLASH)begin
        led_flash <= ~led_flash;
    end
    else 
        led_flash <=led_flash;
	
end
 
//根据value值输出对应灯效果
always @(*) begin
    case(value)
        4'd0: begin
            led = 4'b0000;//默认状态LED全灭
        end
 
        4'd1:begin
            led = 4'b1111;//
        end
 
        4'd2:begin
            led = 4'b0001;//选择第一种商品
        end
 
        4'd3:begin
            led = 4'b0010;//选择第二种商品
        end
 
        4'd4:begin
            led = 4'b0100;//选择第三种商品
        end
 
        4'd5:begin
            led = 4'b1000;//选择第四种商品
        end
 
        4'd6: begin
		      led = led_running[3:0];//购买成功找零不找零，流水灯
        end
        4'd7:begin
            led = led_flash;//取消订单，闪烁
        end
        default : led = 4'b0000;
    endcase
end
endmodule 