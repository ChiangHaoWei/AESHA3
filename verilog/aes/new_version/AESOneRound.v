module AESOneRound (
    in,out,roundkey,dec,nomix,subbyteonly,sub_in,sub_out,//nomix = 1 when no mixcolumn
    clk
);
input [127:0] in,roundkey;
input dec;
input subbyteonly;
input [31:0] sub_in;
output [31:0] sub_out;
output reg [127:0] out;
input nomix;
input clk;


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
