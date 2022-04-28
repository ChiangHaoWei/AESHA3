//module AESTOP(plain,key,cipher,clk,rst,start,finish,dec);
module AESTOP(  clk,
                rst_n,
                mode, //mode = 1 --> decode?
                i_start,
                i_key,
                i_in,
                o_cipher,
                o_ready);
input clk,rst_n;
input i_start,mode;
input [127:0] i_key,i_in;
output [127:0] o_cipher;
output o_ready;

//state parameter
localparam S_IDLE = 0;
localparam S_ROUNDKEY = 1;
localparam S_COMPUTE = 2;
localparam S_FIN = 3;

// control
reg [3:0] counter_w,counter_r;
reg [1:0] state_w,state_r;

// data reg and wire
reg [127:0] temp_out_w,temp_out_r;

//module reg and wire
wire key_start;
wire key_finish;
reg key_shl,key_shr;
wire [1279:0] roundkeys;
wire [127:0] oneround_in,oneround_out;
wire [127:0] oneround_key;
wire [127:0] xor_in,xor_out;
reg nomix;

//call module
KeySchedule key0(
    .key(i_key), 
    .roundkeys(roundkeys), 
    .clk(clk), 
    .rst_n(rst_n), 
    .start(key_start), 
    .finish(key_finish),
    .shift_l(key_shl),
    .shift_r(key_shr)
);
AESOneRound oneround(
    .in(oneround_in),
    .out(oneround_out),
    .roundkey(oneround_key),
    .dec(mode),
    .nomix(nomix)
);

AddRoundKey xor0( //to xor before start of enc / after end of dec
    .in(xor_in),
    .key(i_key),
    .out(xor_out)
);

//wire assignment
assign xor_in = (mode)? oneround_out:i_in;
assign oneround_in = temp_out_r;
assign key_start = (state_r == S_ROUNDKEY);
assign oneround_key = roundkeys[1279 -: 128];

//output assignment
assign o_cipher = temp_out_r;
assign o_ready = (state_r == S_FIN);

//comb
//next state logic
always @(*) begin
    state_w = state_r;
    counter_w = counter_r;
    case (state_r)
        S_IDLE:begin
            if(i_start) 
                state_w = S_ROUNDKEY;
        end 
        S_ROUNDKEY:begin
            if(key_finish)begin
                state_w = S_COMPUTE;
            end
        end
        S_COMPUTE:begin
            counter_w = counter_r + 1;
            if(counter_r == 9)begin
                state_w = S_FIN;
                counter_w = 0;
            end
        end
        S_FIN:begin
            state_w = S_IDLE;
        end
    endcase
end

always @(*) begin
    key_shl = 0;
    key_shr = 0;
    temp_out_w = temp_out_r;
    nomix = 0;
    case (state_r)
        S_IDLE:begin
            if(mode)
                temp_out_w = i_in;
            else 
                temp_out_w = xor_out;
        end
        S_ROUNDKEY:begin
            if(key_finish && mode)begin
                key_shr = 1;//let roundkeys[1279 -: 128] be 10th round
            end
        end
        S_COMPUTE:begin
            temp_out_w = oneround_out;
            if ((counter_r == 9) && (mode))
                temp_out_w = xor_out;
            if (counter_r == 9 && (!(mode)))
                nomix = 1;
            if (counter_r == 0 && mode)
                nomix = 1;
            if (mode)
                key_shr = 1;
            else
                key_shl = 1;
        end
    endcase
end

//seq
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        counter_r <= 0;
        state_r <= S_IDLE;
    end
    else begin
        counter_r <= counter_w;
        state_r <= state_w;
        temp_out_r <= temp_out_w;
    end
end

endmodule