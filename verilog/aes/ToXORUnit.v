module ToXORUnit (
    roundkey, mix_out, out
);
input [127:0] roundkey;
input [511:0] mix_out;
output [799:0] out;

wire [7:0] key_byte [0:15];
wire [31:0] mix_out_bytes [0:15];

assign {mix_out_bytes[ 0],mix_out_bytes[ 1],mix_out_bytes[ 2],mix_out_bytes[ 3],
        mix_out_bytes[ 4],mix_out_bytes[ 5],mix_out_bytes[ 6],mix_out_bytes[ 7],
        mix_out_bytes[ 8],mix_out_bytes[ 9],mix_out_bytes[10],mix_out_bytes[11],
        mix_out_bytes[12],mix_out_bytes[13],mix_out_bytes[14],mix_out_bytes[15]} = mix_out;

assign {
    key_byte[ 0],key_byte[ 1],key_byte[ 2],key_byte[ 3],
    key_byte[ 4],key_byte[ 5],key_byte[ 6],key_byte[ 7],
    key_byte[ 8],key_byte[ 9],key_byte[10],key_byte[11],
    key_byte[12],key_byte[13],key_byte[14],key_byte[15]
} = roundkey;

assign out = {
    mix_out_bytes[ 0],key_byte[ 0],mix_out_bytes[ 1],key_byte[ 1],mix_out_bytes[ 2],key_byte[ 2],mix_out_bytes[ 3],key_byte[ 3],40'b0,
    mix_out_bytes[ 4],key_byte[ 4],mix_out_bytes[ 5],key_byte[ 5],mix_out_bytes[ 6],key_byte[ 6],mix_out_bytes[ 7],key_byte[ 7],40'b0,
    mix_out_bytes[ 8],key_byte[ 8],mix_out_bytes[ 9],key_byte[ 9],mix_out_bytes[10],key_byte[10],mix_out_bytes[11],key_byte[11],40'b0,
    mix_out_bytes[12],key_byte[12],mix_out_bytes[13],key_byte[13],mix_out_bytes[14],key_byte[14],mix_out_bytes[15],key_byte[15],40'b0
};
    
endmodule