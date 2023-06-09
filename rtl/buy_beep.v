module buy_beep (
    input   wire            clk         ,
    input   wire            rstn        ,
    input   wire    [2:0]   flag_beep   ,

    output  wire            beep
);

localparam  MAX_200ms       =   24'd999_9999;

reg     [23:0]      cnt_200ms       ;
reg     [2:0]       beep_flag       ;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        beep_flag = 1'd0;
    end
    else begin
        beep_flag = flag_beep;
    end
end

endmodule //buy_beep