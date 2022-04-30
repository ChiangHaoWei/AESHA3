module AESOneRound(//two addroundkey
    in,out,roundkey,dec,nomix//nomix = 1 when no mixcolumn
);
input [127:0] in,roundkey;
input dec;
output reg [127:0] out;
input nomix;


reg [127:0]  key_in ,sub_in ,inv_sub_in ,inv_sh_in ,mix_in ,sh_in;
wire [127:0] key_out,sub_out,inv_sub_out,inv_sh_out,mix_out,sh_out;
reg [127:0] key_inv_in;
wire [127:0] key_inv_out;

AddRoundKey a0(.in(key_in),.out(key_out),.key(roundkey));
AddRoundKey ainv(.in(key_inv_in),.out(key_inv_out),.key(roundkey));
SubByte s0(.in(sub_in),.out(sub_out));
InvSubByte s1(.in(inv_sub_in),.out(inv_sub_out));
ShiftRow s2(.in(sh_in),.out(sh_out));
InvShiftRow s3(.in(inv_sh_in),.out(inv_sh_out));
MixColumn m0(.in(mix_in),.out_test(mix_out),.dec(dec));

always @(*) begin
    if(nomix)
        inv_sh_in = key_inv_out;
    else
        inv_sh_in = mix_out;
    inv_sub_in = inv_sh_out;
    sub_in = in;
    sh_in = sub_out;
    key_inv_in = in;
    if(nomix)
        key_in = sh_out;
    else
        key_in = mix_out;
    if(dec)begin //add -> mix -> invsh -> invsub
        //key_in = in;
        mix_in = key_inv_out;
        //inv_sh_in = mix_out;
        //inv_sub_in = inv_sh_out;
        out = inv_sub_out;
    end
    else begin //sub -> sh -> mix -> add
        //sub_in = in;
        //sh_in = sub_out;
        mix_in = sh_out;
        // if(nomix)
        //     key_in = sh_out;
        // else
        //     key_in = mix_out;
        out = key_out;
    end
end


endmodule
