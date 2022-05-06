//module AESTOP(plain,key,cipher,clk,rst,start,finish,dec);
module AESTOP(  
    clk,
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
localparam S_LASTROUNDKEY = 1;
localparam S_COMPUTE = 2;
localparam S_NXTKEY = 3;
localparam S_FIN = 4;

// control
reg [3:0] counter_w,counter_r;
reg [2:0] state_w,state_r;

// data reg and wire
reg [127:0] temp_out_w,temp_out_r;

//module reg and wire
wire [127:0] oneround_in,oneround_out;
reg [127:0] roundkey_w,roundkey_r;
wire [127:0] xor_out;
reg nomix;
reg subbyteonly;
wire [31:0] sub_in,sub_out;
wire [3:0] rc_table_round;

reg key_inv;
wire [7:0] rc;
wire [127:0] key_nxt;

//call module

// KeySchedule key0(
//     .key(i_key), 
//     .roundkeys(roundkeys), 
//     .clk(clk), 
//     .rst_n(rst_n), 
//     .start(key_start), 
//     .finish(key_finish),
//     .sub_in(sub_in),
//     .sub_out(sub_out)
// );
KeySchedule key0(
    .key(roundkey_r), 
    .rc(rc), 
    .dec(key_inv),
    .out_key(key_nxt),
    .sub_in(sub_in),
    .sub_out(sub_out)
);
AESOneRound oneround(
    .in(oneround_in),
    .out(oneround_out),
    .roundkey(roundkey_r),
    .dec(mode),
    .nomix(nomix),
    .subbyteonly(subbyteonly),
    .sub_in(sub_in),
    .sub_out(sub_out)
);

AddRoundKey xor0( //to xor before start of enc / after end of dec
    .in(temp_out_r),
    .key(i_key),
    .out(xor_out)
);

rc_table rctable(
    .round(rc_table_round),
    .o_rc(rc)
);

//wire assignment
//assign xor_in = (mode)? oneround_out:i_in;
assign oneround_in = temp_out_r;
//assign key_start = (state_r == S_ROUNDKEY);
assign rc_table_round = (mode && !(state_r == S_LASTROUNDKEY))? (9-counter_r):counter_r;
//assign oneround_key = roundkeys[1279 -: 128];

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
            counter_w = 0;
            if(i_start) begin
                if(mode) begin
                    state_w = S_LASTROUNDKEY;
                end
                else
                    state_w = S_COMPUTE;
            end
        end 
        S_LASTROUNDKEY:begin
            counter_w = counter_r + 1;
            if(counter_r == 9)begin
                state_w = S_COMPUTE;
                counter_w = 0;
            end
        end
        S_COMPUTE:begin
            if(counter_r == 10)
                state_w = S_FIN;
            else
                state_w = S_NXTKEY;
        end
        S_NXTKEY:begin
            state_w = S_COMPUTE;
            counter_w = counter_r + 1;
        end
        S_FIN:begin
            state_w = S_IDLE;
        end
    endcase
end

always @(*) begin
    temp_out_w = temp_out_r;
    nomix = 0;
    subbyteonly = 0;
    key_inv = 0;
    roundkey_w = roundkey_r;
    case (state_r)
        S_IDLE:begin
            roundkey_w = i_key;
            temp_out_w = i_in;
        end
        S_LASTROUNDKEY:begin
            roundkey_w = key_nxt;
            subbyteonly = 1;
        end
        S_COMPUTE:begin
            temp_out_w = oneround_out;
            if ((counter_r == 10) && (mode))
                temp_out_w = xor_out;
            if (counter_r == 10 && (!(mode)))
                nomix = 1;
            if (counter_r == 0 && mode)
                nomix = 1;
            if (counter_r == 0 && !mode)begin
                temp_out_w = xor_out;
            end
            //round 1 key : roundkeys[1279 -: 128]
            //round 2 key : roundkeys[1279-128 -: 128]
            //round 3 key : roundkeys[1279-128*2 -: 128]
            //round n key : roundkeys[1279-128*(counter_r) -: 128]
        end
        S_NXTKEY:begin
            if(mode)
                key_inv = 1;
            subbyteonly = 1;
            roundkey_w = key_nxt;
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
        roundkey_r <= roundkey_w;
    end
end

endmodule