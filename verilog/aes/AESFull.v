//module AESTOP(plain,key,cipher,clk,rst,start,finish,dec);
module AESTOP(  
    clk,
                rst_n,
                mode, //mode = 1 --> decode?
                i_start,
                i_key,
                i_in,
                o_cipher,
                o_ready);
input clk,rst_n;
input i_start,mode;
input [127:0] i_key,i_in;
output [127:0] o_cipher;
output o_ready;

//state parameter
localparam S_IDLE = 0;
localparam S_LASTROUNDKEY = 1;
localparam S_COMPUTE = 2;
localparam S_NXTKEY = 3;
localparam S_FIN = 4;

// control
reg [3:0] counter_w,counter_r;
reg [2:0] state_w,state_r;

// data reg and wire
reg [127:0] temp_out_w,temp_out_r;

//module reg and wire
wire [127:0] oneround_in,oneround_out;
reg [127:0] roundkey_w,roundkey_r;
wire [127:0] xor_out;
reg nomix;
reg subbyteonly;
wire [31:0] sub_in,sub_out;
wire [3:0] rc_table_round;

reg key_inv;
wire [7:0] rc;
wire [127:0] key_nxt;

//call module

// KeySchedule key0(
//     .key(i_key), 
//     .roundkeys(roundkeys), 
//     .clk(clk), 
//     .rst_n(rst_n), 
//     .start(key_start), 
//     .finish(key_finish),
//     .sub_in(sub_in),
//     .sub_out(sub_out)
// );
KeySchedule key0(
    .key(roundkey_r), 
    .rc(rc), 
    .dec(key_inv),
    .out_key(key_nxt),
    .sub_in(sub_in),
    .sub_out(sub_out)
);
AESOneRound oneround(
    .in(oneround_in),
    .out(oneround_out),
    .roundkey(roundkey_r),
    .dec(mode),
    .nomix(nomix),
    .subbyteonly(subbyteonly),
    .sub_in(sub_in),
    .sub_out(sub_out)
);

AddRoundKey xor0( //to xor before start of enc / after end of dec
    .in(temp_out_r),
    .key(i_key),
    .out(xor_out)
);

rc_table rctable(
    .round(rc_table_round),
    .o_rc(rc)
);

//wire assignment
//assign xor_in = (mode)? oneround_out:i_in;
assign oneround_in = temp_out_r;
//assign key_start = (state_r == S_ROUNDKEY);
assign rc_table_round = (mode && !(state_r == S_LASTROUNDKEY))? (9-counter_r):counter_r;
//assign oneround_key = roundkeys[1279 -: 128];

//output assignment
assign o_cipher = temp_out_r;
assign o_ready = (state_r == S_FIN);

//comb
//next state logic
always @(*) begin
    state_w = state_r;
    counter_w = counter_r;
    case (state_r)
        S_IDLE:begin
            counter_w = 0;
            if(i_start) begin
                if(mode) begin
                    state_w = S_LASTROUNDKEY;
                end
                else
                    state_w = S_COMPUTE;
            end
        end 
        S_LASTROUNDKEY:begin
            counter_w = counter_r + 1;
            if(counter_r == 9)begin
                state_w = S_COMPUTE;
                counter_w = 0;
            end
        end
        S_COMPUTE:begin
            if(counter_r == 10)
                state_w = S_FIN;
            else
                state_w = S_NXTKEY;
        end
        S_NXTKEY:begin
            state_w = S_COMPUTE;
            counter_w = counter_r + 1;
        end
        S_FIN:begin
            state_w = S_IDLE;
        end
    endcase
end

always @(*) begin
    temp_out_w = temp_out_r;
    nomix = 0;
    subbyteonly = 0;
    key_inv = 0;
    roundkey_w = roundkey_r;
    case (state_r)
        S_IDLE:begin
            roundkey_w = i_key;
            temp_out_w = i_in;
        end
        S_LASTROUNDKEY:begin
            roundkey_w = key_nxt;
            subbyteonly = 1;
        end
        S_COMPUTE:begin
            temp_out_w = oneround_out;
            if ((counter_r == 10) && (mode))
                temp_out_w = xor_out;
            if (counter_r == 10 && (!(mode)))
                nomix = 1;
            if (counter_r == 0 && mode)
                nomix = 1;
            if (counter_r == 0 && !mode)begin
                temp_out_w = xor_out;
            end
            //round 1 key : roundkeys[1279 -: 128]
            //round 2 key : roundkeys[1279-128 -: 128]
            //round 3 key : roundkeys[1279-128*2 -: 128]
            //round n key : roundkeys[1279-128*(counter_r) -: 128]
        end
        S_NXTKEY:begin
            if(mode)
                key_inv = 1;
            subbyteonly = 1;
            roundkey_w = key_nxt;
        end
    endcase
