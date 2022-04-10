module SubByte (
    in,out
);
input [127:0] in;
output [127:0] out;

wire [7:0] bytes [15:0];
wire [7:0] outbytes [15:0];

assign bytes[0] = in[7:0];
assign bytes[1] = in[15:8];
assign bytes[2] = in[23:16];
assign bytes[3] = in[31:24];
assign bytes[4] = in[39:32];
assign bytes[5] = in[47:40];
assign bytes[6] = in[55:48];
assign bytes[7] = in[63:56];
assign bytes[8] = in[71:64];
assign bytes[9] = in[79:72];
assign bytes[10] = in[87:80];
assign bytes[11] = in[95:88];
assign bytes[12] = in[103:96];
assign bytes[13] = in[111:104];
assign bytes[14] = in[119:112];
assign bytes[15] = in[127:120];

assign out = {outbytes[15],
              outbytes[14],
              outbytes[13],
              outbytes[12],
              outbytes[11],
              outbytes[10],
              outbytes[9],
              outbytes[8],
              outbytes[7],
              outbytes[6],
              outbytes[5],
              outbytes[4],
              outbytes[3],
              outbytes[2],
              outbytes[1],
              outbytes[0]};



STable s0(.in(bytes[0]), .out(outbytes[0]));
STable s1(.in(bytes[1]), .out(outbytes[1]));
STable s2(.in(bytes[2]), .out(outbytes[2]));
STable s3(.in(bytes[3]), .out(outbytes[3]));
STable s4(.in(bytes[4]), .out(outbytes[4]));
STable s5(.in(bytes[5]), .out(outbytes[5]));
STable s6(.in(bytes[6]), .out(outbytes[6]));
STable s7(.in(bytes[7]), .out(outbytes[7]));
STable s8(.in(bytes[8]), .out(outbytes[8]));
STable s9(.in(bytes[9]), .out(outbytes[9]));
STable s10(.in(bytes[10]), .out(outbytes[10]));
STable s11(.in(bytes[11]), .out(outbytes[11]));
STable s12(.in(bytes[12]), .out(outbytes[12]));
STable s13(.in(bytes[13]), .out(outbytes[13]));
STable s14(.in(bytes[14]), .out(outbytes[14]));
STable s15(.in(bytes[15]), .out(outbytes[15]));


    
endmodule

module InvSubByte (
    in,out
);
input [127:0] in;
output [127:0] out;

wire [7:0] bytes [15:0];
wire [7:0] outbytes [15:0];

assign bytes[0] = in[7:0];
assign bytes[1] = in[15:8];
assign bytes[2] = in[23:16];
assign bytes[3] = in[31:24];
assign bytes[4] = in[39:32];
assign bytes[5] = in[47:40];
assign bytes[6] = in[55:48];
assign bytes[7] = in[63:56];
assign bytes[8] = in[71:64];
assign bytes[9] = in[79:72];
assign bytes[10] = in[87:80];
assign bytes[11] = in[95:88];
assign bytes[12] = in[103:96];
assign bytes[13] = in[111:104];
assign bytes[14] = in[119:112];
assign bytes[15] = in[127:120];


InvSTable s0(.in(bytes[0]), .out(outbytes[0]));
InvSTable s1(.in(bytes[1]), .out(outbytes[1]));
InvSTable s2(.in(bytes[2]), .out(outbytes[2]));
InvSTable s3(.in(bytes[3]), .out(outbytes[3]));
InvSTable s4(.in(bytes[4]), .out(outbytes[4]));
InvSTable s5(.in(bytes[5]), .out(outbytes[5]));
InvSTable s6(.in(bytes[6]), .out(outbytes[6]));
InvSTable s7(.in(bytes[7]), .out(outbytes[7]));
InvSTable s8(.in(bytes[8]), .out(outbytes[8]));
InvSTable s9(.in(bytes[9]), .out(outbytes[9]));
InvSTable s10(.in(bytes[10]), .out(outbytes[10]));
InvSTable s11(.in(bytes[11]), .out(outbytes[11]));
InvSTable s12(.in(bytes[12]), .out(outbytes[12]));
InvSTable s13(.in(bytes[13]), .out(outbytes[13]));
InvSTable s14(.in(bytes[14]), .out(outbytes[14]));
InvSTable s15(.in(bytes[15]), .out(outbytes[15]));

