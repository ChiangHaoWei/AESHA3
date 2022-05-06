module MixColumn (
    in,out,out_inv
);
input [127:0] in;
output reg [127:0] out,out_inv;

reg [31:0] in_col [0:3];
wire [31:0] out_col [0:3], out_inv_col [0:3];
integer i;
always @(*) begin
    for(i=0;i<4;i=i+1)begin
        in_col[i] = in[127-32*i -: 32];
        out[127-32*i -: 32] = out_col[i];
        out_inv[127-32*i -: 32] = out_inv_col[i];
    end
end
genvar j;
generate
    for (j=0;j<4;j=j+1) begin
        MixOneColumn m0(.in(in_col[j]),.out(out_col[j]),.out_inv(out_inv_col[j]));
    end
endgenerate

endmodule


module MixOneColumn (
    in,out,out_inv
);
input [31:0] in;
output [31:0] out,out_inv;

wire [7:0] A [0:3]; //input
reg [7:0] out_w [0:3];//out
wire [7:0] out_inv_w [0:3];
assign {A[0],A[1],A[2],A[3]} = in;
assign out = {out_w[0],out_w[1],out_w[2],out_w[3]};
assign out_inv = {out_inv_w[0],out_inv_w[1],out_inv_w[2],out_inv_w[3]};

wire [7:0] sum; // 4 xor sum
assign sum = A[0] ^ A[1] ^ A[2] ^ A[3];

reg [7:0] two_sum [0:3]; // 0+1 ; 1+2 ; 2+3 ; 3+0
wire [7:0] two_sumx2 [0:3];
integer i;
//two_sum
always @(*) begin
    for(i=0;i<4;i=i+1)begin
        two_sum[i] = A[i] ^ A[(i+1)%4];
    end
end
//two_sumx2
genvar j;
generate
    for(j=0;j<4;j=j+1)begin
        Xtime x0(.in(two_sum[j]),.out(two_sumx2[j]));
    end
endgenerate
//out_w
always @(*) begin
    for(i=0;i<4;i=i+1)begin
        out_w[i] = A[i] ^ two_sumx2[i] ^ sum;
    end
end

//out_inv
wire [7:0] sum02 = out_w[0] ^ out_w[2];
wire [7:0] sum13 = out_w[1] ^ out_w[3];
wire [7:0] sum0x2,sum0x4,sum1x2,sum1x4;
Xtime x1(sum02,sum0x2);
Xtime x2(sum0x2,sum0x4);
Xtime x3(sum13,sum1x2);
Xtime x4(sum1x2,sum1x4);
assign out_inv_w[0] = out_w[0] ^ sum0x4;
assign out_inv_w[1] = out_w[1] ^ sum1x4;
assign out_inv_w[2] = out_w[2] ^ sum0x4;
assign out_inv_w[3] = out_w[3] ^ sum1x4;
    
endmodule



module Xtime(
    in,out
);

input [7:0] in;
output [7:0] out;

wire [7:0] shiftin;
wire [7:0] msb_xor;

assign shiftin[7:1] = in[6:0];
assign shiftin[0]   = in[7];

assign msb_xor = {3'b0,in[7],in[7],1'b0,in[7],1'b0};

assign out = shiftin ^ msb_xor;

endmodule