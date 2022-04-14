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