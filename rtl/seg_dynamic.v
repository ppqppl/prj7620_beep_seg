module  seg_dynamic
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire	[1:0]	flag		,
	
	output	reg		[7:0]	dig			,
	output	reg		[5:0]	sel	
);

localparam	CNT_DELAY_MAX	=	16'd50_000	;
localparam	cnt_seg_MAX		=	3'd6		;
localparam	CNT_1S_MAX		=	26'd50_000_000	;
localparam	ZERO	=	8'b1100_0000	,
			ONE		=	8'b1111_1001	,
			TWO		=	8'b1010_0100	,
			THREE	=	8'b1011_0000	,
			FOUR	=	8'b1001_1001	,
			FIVE	=	8'b1001_0010	,
			SIX		=	8'b1000_0010	,
			SEVEN	=	8'b1111_1000	,
			EIGHT	=	8'b1000_0000	,
			NINE	=	8'b1001_0000	;

reg		[15:0]	cnt_delay	;
reg		[2:0]	cnt_seg		;
reg		[25:0]	cnt_1s		;
reg		[3:0]	cnt_num		;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_delay  <=  16'd0  ;
	else  if(cnt_delay == CNT_DELAY_MAX - 1'b1)
		cnt_delay  <=  16'd0  ;
	else
		cnt_delay  <=  cnt_delay + 1'b1  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_seg  <=  3'd0  ;
	else  if((cnt_delay == CNT_DELAY_MAX - 1'b1)&&(cnt_seg == cnt_seg_MAX - 1'b1))
		cnt_seg  <=  3'd0  ;
	else  if(cnt_delay == CNT_DELAY_MAX - 1'b1)
		cnt_seg  <=  cnt_seg + 1'b1  ;
	else
		cnt_seg  <=  cnt_seg  ;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		sel  <=  6'b111_111  ;
	else  if((cnt_seg == 3'd0)&&(cnt_delay == CNT_DELAY_MAX - 1'b1))
		sel  <=  6'b111_101  ;
	else  if((cnt_seg == 3'd1)&&(cnt_delay == CNT_DELAY_MAX - 1'b1))
		sel  <=  6'b111_011  ;
	else  if((cnt_seg == 3'd2)&&(cnt_delay == CNT_DELAY_MAX - 1'b1))
		sel  <=  6'b110_111  ;
	else  if((cnt_seg == 3'd3)&&(cnt_delay == CNT_DELAY_MAX - 1'b1))
		sel  <=  6'b101_111  ;
	else  if((cnt_seg == 3'd4)&&(cnt_delay == CNT_DELAY_MAX - 1'b1))
		sel  <=  6'b011_111  ;
	else  if((cnt_seg == 3'd5)&&(cnt_delay == CNT_DELAY_MAX - 1'b1))
		sel  <=  6'b111_110  ;
	else
		sel  <=  sel  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_1s  <=  26'd0  ;
	else  if(cnt_1s == CNT_1S_MAX - 1'b1)
		cnt_1s  <=  26'd0  ;
	else
		cnt_1s  <=  cnt_1s + 1'b1  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_num  <=  4'd0  ;
	else  if((cnt_1s == CNT_1S_MAX - 1'b1)&&(cnt_num == 4'd9))
		cnt_num  <=  4'd0  ;
	else  if(cnt_1s == CNT_1S_MAX - 1'b1)
		cnt_num  <=  cnt_num + 1'b1  ;
	else
		cnt_num  <=  cnt_num  ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		dig  <=  8'b1111_1111  ;
	else  if(flag == 2'b01)
		dig  <=  8'b1111_1111  ;
	else  if(flag == 2'b10)
		case(cnt_num)
			4'd0	:	dig  <=  ZERO	;
			4'd1	:	dig	 <=  ONE	;
			4'd2	:	dig	 <=  TWO	;
			4'd3	:	dig	 <=  THREE	;
			4'd4	:	dig	 <=  FOUR	;
			4'd5	:	dig  <=  FIVE	;
			4'd6	:	dig  <=  SIX	;
			4'd7	:	dig  <=  SEVEN	;
			4'd8	:	dig	 <=  EIGHT	;
			4'd9	:	dig  <=  NINE	;
			default	:	dig  <=  dig	;
		endcase
	else
		dig  <=  8'b1111_1111  ;

endmodule