end

//seq
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        counter_r <= 0;
        state_r <= S_IDLE;
    end
    else begin
        counter_r <= counter_w;
        state_r <= state_w;
        temp_out_r <= temp_out_w;
        roundkey_r <= roundkey_w;
    end
end

endmodule

module rc_table(
    round,o_rc
);
input [3:0] round;
output reg [7:0] o_rc;
always @(*) begin
    case (round)
        0: o_rc = 8'h01;
        1: o_rc = 8'h02;
        2: o_rc = 8'h04;
        3: o_rc = 8'h08;
        4: o_rc = 8'h10;
        5: o_rc = 8'h20;
        6: o_rc = 8'h40;
        7: o_rc = 8'h80;
        8: o_rc = 8'h1b;
        9: o_rc = 8'h36;
        default: o_rc = 0;
    endcase
end


endmodule
module AESOneRound (
    in,out,roundkey,dec,nomix,subbyteonly,sub_in,sub_out,//nomix = 1 when no mixcolumn
);
input [127:0] in,roundkey;
input dec;
input subbyteonly;
input [31:0] sub_in;
output [31:0] sub_out;
output reg [127:0] out;
input nomix;
// input clk;


reg [127:0]  key_in ,inv_sh_in ,mix_in ,sh_in;
wire [127:0] key_out,inv_sh_out,mix_out,sh_out,mix_out_inv;
reg [31:0] sub32_in;
wire [31:0] sub32_out;
reg [95:0] sub96_in;
wire [95:0] sub96_out;

assign sub_out = sub32_out;
wire sub32_dec = dec & (!(subbyteonly));

AddRoundKey add(.in(key_in),.out(key_out),.key(roundkey));
SubByte_32 sub32(.in(sub32_in),.out(sub32_out),.dec(sub32_dec));
SubByte_96 sub96(.in(sub96_in),.out(sub96_out),.dec(dec));
ShiftRow shift(.in(sh_in),.out(sh_out));
InvShiftRow invshift(.in(inv_sh_in),.out(inv_sh_out));
MixColumn mix(.in(mix_in),.out(mix_out),.out_inv(mix_out_inv));

always @(*) begin
    if(nomix)
        inv_sh_in = key_out;
    else
        inv_sh_in = mix_out_inv;
    if(subbyteonly)
        sub32_in = sub_in;
    else begin
        if(dec)
            sub32_in = inv_sh_out[31:0];
        else
            sub32_in = in[31:0];
    end
    sh_in = {sub96_out,sub32_out};
    if(dec)begin //add -> mix -> invsh -> invsub
        key_in = in;
        mix_in = key_out;
        //inv_sh_in = mix_out_inv;
        sub96_in = inv_sh_out[127:32];
        out = {sub96_out,sub32_out};
    end
    else begin //sub -> sh -> mix -> add
        sub96_in = in[127:32];
        if(nomix)
            key_in = sh_out;
        else
            key_in = mix_out;
        //sh_in = sub_out;
        mix_in = sh_out;
        out = key_out;
    end
end



endmodule

module KeySchedule ( // share xor?
    key,rc,out_key,dec,sub_in,sub_out
);
input [127:0] key;
input [7:0] rc;
output reg [127:0] out_key;
output [31:0] sub_in;
input [31:0] sub_out;
input dec;

reg [31:0] out_word [0:3];
reg [31:0] in_word [0:3];
integer i;

reg [31:0] g_in;
wire [31:0] g_out;
GFunction gfunc(.in(g_in),.out(g_out),.rc(rc),.sub_in(sub_in),.sub_out(sub_out));

always @(*) begin
    for(i=0;i<4;i=i+1)begin
        in_word[i] = key[127-32*i -: 32];
        out_key[127-32*i -: 32] = out_word[i];
    end
