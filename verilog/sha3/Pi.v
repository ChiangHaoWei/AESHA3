module Pi (
    in,out
);
input [0:1599] in;
output reg [0:1599] out;

integer x,y,z;

always @(*) begin
    for(x=0;x<5;x=x+1)begin
        for (y = 0;y<5 ;y=y+1 ) begin
            for (z = 0;z<64;z=z+1 ) begin
                out[64*(5*y+x)+z] = in[64*(5*x+((x+3*y)%5))+z];
            end
        end
    end
end
    
endmodule