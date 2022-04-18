module Theta (
  in, out
);
    input      [0:1599] in;
    output reg [0:1599] out;

    reg [319:0] columns;

    integer i, j, k;
    


    always @(*) begin
        for (j=0; j<5; j=j+1) begin
            for (k=0; k<64; k=k+1) begin
                columns[j*64+k] = in[j*64+k] ^ in[(j+5)*64+k] ^ in[(j+10)*64+k] ^ in[(j+15)*64+k] ^ in[(j+20)*64+k];
            end
        end
        
        for (i=0; i<5; i=i+1) begin
            for (j=0; j<5; j=j+1) begin
                for (k=0; k<64; k=k+1) begin
                    if (k==0) begin
                        if (j==0) out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k] ^ columns[(4)*64+k] ^ columns[((j+1)%5)*64+(63)];
                        else out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k] ^ columns[((j-1)%5)*64+k] ^ columns[((j+1)%5)*64+(63)];
                    end
                    else if (j==0) begin
                        if (k==0) out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k] ^ columns[(4)*64+k] ^ columns[((j+1)%5)*64+(63)];
                        else out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k] ^ columns[(4)*64+k] ^ columns[((j+1)%5)*64+((k-1)%64)];
                    end
                    else out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k] ^ columns[((j-1)%5)*64+k] ^ columns[((j+1)%5)*64+((k-1)%64)];
                end
            end
        end
    end

  
endmodule