end

always @(*) begin
    if(dec)begin
        g_in = out_word[3];
        out_word[0] = in_word[0] ^ g_out;
        out_word[1] = in_word[1] ^ in_word[0];
        out_word[2] = in_word[2] ^ in_word[1];
        out_word[3] = in_word[3] ^ in_word[2];
    end
    else begin
        g_in = in_word[3];
        out_word[0] = in_word[0] ^ g_out;
        out_word[1] = in_word[1] ^ out_word[0];
        out_word[2] = in_word[2] ^ out_word[1];
        out_word[3] = in_word[3] ^ out_word[2];
    end
end

endmodule


module GFunction(in,out,rc,sub_in,sub_out);

input [31:0] in;
input [7:0] rc;
output [31:0] out;
output [31:0] sub_in;
input [31:0] sub_out;

wire [7:0] V [0:3];
wire [7:0] V_o [0:3];
wire [7:0] V_o_temp;

assign {V[0],V[1],V[2],V[3]} = in;
assign out = {V_o[0],V_o[1],V_o[2],V_o[3]};

// STable s0(.in(V[0]),.out(V_o[3]));
// STable s1(.in(V[1]),.out(V_o_temp));
// STable s2(.in(V[2]),.out(V_o[1]));
// STable s3(.in(V[3]),.out(V_o[2]));

assign sub_in = {V[0],V[1],V[2],V[3]};
assign {V_o[3],V_o_temp,V_o[1],V_o[2]} = sub_out;

assign V_o[0] = V_o_temp ^ rc;

endmodule
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
// genvar j;
// generate
//     for (j=0;j<4;j=j+1) begin
//         MixOneColumn m0(.in(in_col[j]),.out(out_col[j]),.out_inv(out_inv_col[j]));
//     end
// endgenerate

MixOneColumn m0(.in(in_col[0]), .out(out_col[0]), .out_inv(out_inv_col[0]));
MixOneColumn m1(.in(in_col[1]), .out(out_col[1]), .out_inv(out_inv_col[1]));
MixOneColumn m2(.in(in_col[2]), .out(out_col[2]), .out_inv(out_inv_col[2]));
MixOneColumn m3(.in(in_col[3]), .out(out_col[3]), .out_inv(out_inv_col[3]));

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
// genvar j;
// generate
//     for(j=0;j<4;j=j+1)begin
//         Xtime x0(.in(two_sum[j]),.out(two_sumx2[j]));
//     end
// endgenerate

Xtime x5(.in(two_sum[0]), .out(two_sumx2[0]));
Xtime x6(.in(two_sum[1]), .out(two_sumx2[1]));
Xtime x7(.in(two_sum[2]), .out(two_sumx2[2]));
Xtime x8(.in(two_sum[3]), .out(two_sumx2[3]));

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
module SubByte (
    in,out,dec
);
input [127:0] in;
output reg [127:0] out;
input dec;

reg [7:0] byte [0:15];
wire [7:0] sub [0:15];
integer i;
always @(*) begin
    for(i=0;i<16;i=i+1)begin
        byte[i] = in[127-8*i -: 8];
        out[127-8*i -: 8] = sub[i];
    end
end
// genvar j;
// generate
//     for (j=0;j<16;j=j+1)begin
//         SubOneByte s0(.in(byte[j]),.out(sub[j]),.dec(dec));
//     end
// endgenerate

SubOneByte s0(.in(byte[0]), .out(sub[0]), .dec(dec));
SubOneByte s1(.in(byte[1]), .out(sub[1]), .dec(dec));
SubOneByte s2(.in(byte[2]), .out(sub[2]), .dec(dec));
SubOneByte s3(.in(byte[3]), .out(sub[3]), .dec(dec));
SubOneByte s4(.in(byte[4]), .out(sub[4]), .dec(dec));
SubOneByte s5(.in(byte[5]), .out(sub[5]), .dec(dec));
SubOneByte s6(.in(byte[6]), .out(sub[6]), .dec(dec));
SubOneByte s7(.in(byte[7]), .out(sub[7]), .dec(dec));
SubOneByte s8(.in(byte[8]), .out(sub[8]), .dec(dec));
SubOneByte s9(.in(byte[9]), .out(sub[9]), .dec(dec));
SubOneByte s10(.in(byte[10]), .out(sub[10]), .dec(dec));
SubOneByte s11(.in(byte[11]), .out(sub[11]), .dec(dec));
SubOneByte s12(.in(byte[12]), .out(sub[12]), .dec(dec));
SubOneByte s13(.in(byte[13]), .out(sub[13]), .dec(dec));
SubOneByte s14(.in(byte[14]), .out(sub[14]), .dec(dec));
SubOneByte s15(.in(byte[15]), .out(sub[15]), .dec(dec));

