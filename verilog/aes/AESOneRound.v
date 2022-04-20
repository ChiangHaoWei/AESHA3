module AESOneRound (
    in,out,roundkey,dec
);
input [127:0] in,roundkey;
input dec;
output reg [127:0] out;


reg [127:0]  key_in ,sub_in ,inv_sub_in ,inv_sh_in ,mix_in ,sh_in;
wire [127:0] key_out,sub_out,inv_sub_out,inv_sh_out,mix_out,sh_out;

AddRoundKey a0(.in(key_in),.out(key_out),.key(roundkey));
SubByte s0(.in(sub_in),.out(sub_out));
InvSubByte s1(.in(inv_sub_in),.out(inv_sub_out));
ShiftRow s2(.in(sh_in),.out(sh_out));
InvShiftRow s3(.in(inv_sh_in),.out(inv_sh_out));
MixColumn m0(.in(mix_in),.out_test(mix_out),.dec(dec));

always @(*) begin
    inv_sh_in = mix_out;
    inv_sub_in = inv_sh_out;
    sub_in = in;
    sh_in = sub_out;
    if(dec)begin //add -> mix -> invsh -> invsub
        key_in = in;
        mix_in = key_out;
        //inv_sh_in = mix_out;
        //inv_sub_in = inv_sh_out;
        out = inv_sub_out;
    end
    else begin //sub -> sh -> mix -> add
        //sub_in = in;
        //sh_in = sub_out;
        mix_in = sh_out;
        key_in = mix_out;
        out = key_out;
    end
end


endmodule
