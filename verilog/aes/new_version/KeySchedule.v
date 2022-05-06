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




module rc_next(
    rc,dec,rc_nxt
);
input [7:0] rc;
input dec;
output [7:0] rc_nxt;
wire [7:0] rcx2,rcx2_inv;
assign rc_nxt = (dec)? rcx2_inv : rcx2;

Xtime x2(.in(rc),.out(rcx2));
InvXtime invx2(.in(rc),.out(rcx2_inv));

endmodule

module InvXtime (
    in,out
);
input [7:0] in;
output [7:0] out;
assign out[0] = in[0] ^ in[1];
assign out[1] = in[2];
assign out[2] = in[0] ^ in[3];
assign out[3] = in[0] ^ in[4];
assign out[4] = in[5];
assign out[5] = in[6];
assign out[6] = in[7];
assign out[7] = in[0];

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