endmodule

module SubByte_32 (
    in,out,dec
);
input [31:0] in;
output reg [31:0] out;
input dec;

reg [7:0] byte [0:3];
wire [7:0] sub [0:3];
integer i;
always @(*) begin
    for(i=0;i<4;i=i+1)begin
        byte[i] = in[31-8*i -: 8];
        out[31-8*i -: 8] = sub[i];
    end
end
// genvar j;
// generate
//     for (j=0;j<4;j=j+1)begin
//         SubOneByte s0(.in(byte[j]),.out(sub[j]),.dec(dec));
//     end
// endgenerate

SubOneByte s0(.in(byte[0]), .out(sub[0]), .dec(dec));
SubOneByte s1(.in(byte[1]), .out(sub[1]), .dec(dec));
SubOneByte s2(.in(byte[2]), .out(sub[2]), .dec(dec));
SubOneByte s3(.in(byte[3]), .out(sub[3]), .dec(dec));

endmodule

module SubByte_96 (
    in,out,dec
);
input [95:0] in;
output reg [95:0] out;
input dec;

reg [7:0] byte [0:11];
wire [7:0] sub [0:11];
integer i;
always @(*) begin
    for(i=0;i<12;i=i+1)begin
        byte[i] = in[95-8*i -: 8];
        out[95-8*i -: 8] = sub[i];
    end
end
// genvar j;
// generate
//     for (j=0;j<12;j=j+1)begin
//         SubOneByte s0(.in(byte[j]),.out(sub[j]),.dec(dec));
//     end
// endgenerate

SubOneByte s0(.in(byte[0]), .out(sub[0]), .dec(dec));
SubOneByte s1(.in(byte[1]), .out(sub[1]), .dec(dec));
SubOneByte s2(.in(byte[2]), .out(sub[2]), .dec(dec));
SubOneByte s3(.in(byte[3]), .out(sub[3]), .dec(dec));
SubOneByte s4(.in(byte[4]), .out(sub[4]), .dec(dec));
SubOneByte s5(.in(byte[5]), .out(sub[5]), .dec(dec));
SubOneByte s6(.in(byte[6]), .out(sub[6]), .dec(dec));
SubOneByte s7(.in(byte[7]), .out(sub[7]), .dec(dec));
SubOneByte s8(.in(byte[8]), .out(sub[8]), .dec(dec));
SubOneByte s9(.in(byte[9]), .out(sub[9]), .dec(dec));
SubOneByte s10(.in(byte[10]), .out(sub[10]), .dec(dec));
SubOneByte s11(.in(byte[11]), .out(sub[11]), .dec(dec));

endmodule



module SubOneByte (
    in,out,dec
);
input [7:0] in;
output [7:0] out;
input dec;

wire [7:0] c_in,c_out;
wire [7:0] c_in2,c_out2;
wire [7:0] m_in,m_out;
wire [7:0] minv_in,minv_out;
wire [7:0] g_in,g_out;
assign c_in = minv_out;
assign c_in2 = m_out;
assign minv_in = in;
assign g_in = (dec)? c_out:in;
assign m_in = g_out;
assign out = (dec)? g_out:c_out2;

MultiplyM m0(m_in,m_out);
MultiplyMinv m1 (minv_in,minv_out);
AddCinv c0(c_in,c_out);
AddC c1(c_in2,c_out2);
GFInverseTable g0(g_in,g_out);

endmodule

module MultiplyM(
    in,out
);
input [7:0] in;
output reg [7:0] out;
integer i;
always @(*) begin
    for(i=0;i<8;i=i+1)begin
        out[i] = in[i] ^ in[(i+4)%8] ^ in[(i+5)%8] ^ in[(i+6)%8] ^ in[(i+7)%8];
    end