assign out = {outbytes[15],
              outbytes[14],
              outbytes[13],
              outbytes[12],
              outbytes[11],
              outbytes[10],
              outbytes[9],
              outbytes[8],
              outbytes[7],
              outbytes[6],
              outbytes[5],
              outbytes[4],
              outbytes[3],
              outbytes[2],
              outbytes[1],
              outbytes[0]};

endmodule

module STable(in,out);

input [7:0] in;
output reg [7:0] out;

always @(*) begin
    case (in)
        0: out = 8'h63;
        1: out = 8'h7C;
        2: out = 8'h77;
        3: out = 8'h7B;
        4: out = 8'hF2;
        5: out = 8'h6B;
        6: out = 8'h6F;
        7: out = 8'hC5;
        8: out = 8'h30;
        9: out = 8'h01;
        10: out = 8'h67;
        11: out = 8'h2B;
        12: out = 8'hFE;
        13: out = 8'hD7;
        14: out = 8'hAB;
        15: out = 8'h76;
        16: out = 8'hCA;
        17: out = 8'h82;
        18: out = 8'hC9;
        19: out = 8'h7D;
        20: out = 8'hFA;
        21: out = 8'h59;
        22: out = 8'h47;
        23: out = 8'hF0;
        24: out = 8'hAD;
        25: out = 8'hD4;
        26: out = 8'hA2;
        27: out = 8'hAF;
        28: out = 8'h9C;
        29: out = 8'hA4;
        30: out = 8'h72;
        31: out = 8'hC0;
        32: out = 8'hB7;
        33: out = 8'hFD;
        34: out = 8'h93;
        35: out = 8'h26;
        36: out = 8'h36;
        37: out = 8'h3F;
        38: out = 8'hF7;
        39: out = 8'hCC;
        40: out = 8'h34;
        41: out = 8'hA5;
        42: out = 8'hE5;
        43: out = 8'hF1;
        44: out = 8'h71;
        45: out = 8'hD8;
        46: out = 8'h31;
        47: out = 8'h15;
        48: out = 8'h04;
        49: out = 8'hC7;
        50: out = 8'h23;
        51: out = 8'hC3;
        52: out = 8'h18;
        53: out = 8'h96;
        54: out = 8'h05;
        55: out = 8'h9A;
        56: out = 8'h07;
        57: out = 8'h12;
        58: out = 8'h80;
        59: out = 8'hE2;
        60: out = 8'hEB;
        61: out = 8'h27;
        62: out = 8'hB2;
        63: out = 8'h75;
        64: out = 8'h09;
        65: out = 8'h83;
        66: out = 8'h2C;
        67: out = 8'h1A;
        68: out = 8'h1B;
        69: out = 8'h6E;
        70: out = 8'h5A;
        71: out = 8'hA0;
        72: out = 8'h52;
        73: out = 8'h3B;
        74: out = 8'hD6;
        75: out = 8'hB3;
        76: out = 8'h29;
        77: out = 8'hE3;
        78: out = 8'h2F;
        79: out = 8'h84;
        80: out = 8'h53;
        81: out = 8'hD1;
        82: out = 8'h00;
        83: out = 8'hED;
        84: out = 8'h20;
        85: out = 8'hFC;
        86: out = 8'hB1;
        87: out = 8'h5B;
        88: out = 8'h6A;
        89: out = 8'hCB;
        90: out = 8'hBE;
        91: out = 8'h39;
        92: out = 8'h4A;
        93: out = 8'h4C;
        94: out = 8'h58;
        95: out = 8'hCF;
        96: out = 8'hD0;
        97: out = 8'hEF;
        98: out = 8'hAA;
        99: out = 8'hFB;
        100: out = 8'h43;
        101: out = 8'h4D;
        102: out = 8'h33;
        103: out = 8'h85;
        104: out = 8'h45;
        105: out = 8'hF9;
        106: out = 8'h02;
        107: out = 8'h7F;
        108: out = 8'h50;
        109: out = 8'h3C;
        110: out = 8'h9F;
        111: out = 8'hA8;
        112: out = 8'h51;
        113: out = 8'hA3;
        114: out = 8'h40;
        115: out = 8'h8F;
        116: out = 8'h92;
        117: out = 8'h9D;
        118: out = 8'h38;
        119: out = 8'hF5;
        120: out = 8'hBC;
        121: out = 8'hB6;
        122: out = 8'hDA;
        123: out = 8'h21;
        124: out = 8'h10;
        125: out = 8'hFF;
        126: out = 8'hF3;
        127: out = 8'hD2;
        128: out = 8'hCD;
        129: out = 8'h0C;
        130: out = 8'h13;
        131: out = 8'hEC;
        132: out = 8'h5F;
        133: out = 8'h97;
        134: out = 8'h44;
        135: out = 8'h17;
        136: out = 8'hC4;
        137: out = 8'hA7;
        138: out = 8'h7E;
        139: out = 8'h3D;
        140: out = 8'h64;
        141: out = 8'h5D;
        142: out = 8'h19;
        143: out = 8'h73;
        144: out = 8'h60;
        145: out = 8'h81;
        146: out = 8'h4F;
        147: out = 8'hDC;
        148: out = 8'h22;
        149: out = 8'h2A;
        150: out = 8'h90;
        151: out = 8'h88;
        152: out = 8'h46;
        153: out = 8'hEE;
        154: out = 8'hB8;
        155: out = 8'h14;
        156: out = 8'hDE;
        157: out = 8'h5E;
        158: out = 8'h0B;
        159: out = 8'hDB;
        160: out = 8'hE0;
        161: out = 8'h32;
        162: out = 8'h3A;
        163: out = 8'h0A;
        164: out = 8'h49;
        165: out = 8'h06;
        166: out = 8'h24;
        167: out = 8'h5C;
        168: out = 8'hC2;
        169: out = 8'hD3;
        170: out = 8'hAC;
        171: out = 8'h62;
        172: out = 8'h91;
        173: out = 8'h95;
        174: out = 8'hE4;
        175: out = 8'h79;
        176: out = 8'hE7;
        177: out = 8'hC8;
        178: out = 8'h37;
        179: out = 8'h6D;
        180: out = 8'h8D;
        181: out = 8'hD5;
        182: out = 8'h4E;
        183: out = 8'hA9;
        184: out = 8'h6C;
        185: out = 8'h56;
        186: out = 8'hF4;
        187: out = 8'hEA;
        188: out = 8'h65;
        189: out = 8'h7A;
        190: out = 8'hAE;
        191: out = 8'h08;
        192: out = 8'hBA;
        193: out = 8'h78;
        194: out = 8'h25;
        195: out = 8'h2E;
        196: out = 8'h1C;
        197: out = 8'hA6;
        198: out = 8'hB4;
        199: out = 8'hC6;
        200: out = 8'hE8;
        201: out = 8'hDD;
        202: out = 8'h74;
        203: out = 8'h1F;
        204: out = 8'h4B;
        205: out = 8'hBD;
        206: out = 8'h8B;
        207: out = 8'h8A;
        208: out = 8'h70;
        209: out = 8'h3E;
        210: out = 8'hB5;
        211: out = 8'h66;
        212: out = 8'h48;
        213: out = 8'h03;
        214: out = 8'hF6;
        215: out = 8'h0E;
        216: out = 8'h61;
        217: out = 8'h35;
        218: out = 8'h57;
        219: out = 8'hB9;
        220: out = 8'h86;
        221: out = 8'hC1;
        222: out = 8'h1D;
        223: out = 8'h9E;
        224: out = 8'hE1;
        225: out = 8'hF8;
        226: out = 8'h98;
        227: out = 8'h11;
        228: out = 8'h69;
        229: out = 8'hD9;
        230: out = 8'h8E;
        231: out = 8'h94;
        232: out = 8'h9B;
        233: out = 8'h1E;
        234: out = 8'h87;
        235: out = 8'hE9;
        236: out = 8'hCE;
        237: out = 8'h55;
        238: out = 8'h28;
        239: out = 8'hDF;
        240: out = 8'h8C;
        241: out = 8'hA1;
        242: out = 8'h89;
        243: out = 8'h0D;
        244: out = 8'hBF;
        245: out = 8'hE6;
        246: out = 8'h42;
        247: out = 8'h68;
        248: out = 8'h41;
        249: out = 8'h99;
        250: out = 8'h2D;
        251: out = 8'h0F;
        252: out = 8'hB0;
        253: out = 8'h54;
        254: out = 8'hBB;
        255: out = 8'h16;
    endcase
