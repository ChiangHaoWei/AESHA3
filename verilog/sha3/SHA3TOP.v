module xor_unit(a,b,xor_o);

input [1599:0] a;
input [1599:0] b;
output  [1599:0]   xor_o;
assign xor_o=a^b;



endmodule



module SHA3(
    in, more, in_valid, out, hash_next, ready,clk,out_valid,rst_n
);
input [1087:0] in;
input more, in_valid,rst_n;

output  ready;
input clk;
output hash_next;
output out_valid;
output reg [255:0] out;



// intermediate
wire [1599:0] f_out;
reg [1599:0]  xor_a;
wire [1599:0]  xor_out;
reg [1599:0]  xor_b;
reg [1599:0]  f_mid_w;
reg [1599:0]  f_mid_r;


reg [4:0] round_nxt;
reg [4:0] round;
reg  [2:0] state,state_nxt;
// Definition of states
parameter IDLE = 3'b000;
parameter computing1  = 3'b001;
parameter computing2  =3'b010;
parameter second_idle  = 3'b011;
parameter OUT  = 3'b100;

reg  [2:0] xor_state,xor_state_nxt;
// Definition of xor_states
parameter  theta_1= 3'b000;
parameter  outside= 3'b001;
parameter   chi_s= 3'b010;
parameter   theta_2= 3'b011;
parameter   no_use= 3'b011;


//some reg
reg [319:0] columns;
wire [255:0] out_rev;
reg [1599:0] f_in,f_nxt;
wire [0:1599] theta_out,theta_in;
wire [0:1599] chi_in,chi_out;
wire [1599:0]  rho_out,pi_out;
assign theta_in=f_in;
assign theta_out=xor_out;
assign chi_out=xor_out;

assign out_rev=f_out[1599:1344];
assign out_valid = ((state==OUT))? 1'b1:1'b0 ;

integer i,j,k;
always @(*) begin
    for (i=0; i<=248; i=i+8) begin
        for(j=0;j<8;j=j+1) begin
            out[i+j]=out_rev[i+7-j];

        end
        
    end
end


xor_unit  xor_me(.a(xor_a),.b(xor_b),.xor_o(xor_out));



Rho    R1(.in(theta_out),.out(rho_out));

Pi     p1(.in(rho_out),.out(pi_out));

Iota  io1(.in(chi_out),.out(f_out),.round(round));




always @(*) begin
    for (j=0; j<5; j=j+1) begin
        for (k=0; k<64; k=k+1) begin
            columns[j*64+k] =  theta_in[j*64+k] ^ theta_in[(j+5)*64+k] ^ theta_in[(j+10)*64+k] ^ theta_in[(j+15)*64+k] ^ theta_in[(j+20)*64+k];
        end
    end
end

//comb


integer a,b,c;
always @(*) begin
    f_mid_w=pi_out;
    case(state)
    
    IDLE:
    begin
        xor_b=1600'b0;
        xor_a=1600'b0;
        round_nxt=0;
        if (in_valid)
        begin
            state_nxt=computing1;
            f_nxt[1599:512]=in;
            f_nxt[511:0]=512'b0;
        end
        else
        begin
            state_nxt=IDLE;
            f_nxt=0;
        end
    end

    computing1:
    begin
        f_nxt=f_out;
        round_nxt=round;
        state_nxt=computing2;
        for (a = 0; a<5;a=a+1 ) begin
            for (b = 0;b<5 ;b=b+1 ) begin
                for (c = 0;c<64 ;c=c+1 ) begin
                    if (c==0) begin
                        if (b==0) begin
                            xor_b[(a*5+b)*64+c]=columns[(4)*64+c] ^ columns[((b+1)%5)*64+63];
                            xor_a[(a*5+b)*64+c]=theta_in[(a*5+b)*64+c];
                            
                        end
                        else begin
                            xor_b[(a*5+b)*64+c]=columns[((b-1)%5)*64+c] ^ columns[((b+1)%5)*64+(63)];
                            xor_a[(a*5+b)*64+c]=theta_in[(a*5+b)*64+c];
                            
                        end
                        
                    end
                    else if (b==0) begin
                        if (c==0) begin
                            xor_b[(a*5+b)*64+c]=columns[(4)*64+c] ^ columns[((b+1)%5)*64+(63)];
                            xor_a[(a*5+b)*64+c]=theta_in[(a*5+b)*64+c];
                            
                        end
                        else begin
                            xor_b[(a*5+b)*64+c]=columns[(4)*64+c] ^ columns[((b+1)%5)*64+((c-1)%64)];
                            xor_a[(a*5+b)*64+c]=theta_in[(a*5+b)*64+c];
                        end
                        
                        
                    end
                    else begin
                        xor_b[(a*5+b)*64+c]=columns[((b-1)%5)*64+c] ^ columns[((b+1)%5)*64+((c-1)%64)];
                        xor_a[(a*5+b)*64+c]=theta_in[(a*5+b)*64+c];;
                        
                    end
                   
                    
                end
            end
        end

    end
    computing2:
    begin
        round_nxt=round+1;
        f_nxt=f_out;
        for (a=0;a<5;a=a+1) begin
            for (b=0;b<5;b=b+1) begin
                for (c=0;c<64;c=c+1) begin
                   xor_b[64*(5*a+b)+c]=  ((~chi_in[64*(5*b+((a+1)%5))+c]) & (chi_in[64*(5*b+((a+2)%5))+c]));
                   xor_a[64*(5*a+b)+c] =chi_in[64*(5*a+b)+c];
                end
            end
        end
        if((round ==22) && (more))begin
            state_nxt=second_idle;
            
        end
        else if (round==22)
        begin
            state_nxt=OUT;
            
        end
        else
        begin
            state_nxt=computing1;
        end


    end
    second_idle:
    begin
        if (in_valid) begin
            xor_a={f_out[1599:512] ,{512'b0}};
            xor_b={ in,{512'b0}};
            f_nxt=xor_out;
            round_nxt=0;
            state_nxt=computing1;




        end
        else begin
            f_nxt=f_in;
            round_nxt=round;
            state_nxt=second_idle;
        end


    end
    OUT:
    begin
        state_nxt=IDLE;
        round_nxt=0;
        f_nxt=0;

    end


    default:
    begin
        round_nxt = 0;
        state_nxt = 0;
        f_nxt = 0;
    end

    endcase



end



//seq
always @(posedge clk or negedge rst_n) begin
if (!rst_n)
begin
    round <=5'b0;
    f_mid_r<=0;
    state<=0;
    f_in<=f_nxt;
end
else
begin
     round<=round_nxt;
     state<=state_nxt;
     f_mid_r<=f_mid_w;
    
end


    
end

endmodule













