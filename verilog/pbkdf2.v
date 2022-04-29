module PBKDF2 (
  clk, rst_n, i_start, i_pw, i_salt, o_key, o_ready
);
    input clk, rst_n, i_start;
    input [1087:0] i_pw;  // input passward 1088 bit -> maximum password size 136 bytes
    input [127:0] i_salt; // input salt     128 bit
    output [255:0] o_key; // output key     256 bit
    output o_ready;       // ready

    localparam IDLE = 0;
    localparam HASH = 1;
    localparam ITER_TIMES = 15; // maximum 15

    reg state_r, state_w;
    reg [3:0] counter_r, counter_w;
    reg ready_r, ready_w, hmac_start_r, hmac_start_w;
    reg [1087:0] hmac_msg_r, hmac_msg_w;
    reg [255:0] key_r, key_w;

    wire [255:0] hmac_out;
    wire hmac_ready;
    wire [127:0] salt_rev;
    wire [255:0] hmac_out_rev;

    assign o_ready = ready_r;
    assign o_key = key_r;

    HMAC hmac(
        .clk(clk),
        .rst_n(rst_n),
        .start(hmac_start_r),
        .key(i_pw),
        .message(hmac_msg_r),
        .mac_value(hmac_out),
        .ready(hmac_ready)
    );

    ShiftBytes#(128) sb1(.in(i_salt), .out(salt_rev));
    ShiftBytes#(256) sb2(.in(hmac_out), .out(hmac_out_rev));

    always @(*) begin
        state_w = state_r;
        counter_w = counter_r;
        ready_w = ready_r;
        hmac_start_w = hmac_start_r;
        hmac_msg_w = hmac_msg_r;
        key_w = key_r;
        case (state_r)
            IDLE: begin
                if (i_start) begin
                    state_w = HASH;
                    hmac_msg_w = {salt_rev, 32'h0000_0080, 3'b011, 924'd0, 1'b1};
                    hmac_start_w = 1;
                end
                ready_w = 0;
            end
            HASH: begin
                if (hmac_ready) begin
                    key_w = key_r ^ hmac_out;
                    if (counter_r == 0) begin
                        state_w = IDLE;
                        ready_w = 1;
                        counter_w = ITER_TIMES;
                    end
                    else begin
                        counter_w = counter_r - 1;
                        hmac_start_w = 1;
                        hmac_msg_w = {hmac_out_rev, 3'b011, 828'd0, 1'b1};
                    end
                end
                else hmac_start_w = 0;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r <= IDLE;
            counter_r <= ITER_TIMES;
            ready_r <= 0;
            hmac_start_r <= 0;
            hmac_msg_r <= 0;
            key_r <= 0;
        end
        else begin
            state_r <= state_w;
            counter_r <= counter_w;
            ready_r <= ready_w;
            hmac_start_r <= hmac_start_w;
            hmac_msg_r <= hmac_msg_w;
            key_r <= key_w;
        end
    end

endmodule