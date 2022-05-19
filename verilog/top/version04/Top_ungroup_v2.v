module Top (
  clk, rst_n, i_data, i_mode, i_start, o_data, o_valid, o_ien
);
    input [7:0] i_data;
    input i_start, clk, rst_n, i_mode;
    output [7:0] o_data;
    output o_valid, o_ien;
    localparam IDLE = 0;
    localparam READ_SALT_KEY = 1;
    localparam PAD = 2;
    localparam PBKDF2 = 3;
    localparam READ_MSG = 4;
    localparam AES = 5;
    localparam HMAC = 6;
    localparam OUT_S2 = 7;
    localparam HASH_S1 = 8;
    localparam HASH_S2 = 9;
    localparam OUT_S1 = 12;

    localparam OPAD = 128'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
    localparam IPAD = 128'h36363636363636363636363636363636;

    localparam ITER_TIMES = 16;

    reg [255:0] in_buf_r, in_buf_w;
    reg [255:0] out_buf_r, out_buf_w;

    reg [127:0] hmac_key_r, hmac_key_w;
    reg [3:0] state_r, state_w;
    reg [4:0] counter_r, counter_w;
    reg input_enable_r, input_enable_w;
    reg output_valid_r, output_valid_w;
    reg hmac_flag_r, hmac_flag_w;
    reg aes_start_r, aes_start_w;

    reg [4:0] sha3_round_r, sha3_round_w;
    reg [1599:0] sha3_buf_r, sha3_buf_w;
    reg sha3_more_r, sha3_more_w;
    wire [1599:0] sha3_fout;

    wire [127:0] hmac_flip_out;
    wire [255:0] sha3_flip_out;
    wire [127:0] hmac_xor_in;
    wire [127:0] hmac_xor_out;

    wire [127:0] salt, salt_rev;
    wire [127:0] hmac_key;
    wire [1087:0] hmac_msg;

    wire [127:0] cipher, cipher_rev, aes_msg;
    wire [127:0] aes_key;
    wire aes_ready;
    wire [255:0] mac_value, keys;
    wire [1087:0] pbkdf2_hmac_msg;
    wire [255:0] in_buf_rev;

    assign salt = in_buf_r[255:128];
    assign hmac_key = hmac_key_r;
    assign hmac_msg = (hmac_flag_r==0) ? pbkdf2_hmac_msg : {cipher_rev, 3'b011, 956'd0, 1'b1};
    assign pbkdf2_hmac_msg = (counter_r==0) ? {salt_rev, 32'h0000_0080, 3'b011, 924'd0, 1'b1} : {in_buf_r, 3'b011, 828'd0, 1'b1};
    assign aes_msg = in_buf_r[127:0];
    assign aes_key = out_buf_r[127:0];
    assign hmac_xor_in = (state_r==AES || state_r==PBKDF2) ? IPAD : OPAD;
    assign hmac_xor_out = hmac_key ^ hmac_xor_in;

    assign o_valid = output_valid_r;
    assign o_ien = input_enable_r;
    assign o_data = out_buf_r[7:0];

    ShiftBytes#(128) sb3(.in(salt), .out(salt_rev));
    ShiftBytes#(256) sb4(.in(in_buf_r), .out(in_buf_rev));
    ShiftBytes#(128) sb0(.in(out_buf_r[127:0]), .out(cipher_rev));
    ShiftBytes#(128) sb1(.in(hmac_xor_out), .out(hmac_flip_out));
    ShiftBytes#(256) sb2(.in(sha3_fout[1599:1344]), .out(sha3_flip_out));
    Ffunction f0(.in(sha3_buf_r), .out(sha3_fout), .round(sha3_round_r));
    
    AESTOP aes_top(
        .clk(clk),
        .rst_n(rst_n),
        .mode(i_mode),
        .i_start(aes_start_r),
        .i_key(aes_key),
        .i_in(aes_msg),
        .o_cipher(cipher),
        .o_ready(aes_ready)
    );

    always @(*) begin
        in_buf_w       = in_buf_r;
        out_buf_w      = out_buf_r;
        hmac_key_w     = hmac_key_r;
        state_w        = state_r;
        counter_w      = counter_r;
        input_enable_w = input_enable_r;
        output_valid_w = output_valid_r;
        aes_start_w    = aes_start_r;
        sha3_buf_w = sha3_buf_r;
        sha3_round_w = sha3_round_r;
        sha3_more_w = sha3_more_r;
        hmac_flag_w = hmac_flag_r;
        case (state_r)
            IDLE: begin
                if (i_start) begin
                    state_w = READ_SALT_KEY;
                    in_buf_w = {in_buf_r[247:0], i_data};
                    counter_w = 1;
                end
            end
            READ_SALT_KEY: begin
                counter_w = counter_r + 1;
                if (i_start) begin
                    in_buf_w = {in_buf_r[247:0], i_data};
                    if (counter_r==5'd31) begin
                        state_w = PBKDF2;
                        input_enable_w = 1;
                        hmac_key_w = {in_buf_r[119:0], i_data};
                        counter_w = 0;
                    end
                end
                else begin
                    input_enable_w = 1;
                    in_buf_w = {in_buf_r[247:0], 8'd0};
                    if (counter_r==5'd31) begin
                        state_w = PBKDF2;
                        hmac_key_w = {in_buf_r[119:0], 8'd0};
                        counter_w = 0;
                    end
                end
            end
            HASH_S1: begin
                if (sha3_round_r==23 && sha3_more_r) begin
                    sha3_round_w = 0;
                    sha3_buf_w[1599:512] = sha3_fout[1599:512] ^ hmac_msg;
                    sha3_buf_w[511:0] = sha3_fout[511:0];
                    sha3_more_w = 0;
                end
                else if (sha3_round_r==23) begin
                    sha3_round_w = 0;
                    sha3_more_w = 1;
                    in_buf_w = sha3_fout[1599:1344];
                    sha3_buf_w = {hmac_flip_out, {120{8'h3a}}, 512'd0};
                    state_w = HASH_S2;
                end
                else begin
                    sha3_round_w = sha3_round_r + 1;
                    sha3_buf_w = sha3_fout;
                end
            end

            HASH_S2: begin
                if (sha3_round_r==23 && sha3_more_r) begin
                    sha3_round_w = 0;
                    sha3_buf_w[1599:512] = sha3_fout[1599:512] ^ {in_buf_r, 3'b011, 828'd0, 1'b1};
                    sha3_buf_w[511:0] = sha3_fout[511:0];
                    sha3_more_w = 0;
                end
                else if (sha3_round_r==23) begin
                    sha3_round_w = 0;
                    in_buf_w = sha3_fout[1599:1344];
                    if (hmac_flag_r) begin
                        state_w = OUT_S1;
                        counter_w = 0;
                        output_valid_w = 1;
                    end
                    else begin
                        state_w = PBKDF2;
                        counter_w = counter_r + 1;
                        output_valid_w = 0;
                    end
                end
                else begin
                    sha3_round_w = sha3_round_r + 1;
                    sha3_buf_w = sha3_fout;
                end
            end

            
            PBKDF2: begin
                hmac_flag_w = 0;
                sha3_buf_w = {hmac_flip_out, {120{8'h6c}}, 512'd0};
                sha3_more_w = 1;
                sha3_round_w = 0;
                state_w = HASH_S1;
                if (counter_r!=0) begin
                    out_buf_w = out_buf_r ^ in_buf_rev;
                end

                if (counter_r==ITER_TIMES) begin
                    state_w = READ_MSG;
                    input_enable_w = 0;
                    counter_w = 0;
                    sha3_more_w = 0;
                    sha3_round_w = 0;
                end

            end
            READ_MSG: begin
                hmac_key_w = out_buf_r[255:128];
                if (i_start) begin
                    counter_w = counter_r + 1;
                    in_buf_w = {in_buf_r[247:0], i_data};
                    if (counter_r==5'd15) begin
                        state_w = AES;
                        input_enable_w = 1;
                        aes_start_w = 1;
                    end
                end
            end

            AES: begin
                aes_start_w = 0;
                if (aes_ready) begin
                    out_buf_w = {128'd0, cipher};
                    state_w = HASH_S1;
                    counter_w = 0;
                    output_valid_w = 0;
                    sha3_buf_w = {hmac_flip_out, {120{8'h6c}}, 512'd0};
                    sha3_more_w = 1;
                    sha3_round_w = 0;
                    hmac_flag_w = 1;
                end
            end

            OUT_S1: begin
                counter_w = counter_r + 1;
                if (counter_r==5'd15) begin
                    state_w = HMAC;
                    output_valid_w = 0;
                end
                else out_buf_w = {out_buf_r[7:0], out_buf_r[255:8]};
            end

            HMAC: begin
                counter_w = 0;
                out_buf_w = in_buf_rev;
                state_w = OUT_S2;
                output_valid_w = 1;
            end

            OUT_S2: begin
                counter_w = counter_r + 1;
                out_buf_w = {out_buf_r[7:0], out_buf_r[255:8]};
                if (counter_r==31) begin
                    state_w = IDLE;
                    output_valid_w = 0;
                    counter_w = 0;
                    input_enable_w = 0;
                end
            end
        endcase
    end


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_buf_r       <= 0;
            out_buf_r      <= 0;
            hmac_key_r     <= 0;
            state_r        <= IDLE;
            counter_r      <= 0;
            input_enable_r <= 0;
            output_valid_r <= 0;
            aes_start_r    <= 0;
            sha3_more_r <= 0;
            sha3_round_r <= 0;
            sha3_buf_r <= 0;
            hmac_flag_r <= 0;
        end
        else begin
            in_buf_r       <= in_buf_w;
            out_buf_r      <= out_buf_w;
            hmac_key_r     <= hmac_key_w;
            state_r        <= state_w;
            counter_r      <= counter_w;
            input_enable_r <= input_enable_w;
            output_valid_r <= output_valid_w;
            aes_start_r    <= aes_start_w;
            sha3_more_r <= sha3_more_w;
            sha3_round_r <= sha3_round_w;
            sha3_buf_r <= sha3_buf_w;
            hmac_flag_r <= hmac_flag_w;
        end
    end




  
endmodule