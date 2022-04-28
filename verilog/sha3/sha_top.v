module SHA3TOP(
           clk, in ,more,in_valid,hash_next, out, out_valid ,rst_n
       );



// Definition of states
parameter IDLE = 3'b000;
parameter computing  = 3'b001;
parameter second_idle  = 3'b010;
parameter OUT  = 3'b011;

input [1087:0] in;
input clk;
input more;
input rst_n;
input in_valid;
output hash_next;
output reg [255:0] out;
output out_valid;
wire [255:0] out_rev;
reg [4:0] round_nxt;
reg [4:0] round;



reg  [2:0] state,state_nxt;

wire [1599:0] f_out;
reg [1599:0] f_in,f_nxt;

assign hash_next = ((state==second_idle)&&(!in_valid))? 1'b1:1'b0 ;
assign out_valid = ((state==OUT))? 1'b1:1'b0 ;

assign out_rev =((state==OUT))?f_out[1599:1344]:256'b0;

integer i,j;


always @(*) begin
    for (i=0; i<=248; i=i+8) begin
        for(j=0;j<8;j=j+1) begin
            out[i+j]=out_rev[i+7-j];

        end
        
    end
end



Ffunction funcs(f_in,f_out,round);






always @(*)
begin
    case(state)
        IDLE:
        begin
            round_nxt=0;
            if (in_valid)
            begin
                state_nxt=computing;
                f_nxt[1599:512]=in;
                f_nxt[511:0]=512'b0;
            end
            else
            begin
                state_nxt=IDLE;
                f_nxt=0;
            end
        end

        computing:
        begin
            round_nxt=round+1;
            f_nxt=f_out;
            if((round ==22) && (more) )
            begin

                state_nxt=second_idle;
            end
            else if (round==22)
            begin
                state_nxt=OUT;

            end
            else
            begin
                state_nxt=computing;
            end

        end
        second_idle:
        begin
            if (in_valid) begin
                f_nxt[1599:512]=f_out[1599:512] ^ in;
                f_nxt[511:0]=f_out[511:0];
                round_nxt=0;
                state_nxt=computing;




            end
            else begin
                f_nxt=f_in;
                round_nxt=0;
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

        end

    endcase
end



always @(posedge clk or negedge rst_n )
begin
    if (!rst_n)
    begin
        round <=5'b0;
        f_in<=0;
        state<=0;
    end

    else
    begin
        f_in<=f_nxt;
        state<=state_nxt;
        round<=round_nxt;



    end




end

endmodule
