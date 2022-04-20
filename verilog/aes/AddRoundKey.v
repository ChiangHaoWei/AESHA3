module AddRoundKey (
    in,key,out
);
    input [127:0] in,key;
    output [127:0] out;
    assign out = in^key;
endmodule