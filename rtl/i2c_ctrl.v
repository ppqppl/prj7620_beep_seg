module  i2c_ctrl
#(
	parameter	SLAVE_ID	=	7'b111_0011		,
				SENSOR_ADDR	=	8'b1110_1111	,
				RD_ADDR		=	8'h43			,
				SYS_CLK_FREQ=	26'd50_000_000	,
				SCL_FREQ	=	23'd250_000
)
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire	[23:0]	cfg_data	,
	input	wire			i2c_start	,
	input	wire	[5:0]	reg_num		,

	output	wire			scl			,
	output	reg				cfg_start 	,
	output	reg				i2c_clk		,
	output	reg		[2:0]	mode		,
	output	reg 	[7:0]	po_data		,
	
	inout	wire			sda	
);

parameter	CNT_CLK_MAX		=	(SYS_CLK_FREQ/SCL_FREQ) >> 2'd3  ;
parameter	CNT_T1_MAX		=	'd1000  ,	//初始延迟1000us
			CNT_T2_MAX		=	'd1000	;	//唤醒等待1000us
parameter	IDLE			=	'd0		,
			START			=	'd1		,
			SLAVE_ADDR		=	'd2		,
			ACK_1			=	'd3		,
			DEVICE_ADDR		=	'd4		,
			ACK_2			=	'd5		,
			DATA			=	'd6		,
			ACK_3			=	'd7		,
			STOP			=	'd8		,
			WAIT			=	'd9		,
			NACK			=	'd10	;

(*noprune*)reg		[4:0]	n_state		;
(*noprune*)reg		[4:0]	c_state		;
(*noprune*)reg		[4:0]	cnt_clk		;	//i2c时钟计数器
(*noprune*)reg				skip_en_1	;	//状态跳转信号1
(*noprune*)reg				skip_en_2	;	//状态跳转信号2
(*noprune*)reg				skip_en_3	;	//状态跳转信号3
(*noprune*)reg				skip_en_4	;	//状态跳转信号4
(*noprune*)reg				skip_en_5	;	//状态跳转信号5
(*noprune*)reg				skip_en_6	;	//状态跳转信号6
(*noprune*)reg				skip_en_7	;	//状态跳转信号7
(*noprune*)reg				error_en	;	//错误信号
(*noprune*)reg		[9:0]	cnt_wait	;	//初始状态等待信号
(*noprune*)reg				i2c_scl		;
(*noprune*)reg				i2c_sda		;
(*noprune*)reg				i2c_end		;
(*noprune*)reg		[1:0]	cnt_i2c_clk	;	//计数i2c时钟个数
(*noprune*)reg		[2:0]	cnt_bit		;	//发送或者接收数据的8bit计数器
(*noprune*)reg				ack			;
(*noprune*)reg		[7:0]	rec_data	;	//接收的数据，用来判断是否为0x20
(*noprune*)reg		[9:0]	cnt_delay	;
(*noprune*)reg 		[7:0]	slave_addr	;
(*noprune*)reg 		[7:0]	device_addr	;
(*noprune*)reg 		[7:0]	wr_addr		;
(*noprune*)reg 		[5:0]	cfg_num		;
(*noprune*)reg 		[7:0]	po_data_reg	;
(*noprune*)wire				sda_en		;
(*noprune*)wire				sda_in		;