end

endmodule

module InvSTable(in,out);

input [7:0] in;
output reg [7:0] out;

always @(*) begin
    case (in)
        0: out = 8'h52;
        1: out = 8'h09;
        2: out = 8'h6A;
        3: out = 8'hD5;
        4: out = 8'h30;
        5: out = 8'h36;
        6: out = 8'hA5;
        7: out = 8'h38;
        8: out = 8'hBF;
        9: out = 8'h40;
        10: out = 8'hA3;
        11: out = 8'h9E;
        12: out = 8'h81;
        13: out = 8'hF3;
        14: out = 8'hD7;
        15: out = 8'hFB;
        16: out = 8'h7C;
        17: out = 8'hE3;
        18: out = 8'h39;
        19: out = 8'h82;
        20: out = 8'h9B;
        21: out = 8'h2F;
        22: out = 8'hFF;
        23: out = 8'h87;
        24: out = 8'h34;
        25: out = 8'h8E;
        26: out = 8'h43;
        27: out = 8'h44;
        28: out = 8'hC4;
        29: out = 8'hDE;
        30: out = 8'hE9;
        31: out = 8'hCB;
        32: out = 8'h54;
        33: out = 8'h7B;
        34: out = 8'h94;
        35: out = 8'h32;
        36: out = 8'hA6;
        37: out = 8'hC2;
        38: out = 8'h23;
        39: out = 8'h3D;
        40: out = 8'hEE;
        41: out = 8'h4C;
        42: out = 8'h95;
        43: out = 8'h0B;
        44: out = 8'h42;
        45: out = 8'hFA;
        46: out = 8'hC3;
        47: out = 8'h4E;
        48: out = 8'h08;
        49: out = 8'h2E;
        50: out = 8'hA1;
        51: out = 8'h66;
        52: out = 8'h28;
        53: out = 8'hD9;
        54: out = 8'h24;
        55: out = 8'hB2;
        56: out = 8'h76;
        57: out = 8'h5B;
        58: out = 8'hA2;
        59: out = 8'h49;
        60: out = 8'h6D;
        61: out = 8'h8B;
        62: out = 8'hD1;
        63: out = 8'h25;
        64: out = 8'h72;
        65: out = 8'hF8;
        66: out = 8'hF6;
        67: out = 8'h64;
        68: out = 8'h86;
        69: out = 8'h68;
        70: out = 8'h98;
        71: out = 8'h16;
        72: out = 8'hD4;
        73: out = 8'hA4;
        74: out = 8'h5C;
        75: out = 8'hCC;
        76: out = 8'h5D;
        77: out = 8'h65;
        78: out = 8'hB6;
        79: out = 8'h92;
        80: out = 8'h6C;
        81: out = 8'h70;
        82: out = 8'h48;
        83: out = 8'h50;
        84: out = 8'hFD;
        85: out = 8'hED;
        86: out = 8'hB9;
        87: out = 8'hDA;
        88: out = 8'h5E;
        89: out = 8'h15;
        90: out = 8'h46;
        91: out = 8'h57;
        92: out = 8'hA7;
        93: out = 8'h8D;
        94: out = 8'h9D;
        95: out = 8'h84;
        96: out = 8'h90;
        97: out = 8'hD8;
        98: out = 8'hAB;
        99: out = 8'h00;
        100: out = 8'h8C;
        101: out = 8'hBC;
        102: out = 8'hD3;
        103: out = 8'h0A;
        104: out = 8'hF7;
        105: out = 8'hE4;
        106: out = 8'h58;
        107: out = 8'h05;
        108: out = 8'hB8;
        109: out = 8'hB3;
        110: out = 8'h45;
        111: out = 8'h06;
        112: out = 8'hD0;
        113: out = 8'h2C;
        114: out = 8'h1E;
        115: out = 8'h8F;
        116: out = 8'hCA;
        117: out = 8'h3F;
        118: out = 8'h0F;
        119: out = 8'h02;
        120: out = 8'hC1;
        121: out = 8'hAF;
        122: out = 8'hBD;
        123: out = 8'h03;
        124: out = 8'h01;
        125: out = 8'h13;
        126: out = 8'h8A;
        127: out = 8'h6B;
        128: out = 8'h3A;
        129: out = 8'h91;
        130: out = 8'h11;
        131: out = 8'h41;
        132: out = 8'h4F;
        133: out = 8'h67;
        134: out = 8'hDC;
        135: out = 8'hEA;
        136: out = 8'h97;
        137: out = 8'hF2;
        138: out = 8'hCF;
        139: out = 8'hCE;
        140: out = 8'hF0;
        141: out = 8'hB4;
        142: out = 8'hE6;
        143: out = 8'h73;
        144: out = 8'h96;
        145: out = 8'hAC;
        146: out = 8'h74;
        147: out = 8'h22;
        148: out = 8'hE7;
        149: out = 8'hAD;
        150: out = 8'h35;
        151: out = 8'h85;
        152: out = 8'hE2;
        153: out = 8'hF9;
        154: out = 8'h37;
        155: out = 8'hE8;
        156: out = 8'h1C;
        157: out = 8'h75;
        158: out = 8'hDF;
        159: out = 8'h6E;
        160: out = 8'h47;
        161: out = 8'hF1;
        162: out = 8'h1A;
        163: out = 8'h71;
        164: out = 8'h1D;
        165: out = 8'h29;
        166: out = 8'hC5;
        167: out = 8'h89;
        168: out = 8'h6F;
        169: out = 8'hB7;
        170: out = 8'h62;
        171: out = 8'h0E;
        172: out = 8'hAA;
        173: out = 8'h18;
        174: out = 8'hBE;
        175: out = 8'h1B;
        176: out = 8'hFC;
        177: out = 8'h56;
        178: out = 8'h3E;
        179: out = 8'h4B;
        180: out = 8'hC6;
        181: out = 8'hD2;
        182: out = 8'h79;
        183: out = 8'h20;
        184: out = 8'h9A;
        185: out = 8'hDB;
        186: out = 8'hC0;
        187: out = 8'hFE;
        188: out = 8'h78;
        189: out = 8'hCD;
        190: out = 8'h5A;
        191: out = 8'hF4;
        192: out = 8'h1F;
        193: out = 8'hDD;
        194: out = 8'hA8;
        195: out = 8'h33;
        196: out = 8'h88;
        197: out = 8'h07;
        198: out = 8'hC7;
        199: out = 8'h31;
        200: out = 8'hB1;
        201: out = 8'h12;
        202: out = 8'h10;
        203: out = 8'h59;
        204: out = 8'h27;
        205: out = 8'h80;
        206: out = 8'hEC;
        207: out = 8'h5F;
        208: out = 8'h60;
        209: out = 8'h51;
        210: out = 8'h7F;
        211: out = 8'hA9;
        212: out = 8'h19;
        213: out = 8'hB5;
        214: out = 8'h4A;
        215: out = 8'h0D;
        216: out = 8'h2D;
        217: out = 8'hE5;
        218: out = 8'h7A;
        219: out = 8'h9F;
        220: out = 8'h93;
        221: out = 8'hC9;
        222: out = 8'h9C;
        223: out = 8'hEF;
        224: out = 8'hA0;
        225: out = 8'hE0;
        226: out = 8'h3B;
        227: out = 8'h4D;
        228: out = 8'hAE;
        229: out = 8'h2A;
        230: out = 8'hF5;
        231: out = 8'hB0;
        232: out = 8'hC8;
        233: out = 8'hEB;
        234: out = 8'hBB;
        235: out = 8'h3C;
        236: out = 8'h83;
        237: out = 8'h53;
        238: out = 8'h99;
        239: out = 8'h61;
        240: out = 8'h17;
        241: out = 8'h2B;
        242: out = 8'h04;
        243: out = 8'h7E;
        244: out = 8'hBA;
        245: out = 8'h77;
        246: out = 8'hD6;
        247: out = 8'h26;
        248: out = 8'hE1;
        249: out = 8'h69;
        250: out = 8'h14;
        251: out = 8'h63;
        252: out = 8'h55;
        253: out = 8'h21;
        254: out = 8'h0C;
        255: out = 8'h7D;
    endcase
end

endmodule