module AESTOP(plain,key,cipher,clk,rst,start,finish,dec);

input [127:0] plain,key;
output [127:0] cipher;
input clk,rst;
input start,dec;
output finish;

//state parameter
localparam S_IDLE = 0;
localparam S_COMPUTE = 1;

// control
reg [3:0] counter_w,counter_r;
reg [1:0] state_w,state_r;

// data reg
reg [127:0] temp_out_w,temp_out_r;

//comb
always @() begin
    
end

//seq
always @(posedge clk or ) begin
    
end

endmodule