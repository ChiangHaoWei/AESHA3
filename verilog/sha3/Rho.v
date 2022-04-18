module Rho (
    in,out
);
input [1599:0] in;
output [1599:0] out;

wire [63:0] in_lane [0:24];
wire [63:0] out_lane [0:24];

assign {in_lane[ 0],in_lane[ 1],in_lane[ 2],in_lane[ 3],in_lane[ 4],
        in_lane[ 5],in_lane[ 6],in_lane[ 7],in_lane[ 8],in_lane[ 9],
        in_lane[10],in_lane[11],in_lane[12],in_lane[13],in_lane[14],
        in_lane[15],in_lane[16],in_lane[17],in_lane[18],in_lane[19],
        in_lane[20],in_lane[21],in_lane[22],in_lane[23],in_lane[24]} = in;

assign out_lane[0] = in_lane[0];
assign out_lane[1] = {in_lane[1][0],in_lane[1][63:1]};//1
assign out_lane[2] = {in_lane[2][61:0],in_lane[2][63:62]}; //190 -> 62,left shift 2
assign out_lane[3] = {in_lane[3][27:0],in_lane[3][63:28]}; //28
assign out_lane[4] = {in_lane[4][26:0],in_lane[4][63:27]}; //91 -> 27

assign out_lane[5] = {in_lane[5][35:0],in_lane[5][63:36]};//36
assign out_lane[6] = {in_lane[6][43:0],in_lane[6][63:44]};//300 -> 44
assign out_lane[7] = {in_lane[7][5:0],in_lane[7][63:6]};//6
assign out_lane[8] = {in_lane[8][54:0],in_lane[8][63:55]};//55
assign out_lane[9] = {in_lane[9][19:0],in_lane[9][63:20]};//276 -> 20

assign out_lane[10] = {in_lane[10][2:0],in_lane[10][63:3]};//3
assign out_lane[11] = {in_lane[11][9:0],in_lane[11][63:10]};//10
assign out_lane[12] = {in_lane[12][42:0],in_lane[12][63:43]};//171 -> 43
assign out_lane[13] = {in_lane[13][24:0],in_lane[13][63:25]};//153 -> 25
assign out_lane[14] = {in_lane[14][38:0],in_lane[14][63:39]};//231 -> 39

assign out_lane[15] = {in_lane[15][40:0],in_lane[15][63:41]};//105 -> 41
assign out_lane[16] = {in_lane[16][44:0],in_lane[16][63:45]};//45
assign out_lane[17] = {in_lane[17][14:0],in_lane[17][63:15]};//15
assign out_lane[18] = {in_lane[18][20:0],in_lane[18][63:21]};//21
assign out_lane[19] = {in_lane[19][7:0],in_lane[19][63:8]};//136 -> 8

assign out_lane[20] = {in_lane[20][17:0],in_lane[20][63:18]};//210 -> 18
assign out_lane[21] = {in_lane[21][1:0],in_lane[21][63:2]};//66 -> 2
assign out_lane[22] = {in_lane[22][60:0],in_lane[22][63:61]};//253 -> 61
assign out_lane[23] = {in_lane[23][55:0],in_lane[23][63:56]};//120 -> 56
assign out_lane[24] = {in_lane[24][13:0],in_lane[24][63:14]};//78 -> 14

assign out = 
       {out_lane[ 0],out_lane[ 1],out_lane[ 2],out_lane[ 3],out_lane[ 4],
        out_lane[ 5],out_lane[ 6],out_lane[ 7],out_lane[ 8],out_lane[ 9],
        out_lane[10],out_lane[11],out_lane[12],out_lane[13],out_lane[14],
        out_lane[15],out_lane[16],out_lane[17],out_lane[18],out_lane[19],
        out_lane[20],out_lane[21],out_lane[22],out_lane[23],out_lane[24]};
    
endmodule