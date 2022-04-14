module XORUnit (
    in,out
);
// XOR every 5 bytes of input to one byte
input [799:0] in;
output [159:0] out;

wire [39:0] columns [0:19];
reg [7:0] out_byte [0:19];

assign {columns[ 0],columns[ 1],columns[ 2],columns[ 3],columns[ 4],
        columns[ 5],columns[ 6],columns[ 7],columns[ 8],columns[ 9],
        columns[10],columns[11],columns[12],columns[13],columns[14],
        columns[15],columns[16],columns[17],columns[18],columns[19]} = in;
assign out = 
       {out_byte[ 0],out_byte[ 1],out_byte[ 2],out_byte[ 3],out_byte[ 4],
        out_byte[ 5],out_byte[ 6],out_byte[ 7],out_byte[ 8],out_byte[ 9],
        out_byte[10],out_byte[11],out_byte[12],out_byte[13],out_byte[14],
        out_byte[15],out_byte[16],out_byte[17],out_byte[18],out_byte[19]};

integer i;
always @(*) begin
    for(i=0;i<20;i=i+1)begin
        out_byte[i] = columns[i][39:32] ^ columns[i][31:24] ^ columns[i][23:16] ^ columns[i][15:8] ^ columns[i][7:0];
    end
end


endmodule