module seg_drive(
    input   wire    			 clk         ,
    input   wire    			 rst_n       ,       //复位
    input   wire    [5:0]   sel         ,       //数码管位选
    input   wire    [6:0]   price_put   ,       //投入的钱
    input   wire    [6:0]   price_need  ,       //商品的价格
    input   wire    [6:0]   price_out   ,       //找零的钱
    output   reg    [7:0]   seg                 //数码管段选
   
);
 
reg [3:0] num;
always@(*) begin
    case(sel)
        //投入的钱
		6'b111_110: num = (price_put % 100) / 10;       //十位  
		6'b111_101: num = price_put % 10;               //个位
        //需要的钱
		6'b111_011: num = (price_need % 100) / 10;      //十位
		6'b110_111: num = price_need % 10;              //个位
        //找回的钱
		6'b101_111: num = (price_out % 100) / 10;       //十位
		6'b011_111: num = price_out % 10;               //个位
		default:num = 4'd0;
   endcase
end
always @ (*) begin
    //需要显示小数点
    if(!sel[1] || !sel[3] || !sel[5]) begin
        case(num)
            4'd0:    seg = 8'b1100_0000; //匹配到后参考共阳极真值表
            4'd1:    seg = 8'b1111_1001;
            4'd2:    seg = 8'b1010_0100;
            4'd3:    seg = 8'b1011_0000;
            4'd4:    seg = 8'b1001_1001;
            4'd5:    seg = 8'b1001_0010;
            4'd6:    seg = 8'b1000_0010;
            4'd7:    seg = 8'b1111_1000;
            4'd8:    seg = 8'b1000_0000;
            4'd9:    seg = 8'b1001_0000;
            default : seg = 8'b1100_0000;
        endcase
    end
       
    else begin
        case(num)
            4'd0:    seg = 8'b0100_0000; //匹配到后参考共阳极真值表
            4'd1:    seg = 8'b0111_1001;
            4'd2:    seg = 8'b0010_0100;
            4'd3:    seg = 8'b0011_0000;
            4'd4:    seg = 8'b0001_1001;
            4'd5:    seg = 8'b0001_0010;
            4'd6:    seg = 8'b0000_0010;
            4'd7:    seg = 8'b0111_1000;
            4'd8:    seg = 8'b0000_0000;
            4'd9:    seg = 8'b0001_0000;
            default : seg = 8'b0100_0000;
        endcase
    end
end
endmodule