assign	scl		=	i2c_scl  ;
assign	sda_in	=	sda  ;
assign	sda_en	=	((c_state == ACK_1)||(c_state == ACK_2)||(c_state == ACK_3)||(c_state == DATA&&mode == 3'd3)||(c_state == DATA&&mode == 3'd6)) ? 1'b0 : 1'b1  ;
assign	sda		=	(sda_en == 1'b1) ? i2c_sda : 1'bz  ;

always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cfg_start  <=  1'b0  ;
	else 
		cfg_start  <=  i2c_end  ;

always@(*)
	case(mode)
		3'd0	:	begin
						slave_addr	<=  {SLAVE_ID,1'b0}  ;	//激活
						device_addr	<=  8'd0  ;
						wr_addr		<=  8'd0  ;
					end
		3'd1	:	begin
				 		slave_addr	<=  {SLAVE_ID,1'b0}  ;	//写入0xEF 00	
				 		device_addr	<=  SENSOR_ADDR  ;	
				 		wr_addr		<=  8'd0  ;	
				 	end	
		3'd2	:	begin
				 		slave_addr	<=  {SLAVE_ID,1'b0}  ;	//写入00寄存器	
				 		device_addr	<=  8'b0000_0000  ;	
					end	
		3'd3	:	begin
						slave_addr	<=  {SLAVE_ID,1'b1}  ;	//读取00寄存器的值
					end
		3'd4	:	begin
						slave_addr	<=  cfg_data[23:16]  ;
						device_addr	<=  cfg_data[15:8]   ;
						wr_addr	    <=  cfg_data[7:0]	 ;
					end
		3'd5	:	begin
						slave_addr	<=  {SLAVE_ID,1'b0}  ;
						device_addr	<=  RD_ADDR			 ;
					end
		3'd6	:	begin
						slave_addr  <=  {SLAVE_ID,1'b1}  ;
					end
	endcase

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_clk  <=  5'd0  ;
	else  if(cnt_clk == CNT_CLK_MAX - 1'b1)
		cnt_clk  <=  5'd0  ;
	else
		cnt_clk  <=  cnt_clk + 1'b1  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		i2c_clk  <=  1'b0  ;
	else  if(cnt_clk == CNT_CLK_MAX - 1'b1)
		i2c_clk  <=  ~i2c_clk  ;
	else
		i2c_clk  <=  i2c_clk ;
		
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		c_state  <=  IDLE  ;
	else
		c_state  <=  n_state  ;

always@(*)	
	case(c_state)	
		IDLE		:	if((skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1)||(skip_en_7 == 1'b1))
							n_state  <=  START  ;
						else
							n_state  <=  IDLE  ;
		START		:	if((skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1)||(skip_en_7 == 1'b1))
							n_state  <=  SLAVE_ADDR  ;
						else
							n_state  <=  START  ;
		SLAVE_ADDR	:	if(skip_en_1 == 1'b1)
							n_state  <=  WAIT  ;
						else  if((skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1)||(skip_en_7 == 1'b1))
							n_state  <=  ACK_1  ;
						else
							n_state  <=  SLAVE_ADDR  ;
		ACK_1		:	if((skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  <=  DEVICE_ADDR  ;
						else  if((skip_en_4 == 1'b1)||(skip_en_7 == 1'b1))
							n_state  <=  DATA  ;
						else
							n_state  <=  ACK_1  ;
		WAIT		:	if(skip_en_1 == 1'b1)
							n_state  <=  STOP  ;
						else
							n_state  <=  WAIT  ;
		DEVICE_ADDR	:	if((skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  <=  ACK_2  ;
						else
							n_state  <=  DEVICE_ADDR  ;
		ACK_2		:	if((skip_en_2 == 1'b1)||(skip_en_5 == 1'b1))
							n_state  <=  DATA  ;
						else  if((skip_en_3 == 1'b1)||(skip_en_6 == 1'b1))
							n_state  <=  STOP  ;
						else
							n_state  <=  ACK_2  ;
		DATA		:	if((skip_en_2 == 1'b1)||(skip_en_5 == 1'b1))
							n_state  <=  ACK_3  ;
						else  if((skip_en_4 == 1'b1)||(skip_en_7 == 1'b1))
							n_state  <=  NACK  ;
						else  if(error_en == 1'b1)
							n_state  <=  IDLE  ;
						else
							n_state  <=  DATA  ;
		ACK_3		:	if((skip_en_2 == 1'b1)||(skip_en_5 == 1'b1))
							n_state  <=  STOP  ;
						else
							n_state  <=  ACK_3  ;
		NACK		:	if(skip_en_4 == 1'b1)
							n_state  <=  STOP  ;
						else  if(skip_en_7 == 1'b1)
							n_state  <=  STOP  ;
						else
							n_state  <=  NACK  ;
		STOP		:	if((skip_en_1 == 1'b1)||(skip_en_2 == 1'b1)||(skip_en_3 == 1'b1)||(skip_en_4 == 1'b1)||(skip_en_5 == 1'b1)||(skip_en_6 == 1'b1)||(skip_en_7 == 1'b1))
							n_state  <=  IDLE  ;
						else
							n_state  <=  STOP  ;
		default		:	n_state  <=  IDLE  ;
	endcase
	
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		begin
			cnt_wait	<=  10'd0  	;
			skip_en_1	<=  1'b0	;
			skip_en_2	<=  1'b0    ;
			skip_en_3	<=  1'b0	;
			skip_en_4	<=  1'b0    ;
			skip_en_5   <=  1'b0    ;
			skip_en_6   <=  1'b0    ;
			skip_en_7	<=  1'b0    ;
			cnt_i2c_clk	<=  2'd0	;
			cnt_bit		<=  3'd0	;
			i2c_end		<=  1'b0  	;
			mode        <=  3'd0    ;
			cnt_delay	<=  10'd0   ;
			error_en	<=  1'b0	;
			cfg_num		<=  6'd0	;
		end
	else
		case(c_state)
			IDLE		:begin
							if(cnt_wait == CNT_T1_MAX - 1'b1)
								cnt_wait  <=  10'd0  ;
							else
								cnt_wait  <=  cnt_wait + 1'b1  ;
							if((cnt_wait == CNT_T1_MAX - 2'd2)&&(mode == 3'd0))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_wait == CNT_T1_MAX - 2'd2)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((cnt_wait == CNT_T1_MAX - 2'd2)&&(mode == 3'd2))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;
							if((cnt_wait == CNT_T1_MAX - 2'd2)&&(mode == 3'd3))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((i2c_start == 1'b1)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;
							if((cnt_wait == CNT_T1_MAX - 2'd2)&&(mode == 3'd5))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;
							if((cnt_wait == CNT_T1_MAX - 2'd2)&&(mode == 3'd6))
								skip_en_7  <=  1'b1  ;
							else
								skip_en_7  <=  1'b0  ;								
						 end
			START		:begin
							cnt_i2c_clk		<=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd0))
								skip_en_1  <=  1'b1  ;
						    else
								skip_en_1  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
						    else
								skip_en_2  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd2))
								skip_en_3  <=  1'b1  ;
						    else
								skip_en_3  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd3))
								skip_en_4  <=  1'b1  ;
						    else
								skip_en_4  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
						    else
								skip_en_5  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd5))
								skip_en_6  <=  1'b1  ;
						    else
								skip_en_6  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd6))
								skip_en_7  <=  1'b1  ;
						    else
								skip_en_7  <=  1'b0  ;								
						 end
			SLAVE_ADDR	:begin
							cnt_i2c_clk		<=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd3)&&(cnt_bit == 3'd7))
								cnt_bit  <=  3'd0  ;
							else  if(cnt_i2c_clk == 2'd3)
								cnt_bit  <=  cnt_bit + 1'b1  ;
							else
								cnt_bit  <=  cnt_bit  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd0))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd2))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd3))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd5))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd6))
								skip_en_7  <=  1'b1  ;
							else
								skip_en_7  <=  1'b0  ;								
						 end
			ACK_1		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd2))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd3))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd5))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd6))
								skip_en_7  <=  1'b1  ;
							else
								skip_en_7  <=  1'b0  ;								
						 end
			WAIT		:begin
							cnt_delay  <=  cnt_delay + 1'b1  ;
							if(cnt_delay == CNT_T2_MAX - 2'd2)
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
						 end
		    DEVICE_ADDR	:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd3)&&(cnt_bit == 3'd7))
								cnt_bit  <=  3'd0  ;
							else  if(cnt_i2c_clk == 2'd3)
								cnt_bit  <=  cnt_bit + 1'b1  ;
							else
								cnt_bit  <=  cnt_bit  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd2))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd5))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;									
						 end
			ACK_2		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd2))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd5))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;								
						 end
			DATA		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((cnt_i2c_clk == 2'd3)&&(cnt_bit == 3'd7))
								cnt_bit  <=  3'd0  ;
							else  if(cnt_i2c_clk == 2'd3)
								cnt_bit  <=  cnt_bit + 1'b1  ;
							else
								cnt_bit  <=  cnt_bit  ;			
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd3)&&(rec_data == 8'h20))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd6))
								skip_en_7  <=  1'b1  ;
							else
								skip_en_7  <=  1'b0  ;								
							if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd3)&&(rec_data != 8'h20))
								begin
									error_en  <=  1'b1  ;
									mode	  <=  1'b0  ;
								end
							else
								begin
									error_en  <=  1'b0  ;
									mode	  <=  mode  ;
								end	
						 end
			ACK_3		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd4))
								skip_en_5 <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;								
						 end
			NACK		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd3))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;
							if((ack == 1'b1)&&(cnt_i2c_clk == 2'd2)&&(mode == 3'd6))
								skip_en_7  <=  1'b1  ;
							else
								skip_en_7  <=  1'b0  ;								
						 end
		    STOP		:begin
							cnt_i2c_clk  <=  cnt_i2c_clk + 1'b1  ;
							if(cnt_i2c_clk == 2'd2)
								i2c_end  <=  1'b1  ;
							else
								i2c_end  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd0))
								skip_en_1  <=  1'b1  ;
							else
								skip_en_1  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd1))
								skip_en_2  <=  1'b1  ;
							else
								skip_en_2  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd2))
								skip_en_3  <=  1'b1  ;
							else
								skip_en_3  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd3))
								skip_en_4  <=  1'b1  ;
							else
								skip_en_4  <=  1'b0  ;	
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd4))
								skip_en_5  <=  1'b1  ;
							else
								skip_en_5  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd5))
								skip_en_6  <=  1'b1  ;
							else
								skip_en_6  <=  1'b0  ;
							if((cnt_i2c_clk == 2'd2)&&(mode == 3'd6))
								skip_en_7  <=  1'b1  ;
							else
								skip_en_7  <=  1'b0  ;								
							if((i2c_end == 1'b1)&&(mode != 3'd4)&&(mode != 3'd6))
								mode  <=  mode + 1'b1  ;
							else  if((i2c_end == 1'b1)&&(mode == 3'd4)&&(reg_num == 6'd51))
								mode  <=  mode + 1'b1  ;
							else
								mode  <=  mode  ;
							if((i2c_end == 1'b1)&&(mode == 3'd4))
								cfg_num  <=  cfg_num + 1'b1  ;
							else
								cfg_num  <=  cfg_num  ;
						 end
			default		:begin
							cnt_wait	<=  10'd0  ;
							skip_en_1	<=  1'b0   ;
							skip_en_2   <=  1'b0   ;
							skip_en_3	<=  1'b0   ;
							skip_en_4   <=  1'b0   ;
							skip_en_5	<=  1'b0   ;
							skip_en_6   <=  1'b0   ;
							skip_en_7   <=  1'b0   ;
							cnt_i2c_clk	<=  2'd0   ;
							cnt_bit	    <=  3'd0   ;
							i2c_end		<=  1'b0   ;
							mode		<=  mode   ;
							cnt_delay	<=  10'd0  ;
							error_en	<=  1'b0   ;
							cfg_num		<=  cfg_num;
						 end
		endcase

always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		rec_data  <=  8'd0  ;
	else
		case(c_state)
			DATA	:	if((mode == 3'd3)&&(cnt_i2c_clk == 2'd1))
							rec_data  <=  {rec_data[6:0],sda_in}  ;
						else
							rec_data  <=  rec_data  ;
			default	:	rec_data  <=  rec_data  ;
		endcase
		
always@(posedge i2c_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_data_reg  <=  8'd0  ;
	else  
		case(c_state)
			DATA	:	if((mode == 3'd6)&&(cnt_i2c_clk == 2'd1))
							po_data_reg  <=  {po_data_reg[6:0],sda_in}  ;
						else
							po_data_reg  <=  po_data_reg  ;
			default	:	po_data_reg  <=  po_data_reg  ;
		endcase

always@(*)
	if(sys_rst_n == 1'b0)
		po_data  <=  8'd0  ;
	else  if((cnt_i2c_clk == 2'd2)&&(cnt_bit == 3'd7)&&(mode == 3'd6))//&&(po_data_reg[3:0] != 4'b0000))
		po_data  <=  po_data_reg  ;
	else
		po_data  <=  po_data  ;
		
always@(*)
	case(c_state)
		ACK_1,ACK_2,ACK_3	:	ack  <=  ~sda_in  ;
		NACK				:	ack  <=  sda_in  ;
		default	:	ack  <=  1'b0  ;
	endcase

always@(*)
	case(c_state)
		IDLE		:	i2c_scl  <=  1'b1  ;
		START		:	if(cnt_i2c_clk == 2'd3)
							i2c_scl  <=  1'b0  ;
						else
							i2c_scl  <=  1'b1  ;
		SLAVE_ADDR,ACK_1,DEVICE_ADDR,ACK_2,DATA,ACK_3,NACK:
						if((cnt_i2c_clk == 2'd1)||(cnt_i2c_clk == 2'd2))
							i2c_scl  <=  1'b1  ;
						else
							i2c_scl  <=  1'b0  ;
		WAIT		:	if((cnt_delay == 10'd0)||(cnt_delay == CNT_T2_MAX - 1'b1))
							i2c_scl  <=  1'b0  ;
						else
							i2c_scl  <=  1'b1  ;
		STOP		:	if(cnt_i2c_clk == 2'd0)
							i2c_scl  <=  1'b0  ;
						else
							i2c_scl  <=  1'b1  ;
	    default		:	i2c_scl  <=  1'b1  ;
	endcase

always@(*)
	case(c_state)
		IDLE		:	i2c_sda		<=  1'b1  ;
		START		:	if(cnt_i2c_clk == 2'd0)
							i2c_sda  <=  1'b1  ;
						else
							i2c_sda  <=  1'b0  ;
		SLAVE_ADDR	:	i2c_sda  <=  slave_addr[7-cnt_bit]  ;
		ACK_1,ACK_2,ACK_3:	
						i2c_sda  <=  1'b0  ;
		WAIT,NACK	:	i2c_sda  <=  1'b1  ;
		DEVICE_ADDR	:	i2c_sda  <=  device_addr[7-cnt_bit]  ;
		DATA		:	if((mode == 3'd3)||(mode == 3'd6))
							i2c_sda  <=  sda_in  ;
						else
							i2c_sda  <=  wr_addr[7-cnt_bit]  ;
		STOP		:	if((cnt_i2c_clk == 2'd0)||(cnt_i2c_clk == 2'd1))
							i2c_sda  <=  1'b0  ;
						else
							i2c_sda  <=  1'b1  ;
		default		:	i2c_sda  <=  1'b1  ;
	endcase

endmodule