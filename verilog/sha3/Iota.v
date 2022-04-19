module Iota(
    in,out,round
);
    input [0:1599] in;

    input  [4:0] round;
    output reg [0:1599] out;

    wire[0:167] rc ;
    assign rc=168'b100000001011000111101000011111111001000010100111110101010111000001100010101100110010111111011110011011101110010101001010001001011010001100111001111000110110000100010111;
    wire [7:0] z;
    assign z={3'b000,round};
    reg [7:0] tem;


    integer i,j,k;
    always @(*) begin
        tem=(z<<3)-z;
        for (i=0; i<5; i=i+1) begin
            for (j=0; j<5; j=j+1) begin
                if ((i!=0)||(j!=0)) 
                begin
                    for(k=0;k<64;k=k+1) begin
                        out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k];

                    end


                end
                
                else
                begin
                    for(k=0;k<64;k=k+1) begin
                        case(k)
                            32'd0: begin
                            out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k]^rc[tem];
                            end


                            32'd1:begin
                            out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k]^rc[1+tem];
                            end


                            32'd3:begin
                            out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k]^rc[2+tem];
                            end

                            32'd7:begin
                            out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k]^rc[3+tem];
                            end
                            32'd15:begin
                            out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k]^rc[4+tem];
                            end
                            32'd31:begin
                            out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k]^rc[5+tem];
                            end
                            32'd63:begin
                            out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k]^rc[6+tem];
                            end
                            default:begin
                                out[(i*5+j)*64 + k] = in[(i*5+j)*64 + k];
                            end

                        endcase
                    end
                end
            end
        end
        
    end
endmodule