end 

endmodule

module MultiplyMinv(
    in,out
);
input [7:0] in;
output reg [7:0] out;
integer i;
always @(*) begin
    for(i=0;i<8;i=i+1)begin
        out[i] = in[(i+2)%8] ^ in[(i+5)%8] ^ in[(i+7)%8] ;
    end
end
endmodule

module AddC(
    in,out
);
input [7:0] in;
output [7:0] out;

assign out = in ^ 8'b01100011;

endmodule

module AddCinv(
    in,out
);
input [7:0] in;
output [7:0] out;

assign out = in ^ 8'b00000101;

endmodule

module GFInverseTable (
    in,out
);
input [7:0] in;
output reg [7:0] out;
always @(*) begin
    case (in)
        0 : out = 0;
        1 : out = 1; 
        2 : out = 141; 
        3 : out = 246; 
        4 : out = 203; 
        5 : out = 82; 
        6 : out = 123; 
        7 : out = 209; 
        8 : out = 232; 
        9 : out = 79; 
        10 : out = 41; 
        11 : out = 192; 
        12 : out = 176; 
        13 : out = 225; 
        14 : out = 229; 
        15 : out = 199; 
        16 : out = 116; 
        17 : out = 180; 
        18 : out = 170; 
        19 : out = 75; 
        20 : out = 153; 
        21 : out = 43; 
        22 : out = 96; 
        23 : out = 95; 
        24 : out = 88; 
        25 : out = 63; 
        26 : out = 253; 
        27 : out = 204; 
        28 : out = 255; 
        29 : out = 64; 
        30 : out = 238; 
        31 : out = 178; 
        32 : out = 58; 
        33 : out = 110; 
        34 : out = 90; 
        35 : out = 241; 
        36 : out = 85; 
        37 : out = 77; 
        38 : out = 168; 
        39 : out = 201; 
        40 : out = 193; 
        41 : out = 10; 
        42 : out = 152; 
        43 : out = 21; 
        44 : out = 48; 
        45 : out = 68; 
        46 : out = 162; 
        47 : out = 194; 
        48 : out = 44; 
        49 : out = 69; 
        50 : out = 146; 
        51 : out = 108; 
        52 : out = 243; 
        53 : out = 57; 
        54 : out = 102; 
        55 : out = 66; 
        56 : out = 242; 
        57 : out = 53; 
        58 : out = 32; 
        59 : out = 111; 
        60 : out = 119; 
        61 : out = 187; 
        62 : out = 89; 
        63 : out = 25; 
        64 : out = 29; 
        65 : out = 254; 
        66 : out = 55; 
        67 : out = 103; 
        68 : out = 45; 
        69 : out = 49; 
        70 : out = 245; 
        71 : out = 105; 
        72 : out = 167; 
        73 : out = 100; 
        74 : out = 171; 
        75 : out = 19; 
        76 : out = 84; 
        77 : out = 37; 
        78 : out = 233; 
        79 : out = 9; 
        80 : out = 237; 
        81 : out = 92; 
        82 : out = 5; 
        83 : out = 202; 
        84 : out = 76; 
        85 : out = 36; 
        86 : out = 135; 
        87 : out = 191; 
        88 : out = 24; 
        89 : out = 62; 
        90 : out = 34; 
        91 : out = 240; 
        92 : out = 81; 
        93 : out = 236; 
        94 : out = 97; 
        95 : out = 23; 
        96 : out = 22; 
        97 : out = 94; 
        98 : out = 175; 
        99 : out = 211; 
        100 : out = 73; 
        101 : out = 166; 
        102 : out = 54; 
        103 : out = 67; 
        104 : out = 244; 
        105 : out = 71; 
        106 : out = 145; 
        107 : out = 223; 
        108 : out = 51; 
        109 : out = 147; 
        110 : out = 33; 
        111 : out = 59; 
        112 : out = 121; 
        113 : out = 183; 
        114 : out = 151; 
        115 : out = 133; 
        116 : out = 16; 
        117 : out = 181; 
        118 : out = 186; 
        119 : out = 60; 
        120 : out = 182; 
        121 : out = 112; 
        122 : out = 208; 
        123 : out = 6; 
        124 : out = 161; 
        125 : out = 250; 
        126 : out = 129; 
        127 : out = 130; 
        128 : out = 131; 
        129 : out = 126; 
        130 : out = 127; 
        131 : out = 128; 
        132 : out = 150; 
        133 : out = 115; 
        134 : out = 190; 
        135 : out = 86; 
        136 : out = 155; 
        137 : out = 158; 
        138 : out = 149; 
        139 : out = 217; 
        140 : out = 247; 
        141 : out = 2; 
        142 : out = 185; 
        143 : out = 164; 
        144 : out = 222; 
        145 : out = 106; 
        146 : out = 50; 
        147 : out = 109; 
        148 : out = 216; 
        149 : out = 138; 
        150 : out = 132; 
        151 : out = 114; 
        152 : out = 42; 
        153 : out = 20; 
        154 : out = 159; 
        155 : out = 136; 
        156 : out = 249; 
        157 : out = 220; 
        158 : out = 137; 
        159 : out = 154; 
        160 : out = 251; 
        161 : out = 124; 
        162 : out = 46; 
        163 : out = 195; 
        164 : out = 143; 
        165 : out = 184; 
        166 : out = 101; 
        167 : out = 72; 
        168 : out = 38; 
        169 : out = 200; 
        170 : out = 18; 
        171 : out = 74; 
        172 : out = 206; 
        173 : out = 231; 
        174 : out = 210; 
        175 : out = 98; 
        176 : out = 12; 
        177 : out = 224; 
        178 : out = 31; 
        179 : out = 239; 
        180 : out = 17; 
        181 : out = 117; 
        182 : out = 120; 
        183 : out = 113; 
        184 : out = 165; 
        185 : out = 142; 
        186 : out = 118; 
        187 : out = 61; 
        188 : out = 189; 
        189 : out = 188; 
        190 : out = 134; 
        191 : out = 87; 
        192 : out = 11; 
        193 : out = 40; 
        194 : out = 47; 
        195 : out = 163; 
        196 : out = 218; 
        197 : out = 212; 
        198 : out = 228; 
        199 : out = 15; 
        200 : out = 169; 
        201 : out = 39; 
        202 : out = 83; 
        203 : out = 4; 
        204 : out = 27; 
        205 : out = 252; 
        206 : out = 172; 
        207 : out = 230; 
        208 : out = 122; 
        209 : out = 7; 
        210 : out = 174; 
        211 : out = 99; 
        212 : out = 197; 
        213 : out = 219; 
        214 : out = 226; 
        215 : out = 234; 
        216 : out = 148; 
        217 : out = 139; 
        218 : out = 196; 
        219 : out = 213; 
        220 : out = 157; 
        221 : out = 248; 
        222 : out = 144; 
        223 : out = 107; 
        224 : out = 177; 
        225 : out = 13; 
        226 : out = 214; 
        227 : out = 235; 
        228 : out = 198; 
        229 : out = 14; 
        230 : out = 207; 
        231 : out = 173; 
        232 : out = 8; 
        233 : out = 78; 
        234 : out = 215; 
        235 : out = 227; 
        236 : out = 93; 
        237 : out = 80; 
        238 : out = 30; 
        239 : out = 179; 
        240 : out = 91; 
        241 : out = 35; 
        242 : out = 56; 
        243 : out = 52; 
        244 : out = 104; 
        245 : out = 70; 
        246 : out = 3; 
        247 : out = 140; 
        248 : out = 221; 
        249 : out = 156; 
        250 : out = 125; 
        251 : out = 160; 
        252 : out = 205; 
        253 : out = 26; 
        254 : out = 65; 
        255 : out = 28; 

    endcase
