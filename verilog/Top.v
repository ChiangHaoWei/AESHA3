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
    localparam GET_KEY = 3;
    localparam READ_MSG = 4;
    localparam AES = 5;
    localparam CAL_MAC = 6;
    localparam OUT = 7;

    reg [255:0] in_buf_r, in_buf_w;
    reg [255:0] out_buf_r, out_buf_w;

    reg [127:0] aes_key_r, aes_key_w;
    reg [127:0] hmac_key_r, hmac_key_w;
    reg [127:0] cipher_r, cipher_w;
    reg [1:0] state_r, state_w;
    reg [4:0] counter_r, counter_w;
    reg input_enable_r, input_enable_w;
    reg output_valid_r, output_valid_w;

    reg pbk_start_r, pbk_start_w;
    reg hmac_start_r, hmac_start_w;
    reg aes_start_r, aes_start_w;

    wire [127:0] passward, salt;
    wire [1087:0] hmac_key, hmac_msg;

    wire [127:0] cipher, cipher_rev, aes_msg;
    wire pbk_ready, hmac_ready, aes_ready;
    wire [255:0] mac_value, keys;

    assign salt = in_buf_r[127:0];
    assign passward = {in_buf_r[255:128], 960'd0};
    assign hmac_key = {hmac_key_r, 960'd0};
    assign hmac_msg = {cipher_rev, 1'b0, 958'd0, 1'b1};
    assign aes_msg = in_buf_r[127:0];

    assign o_valid = output_valid_r;
    assign o_ien = input_enable_r;
    assign o_data = out_buf_r[7:0];

    ShiftBytes#(256) sb(.in(cipher_r), .out(cipher_rev));
    

    PBKDF2 pbkdf2(
        .clk(clk),
        .rst_n(rst_n),
        .i_start(pbk_start_r),
        .i_pw(passward),
        .i_salt(salt),
        .o_key(keys),
        .o_ready(pbk_ready)
    );

    HMAC hmac(
        .clk(clk),
        .rst_n(rst_n),
        .start(hmac_start_r),
        .key(hmac_key),
        .message(hmac_msg),
        .mac_value(mac_value),
        .ready(hmac_ready)
    );

    AESTOP aes_top(
        .clk(clk),
        .rst_n(rst_n),
        .mode(i_mode),
        .i_start(aes_start_r),
        .i_key(aes_key_r),
        .i_in(aes_msg),
        .o_cipher(cipher),
        .o_ready(aes_ready)
    );

    always @(*) begin
        in_buf_w       = in_buf_r;
        out_buf_w      = out_buf_r;
        aes_key_w      = aes_key_r;
        hmac_key_w     = hmac_key_r;
        cipher_w       = cipher_r;
        state_w        = state_r;
        counter_w      = counter_r;
        input_enable_w = input_enable_r;
        output_valid_w = output_valid_r;
        pbk_start_w    = pbk_start_r;
        hmac_start_w   = hmac_start_r;
        aes_start_w    = aes_start_r;
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
                        state_w = GET_KEY;
                        pbk_start_w = 1;
                        input_enable_w = 1;
                    end
                end
                else begin
                    input_enable_w = 1;
                    in_buf_w = {in_buf_r[247:0], 8'd0};
                    if (counter_r==5'd31) begin
                        state_w = GET_KEY;
                        pbk_start_w = 1;
                    end
                end
            end
            // PAD: begin
            //     counter_w = counter_r + 1;
            //     in_buf_w = {in_buf_r[247:0], 8'd0};
            //     if (counter_r==5'd31) begin
            //         state_w = GET_KEY;
            //         pbk_start_w = 1;
            //     end
            // end
            GET_KEY: begin
                pbk_start_w = 0;
                if (pbk_ready) begin
                    aes_key_w = keys[127:0];
                    hmac_key_w = keys[255:128];
                    state_w = READ_MSG;
                    input_enable_w = 0;
                    counter_w = 0;
                end
            end
            READ_MSG: begin
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
                    cipher_w = cipher;
                    out_buf_w = {128'd0, cipher};
                    state_w = CAL_MAC;
                    hmac_start_w = 1;
                    counter_w = 0;
                    output_valid_w = 1;
                end
            end

            CAL_MAC: begin // assert calculating hmac value needs more than 16 cycles
                hmac_start_w = 0;
                if (counter_r != 5'd16) begin
                    counter_w = counter_r + 1;
                    if (counter_r==5'd15) begin
                        output_valid_w = 0;
                    end
                    else out_buf_w = {out_buf_r[7:0], out_buf_r[255:8]};
                end
                
                if (hmac_ready) begin
                    state_w = OUT;
                    out_buf_w = mac_value;
                    counter_w = 0;
                    output_valid_w = 1;
                end
            end

            OUT: begin
                if (counter_r==5'd15) begin
                    state_w = IDLE;
                    output_valid_w = 0;
                    counter_w = 0;
                    input_enable_w = 0;
                end
                else begin
                    out_buf_w = {out_buf_r[7:0], out_buf_r[255:8]};
                    counter_w = counter_r + 1;
                end
            end
        endcase
    end


    always @(posedge clk) begin
        if (!rst_n) begin
            in_buf_r       <= 0;
            out_buf_r      <= 0;
            aes_key_r      <= 0;
            hmac_key_r     <= 0;
            cipher_r       <= 0;
            state_r        <= IDLE;
            counter_r      <= 0;
            input_enable_r <= 0;
            output_valid_r <= 0;
            pbk_start_r    <= 0;
            hmac_start_r   <= 0;
            aes_start_r    <= 0;
        end
        else begin
            in_buf_r       <= in_buf_w;
            out_buf_r      <= out_buf_w;
            aes_key_r      <= aes_key_w;
            hmac_key_r     <= hmac_key_w;
            cipher_r       <= cipher_w;
            state_r        <= state_w;
            counter_r      <= counter_w;
            input_enable_r <= input_enable_w;
            output_valid_r <= output_valid_w;
            pbk_start_r    <= pbk_start_w;
            hmac_start_r   <= hmac_start_w;
            aes_start_r    <= aes_start_w;
        end
    end




  
endmodule