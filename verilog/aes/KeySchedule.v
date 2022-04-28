module KeySchedule (
    key, roundkeys, clk, rst_n, start, finish,shift_l,shift_r
);
input [127:0] key;
output [1279:0] roundkeys;
input clk,rst_n;
input start;
input shift_l,shift_r;
output finish;

//state param
localparam S_IDLE = 0;
localparam S_COMP = 1;
localparam S_FIN = 2;

//control
reg [1:0] state_w,state_r;
reg [3:0] counter_w,counter_r;

//data
reg [1279:0] roundkeys_w,roundkeys_r;
reg [7:0] rc_w,rc_r;
wire [7:0] rcx2;
wire [127:0] gen_out;

//call module
GenRoundKey gen0(.in(roundkeys_r[127:0]),.out(gen_out),.rc(rc_r));
Xtime X0(.in(rc_r),.out(rcx2));

//output assignment
assign finish = (state_r == S_FIN);
assign roundkeys = roundkeys_r;

//comb
//next state logic 
always @(*) begin
    counter_w = counter_r;
    state_w = state_r;
    case (state_r)
        S_IDLE:begin
            if (start) begin
                state_w = S_COMP;
            end
        end 
        S_COMP:begin
            counter_w = counter_r + 1;
            if(counter_r == 9)begin
                state_w = S_FIN;
                counter_w = 0;
            end
        end
        S_FIN:begin
            // if(start)
            //     state_w = S_COMP;
            state_w = S_IDLE;
        end
    endcase
end
// data
always @(*) begin
    roundkeys_w = roundkeys_r;
    rc_w = rc_r;
    case (state_r)
        S_IDLE:begin
            if(start)
                roundkeys_w[127:0] = key;
            rc_w = 1;
        end
        S_COMP:begin
            roundkeys_w = {roundkeys_r[1151:0],gen_out};
            rc_w = rcx2;
        end
    endcase
end

//seq
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        state_r <= S_IDLE;
        counter_r <= 0;
        rc_r <= 1;
    end
    else begin
        state_r <= state_w;
        counter_r <= counter_w;
        rc_r <= rc_w;
        if (shift_l)
            roundkeys_r <= {roundkeys_w[1151:0],roundkeys_w[1279:1152]};
        else if (shift_r)
            roundkeys_r <= {roundkeys_w[127:0],roundkeys_w[1279:128]};
        else 
            roundkeys_r <= roundkeys_w;
    end
end

endmodule

module GenRoundKey (
    in,out,rc
);
input [127:0] in;
output [127:0] out;
input [7:0] rc;
    
wire [31:0] w0;
wire [31:0] w1;
wire [31:0] w2;
wire [31:0] w3;
assign {w0,w1,w2,w3} = in;

wire [31:0] w_out [0:3];
wire [31:0] g_out;

GFunction g0(.in(w3),.out(g_out),.rc(rc));

assign w_out[0] = w0 ^ g_out;
assign w_out[1] = w_out[0] ^ w1;
assign w_out[2] = w_out[1] ^ w2;
assign w_out[3] = w_out[2] ^ w3;

assign out = {w_out[0], w_out[1], w_out[2], w_out[3]};


endmodule

module GFunction(in,out,rc);

input [31:0] in;
input [7:0] rc;
output [31:0] out;

wire [7:0] V [0:3];
wire [7:0] V_o [0:3];
wire [7:0] V_o_temp;

assign {V[0],V[1],V[2],V[3]} = in;
assign out = {V_o[0],V_o[1],V_o[2],V_o[3]};

STable s0(.in(V[0]),.out(V_o[3]));
STable s1(.in(V[1]),.out(V_o_temp));
STable s2(.in(V[2]),.out(V_o[1]));
STable s3(.in(V[3]),.out(V_o[2]));

assign V_o[0] = V_o_temp ^ rc;

endmodule