end
    
endmodule
module ShiftRow (
    in,out
);// {A0,A1....A15}
/*
    A0  A4  A8  A12
    A1  A5  A9  A13
    A2  A6  A10 A14
    A3  A7  A11 A15

*/

input [127:0] in;
output [127:0] out;

wire [7:0] inbyte [0:15];
wire [7:0] outbyte [0:15];

assign inbyte[ 0] = in[127:120];
assign inbyte[ 1] = in[119:112];
assign inbyte[ 2] = in[111:104];
assign inbyte[ 3] = in[103:96];
assign inbyte[ 4] = in[95:88];
assign inbyte[ 5] = in[87:80];
assign inbyte[ 6] = in[79:72];
assign inbyte[ 7] = in[71:64];
assign inbyte[ 8] = in[63:56];
assign inbyte[ 9] = in[55:48];
assign inbyte[10] = in[47:40];
assign inbyte[11] = in[39:32];
assign inbyte[12] = in[31:24];
assign inbyte[13] = in[23:16];
assign inbyte[14] = in[15:8];
assign inbyte[15] = in[7:0] ;

assign outbyte[ 0] = inbyte[ 0];
assign outbyte[ 1] = inbyte[ 5];
assign outbyte[ 2] = inbyte[10];
assign outbyte[ 3] = inbyte[15];
assign outbyte[ 4] = inbyte[ 4];
assign outbyte[ 5] = inbyte[ 9];
assign outbyte[ 6] = inbyte[14];
assign outbyte[ 7] = inbyte[ 3];
assign outbyte[ 8] = inbyte[ 8];
assign outbyte[ 9] = inbyte[13];
assign outbyte[10] = inbyte[ 2];
assign outbyte[11] = inbyte[ 7];
assign outbyte[12] = inbyte[12];
assign outbyte[13] = inbyte[ 1];
assign outbyte[14] = inbyte[ 6];
assign outbyte[15] = inbyte[11];

