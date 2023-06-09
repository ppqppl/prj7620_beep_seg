module  paj7620_top
(
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	
	output	wire			scl			,
	// output	reg 	[3:0]	led			,
	output	wire	[7:0]	data		,
	
	inout	wire			sda	
);

//parameter	CNT_MAX	=	26'd50_000_000  ;
parameter	CNT_MAX	=	10'd1000  ;

wire			i2c_start	;
wire			cfg_start	;
wire			i2c_clk		;
wire	[23:0]	cfg_data	;
wire	[2:0]	mode		;
wire	[5:0]	reg_num		;
(*noprune*)reg		[25:0]	cnt[3:0]	;
(*noprune*)reg				flag[3:0]	;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		begin
			flag[0]	<=  1'b0	;
			flag[1]	<=  1'b0	;
			flag[2]	<=  1'b0	;
			flag[3]	<=  1'b0	;
		end
	else  if((data[3:0] == 4'b1000)||((data[3:0] == 4'b0000)&&(flag[3] == 1'b1)))
		begin
			flag[0]	<=  1'b0	;
			flag[1]	<=  1'b0	;
			flag[2]	<=  1'b0	;
			if(cnt[3] == CNT_MAX - 1'b1)
				flag[3] <=  1'b0 	;
			else  
				flag[3]	<=  1'b1	;
		end		
	else  if((data[3:0] == 4'b0100)||((data[3:0] == 4'b0000)&&(flag[2] == 1'b1)))
		begin
			flag[0]	<=  1'b0	;
			flag[1]	<=  1'b0	;
			if(cnt[2] == CNT_MAX - 1'b1)
				flag[2]	<=  1'b0	;
			else
				flag[2] <=  1'b1	;
			flag[3]	<=  1'b0	;
		end	
	else  if((data[3:0] == 4'b0010)||((data[3:0] == 4'b0000)&&(flag[1] == 1'b1)))
		begin
			flag[0]	<=  1'b0	;
			if(cnt[1] == CNT_MAX - 1'b1)
				flag[1]	<=  1'b0	;
			else
				flag[1] <=  1'b1	;
			flag[2]	<=  1'b0	;
			flag[3]	<=  1'b0	;
		end	
	else  if((data[3:0] == 4'b0001)||((data[3:0] == 4'b0000)&&(flag[0] == 1'b1)))
		begin
			if(cnt[0] == CNT_MAX - 1'b1)
				flag[0]	<=  1'b0	;
			else
				flag[0]	<=  1'b1	;
			flag[1]	<=  1'b0	;
			flag[2]	<=  1'b0	;
			flag[3]	<=  1'b0	;
		end
	else  if(data[3:0] == 4'b0000)
		begin
			flag[0]	<=  1'b0  ;
			flag[1]	<=  1'b0  ;
			flag[2] <=  1'b0  ;
			flag[3] <=  1'b0  ;
		end
	else
		begin
			flag[0]	<=  flag[0]	;		
			flag[1]	<=  flag[1]	;		
			flag[2]	<=  flag[2]	;		
			flag[3]	<=  flag[3]	;		
		end
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		begin
			cnt[0]	<=  26'd0  ;
			cnt[1]	<=  26'd0  ;
			cnt[2]	<=  26'd0  ;
			cnt[3]	<=  26'd0  ;
		end
	else  if(flag[0] == 1'b1)
		begin
			cnt[0]	<=  cnt[0] + 1'b1  ;
			cnt[1]	<=  26'd0  ;
			cnt[2]	<=  26'd0  ;
			cnt[3]	<=  26'd0  ;
		end	
	else  if(flag[1] == 1'b1)
		begin
			cnt[1]	<=  cnt[1] + 1'b1  ;
			cnt[0]	<=  26'd0  ;
			cnt[2]	<=  26'd0  ;
			cnt[3]	<=  26'd0  ;
		end	
		
	else  if(flag[2] == 1'b1)
		begin
			cnt[2]	<=  cnt[2] + 1'b1  ;
			cnt[0]	<=  26'd0  ;
			cnt[1]	<=  26'd0  ;
			cnt[3]	<=  26'd0  ;
		end		
	else  if(flag[3] == 1'b1)
		begin
			cnt[3]	<=  cnt[3] + 1'b1  ;
			cnt[1]	<=  26'd0  ;
			cnt[2]	<=  26'd0  ;
			cnt[0]	<=  26'd0  ;
		end	
	else  if((flag[0] == 1'b0)&&(flag[1] == 1'b0)&&(flag[2] == 1'b0)&&(flag[3] == 1'b0))
		begin
			cnt[0]	<=  26'd0  ;
			cnt[1]	<=  26'd0  ;
			cnt[2]	<=  26'd0  ;
			cnt[3]	<=  26'd0  ;
		end
	else
		begin
			cnt[0]	<=  cnt[0];
			cnt[1]	<=  cnt[1];
			cnt[2]	<=  cnt[2];
			cnt[3]	<=  cnt[3];	
		end
		
// always@(*)
// 	if(sys_rst_n == 1'b0)
// 		begin
// 			led[0]  <=  1'b0  ;
// 			led[1]  <=  1'b0  ;
// 			led[2]  <=  1'b0  ;
// 			led[3]  <=  1'b0  ;
// 		end
// 	else  if(flag[0] == 1'b1)
// 		begin
// 			led[0]	<=  1'b1  ;
// 			led[1]  <=  1'b0  ;
// 			led[2]  <=  1'b0  ;
// 			led[3]  <=  1'b0  ;
// 		end
// 	else  if(flag[1] == 1'b1)
// 		begin
// 			led[1]	<=  1'b1  ;
// 			led[0]  <=  1'b0  ;
// 			led[2]  <=  1'b0  ;
// 			led[3]  <=  1'b0  ;
// 		end	
// 	else  if(flag[2] == 1'b1)
// 		begin
// 			led[2]  <=  1'b1  ;
// 			led[1]  <=  1'b0  ;
// 			led[0]  <=  1'b0  ;
// 			led[3]  <=  1'b0  ;
// 		end
// 	else  if(flag[3] == 1'b1)
// 		begin
// 			led[3]  <=  1'b1  ;
// 			led[1]  <=  1'b0  ;
// 			led[2]  <=  1'b0  ;
// 			led[0]  <=  1'b0  ;
// 		end	
// 	else  if((flag[0] == 1'b0)&&(flag[1] == 1'b0)&&(flag[2] == 1'b0)&&(flag[3] == 1'b0))
// 		begin
// 			led[3]  <=  1'b0  ;
// 			led[2]  <=  1'b0  ;
// 			led[1]  <=  1'b0  ;
// 			led[0]  <=  1'b0  ;
// 		end
// 	else
// 		begin
// 			led[0]  <=  led[0];
// 			led[1]  <=  led[1];		
// 			led[2]  <=  led[2];		
// 			led[3]  <=  led[3];		
// 		end

i2c_ctrl  i2c_ctrl_inst
(
	.sys_clk	(sys_clk	)	,
	.sys_rst_n	(sys_rst_n	)	,
	.cfg_data	(cfg_data	)	,
	.i2c_start	(i2c_start	)	,
	.reg_num	(reg_num	)	,
	.scl		(scl		)	,
	.cfg_start 	(cfg_start 	)	,
	.i2c_clk	(i2c_clk	)	,
	.mode		(mode		)	,
	.po_data	(data	    )	,
	.sda	    (sda	    )
);

prj7620_cfg  prj7620_cfg_inst
(
	.i2c_clk	(i2c_clk	),
	.sys_rst_n	(sys_rst_n	),
	.cfg_start	(cfg_start	),
	.mode		(mode		),
	.cfg_data	(cfg_data	),
	.i2c_start	(i2c_start	),
	.reg_num	(reg_num	)
);

endmodule