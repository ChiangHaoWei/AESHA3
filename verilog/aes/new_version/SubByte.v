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
genvar j;
generate
    for (j=0;j<16;j=j+1)begin
        SubOneByte s0(.in(byte[j]),.out(sub[j]),.dec(dec));
    end
endgenerate
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
genvar j;
generate
    for (j=0;j<4;j=j+1)begin
        SubOneByte s0(.in(byte[j]),.out(sub[j]),.dec(dec));
    end
endgenerate
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
genvar j;
generate
    for (j=0;j<12;j=j+1)begin
        SubOneByte s0(.in(byte[j]),.out(sub[j]),.dec(dec));
    end
endgenerate
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