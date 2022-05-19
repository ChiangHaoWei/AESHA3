module ShiftBytes# (
    parameter BW = 256
)(in, out);
    input      [BW-1:0]  in;
    output reg [BW-1:0] out;
    integer i, j;

    always @(*) begin
        for (i=(BW>>3)-1; i>=0; i=i-1) begin
            for (j=0; j<8; j=j+1) begin
                out[i*8+7-j] = in[i*8+j];
            end
        end
    end
    
endmodule