assign out = {outbyte[ 0],
            outbyte[ 1],
            outbyte[ 2],
            outbyte[ 3],
            outbyte[ 4],
            outbyte[ 5],
            outbyte[ 6],
            outbyte[ 7],
            outbyte[ 8],
            outbyte[ 9],
            outbyte[10],
            outbyte[11],
            outbyte[12],
            outbyte[13],
            outbyte[14],
            outbyte[15]};


    
endmodule


module InvShiftRow (
    in,out
);
// {A0,A1....A15}
/*
    A0  A4  A8  A12
    A1  A5  A9  A13
    A2  A6  A10 A14
    A3  A7  A11 A15
*/

/*
    A0  A4  A8  A12
    A13 A1  A5  A9
    A10 A14 A2  A6
    A7  A11 A15 A3
*/

input [127:0] in;
output [127:0] out;

wire [7:0] inbyte [0:15];
wire [7:0] outbyte [0:15];

assign inbyte[ 0] = in[127:120];
assign inbyte[ 1] = in[119:112];
assign inbyte[ 2] = in[111:104];
assign inbyte[ 3] = in[103:96];
assign inbyte[ 4] = in[95:88];
assign inbyte[ 5] = in[87:80];
assign inbyte[ 6] = in[79:72];
assign inbyte[ 7] = in[71:64];
assign inbyte[ 8] = in[63:56];
assign inbyte[ 9] = in[55:48];
assign inbyte[10] = in[47:40];
assign inbyte[11] = in[39:32];
assign inbyte[12] = in[31:24];
assign inbyte[13] = in[23:16];
assign inbyte[14] = in[15:8];
assign inbyte[15] = in[7:0] ;

assign outbyte[ 0] = inbyte[ 0];
assign outbyte[ 1] = inbyte[13];
assign outbyte[ 2] = inbyte[10];
assign outbyte[ 3] = inbyte[ 7];
assign outbyte[ 4] = inbyte[ 4];
assign outbyte[ 5] = inbyte[ 1];
assign outbyte[ 6] = inbyte[14];
assign outbyte[ 7] = inbyte[11];
assign outbyte[ 8] = inbyte[ 8];
assign outbyte[ 9] = inbyte[ 5];
assign outbyte[10] = inbyte[ 2];
assign outbyte[11] = inbyte[15];
assign outbyte[12] = inbyte[12];
assign outbyte[13] = inbyte[ 9];
assign outbyte[14] = inbyte[ 6];
assign outbyte[15] = inbyte[ 3];

assign out  = { outbyte[ 0], outbyte[ 1], outbyte[ 2], outbyte[ 3],
                outbyte[ 4], outbyte[ 5], outbyte[ 6], outbyte[ 7],
                outbyte[ 8], outbyte[ 9], outbyte[10], outbyte[11],
                outbyte[12], outbyte[13], outbyte[14],outbyte[15]};

endmodule

module AddRoundKey (
    in,key,out
);
    input [127:0] in,key;
    output [127:0] out;
    assign out = in^key;
endmodule

