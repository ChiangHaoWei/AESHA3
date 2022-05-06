module MixColumn (
    in,dec,out_test // out_test is original mixcolumn(include xor)
);
//in : 16 byte array, out : 4*4*4 byte array
//in:    A0  A4  A8  A12
//       A1  A5  A9  A13
//       A2  A6  A10 A14
//       A3  A7  A11 A15

//out : first layer first column --> C0 4 component (4 byte)
//                  sec          --> C1
//      second      first        --> C4
//{C0,C1,C2...C15}
input [127:0] in;
input dec;
wire [511:0] out;
output [127:0] out_test;



//MixOneColumn m1(.in(A[0:3]),.out(C[0:3]),.dec(dec));
MixOneColumn m1(.in(in[127:96]),.out(out[511:384]),.dec(dec)); // one output layer
MixOneColumn m2(.in(in[95:64]),.out(out[383:256]),.dec(dec));
MixOneColumn m3(.in(in[63:32]),.out(out[255:128]),.dec(dec));
MixOneColumn m4(.in(in[31:0]),.out(out[127:0]),.dec(dec));

wire [31:0] C_beforeXOR [0:15];
wire [7:0] C_afterXOR [0:15];
assign {C_beforeXOR[0],C_beforeXOR[1],C_beforeXOR[2],C_beforeXOR[3],
        C_beforeXOR[4],C_beforeXOR[5],C_beforeXOR[6],C_beforeXOR[7],
        C_beforeXOR[8],C_beforeXOR[9],C_beforeXOR[10],C_beforeXOR[11],
        C_beforeXOR[12],C_beforeXOR[13],C_beforeXOR[14],C_beforeXOR[15]} = out;

assign out_test = { C_afterXOR[0],  C_afterXOR[1],  C_afterXOR[2],  C_afterXOR[3],
                    C_afterXOR[4],  C_afterXOR[5],  C_afterXOR[6],  C_afterXOR[7],
                    C_afterXOR[8],  C_afterXOR[9],  C_afterXOR[10], C_afterXOR[11],
                    C_afterXOR[12], C_afterXOR[13], C_afterXOR[14], C_afterXOR[15]};

genvar i;
generate
    for (i=0;i<16;i=i+1) begin
        assign C_afterXOR[i] = (
        C_beforeXOR[i][31:24] ^ C_beforeXOR[i][23:16] ^ C_beforeXOR[i][15:8] ^ C_beforeXOR[i][7:0]
        );
    end
endgenerate

    

endmodule

module MixOneColumn(in,out,dec);
input [31:0] in;
input dec;
output [127:0] out;//one layer
/*multiply matrix
ProductGenerator mapping
E B D 9      4 2 3 1     A0
9 E B D  --\ 1 4 2 3  X  A1
D 9 E B  --/ 3 1 4 2     A2
B D 9 E      2 3 1 4     A3
*/
wire [7:0] A [0:3];//input
wire [7:0] C0 [0:3]; // one output column
wire [7:0] C1 [0:3];
wire [7:0] C2 [0:3];
wire [7:0] C3 [0:3];
assign out = {C0[0],C0[1],C0[2],C0[3],
              C1[0],C1[1],C1[2],C1[3],
              C2[0],C2[1],C2[2],C2[3],
              C3[0],C3[1],C3[2],C3[3]};

assign A[0] = in[31:24];
assign A[1] = in[23:16];
assign A[2] = in[15:8];
assign A[3] = in[7:0];

ProductGenerator p0(.in(A[0]),.dec(dec),.out1(C1[0]),.out2(C3[0]),.out3(C2[0]),.out4(C0[0]));
ProductGenerator p1(.in(A[1]),.dec(dec),.out1(C2[1]),.out2(C0[1]),.out3(C3[1]),.out4(C1[1]));
ProductGenerator p2(.in(A[2]),.dec(dec),.out1(C3[2]),.out2(C1[2]),.out3(C0[2]),.out4(C2[2]));
ProductGenerator p3(.in(A[3]),.dec(dec),.out1(C0[3]),.out2(C2[3]),.out3(C1[3]),.out4(C3[3]));


endmodule


module ProductGenerator (
    in,dec,out1,out2,out3,out4
);//out1:1/9 out2:3/B out3:1/D out4:2/E

input [7:0] in;
input dec;
output [7:0] out1,out2,out3,out4;

wire [7:0] inx2,inx4,inx8; // inx4,inx8 = 0 when enc
wire [7:0] muxx2;// = 0 when enc

assign muxx2 = (dec)? inx2 : 0;

Xtime x1(.in(in),.out(inx2));
Xtime x2(.in(muxx2),.out(inx4));
Xtime x3(.in(inx4),.out(inx8));

assign out1 = in ^ inx8;
assign out2 = inx2 ^ out1;
assign out3 = inx4 ^ out1;
assign out4 = inx8 ^ inx4 ^ inx2;

    
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