module Top (
    clk, rst_n, i_data, i_mode, i_start, o_data, o_valid
);

    input [7:0] i_data;
    input i_start, clk, rst_n;
    input [1:0] i_mode; // 0: aes encrypt, 1: aes decrypt, 2: sha3
    output [7:0] o_data;
    output o_valid;

    localparam IDLE = 0;
    localparam READ = 1;
    localparam AES = 2;
    localparam SHA = 3;
    localparam OUT = 4;
    localparam PAD = 5;

    reg [255:0] buf_r, buf_w;
    reg [2:0] state_r, state_w;
    reg [4:0] cnt_r, cnt_w;
    reg out_valid_r, out_valid_w;
    reg aes_start_r, aes_start_w;
    reg sha3_start_r, sha3_start_w;
    reg sha3_pad_r, sha3_pad_w;
    reg sha3_more_r, sha3_more_w;

    wire [127:0] aes_key;
    wire [127:0] aes_in;
    wire [127:0] aes_out;
    wire [1087:0] sha3_in;
    wire [255:0] sha3_out;
    wire sha3_ready, aes_ready, sha3_next;

    assign aes_key = buf_r[127:0];
    assign aes_in = buf_r[255:128];
    assign sha3_in = (sha3_pad_r) ? {buf_r[255:0], 831'd0, 1'b1} : {buf_r[255:0], 3'b011, 828'd0, 1'b1};

    assign o_data = buf_r[7:0];
    assign o_valid = out_valid_r;

    AESTOP aes_top(
        .clk(clk),
        .rst_n(rst_n),
        .mode(i_mode[0]),
        .i_start(aes_start_r),
        .i_key(aes_key),
        .i_in(aes_in),
        .o_cipher(aes_out),
        .o_ready(aes_ready)
    );

    SHA3TOP sha3_256(
        .clk(clk),
        .rst_n(rst_n),
        .in(sha3_in),
        .more(sha3_more_r),
        .in_valid(sha3_start_r),
        .out(sha3_out),
        .hash_next(sha3_next),
        .out_valid(sha3_ready)
    );

    always @(*) begin
        state_w = state_r;
        buf_w = buf_r;
        cnt_w = cnt_r;
        sha3_pad_w = sha3_pad_r;
        sha3_start_w = sha3_start_r;
        sha3_more_w = sha3_more_r;
        aes_start_w = aes_start_r;
        out_valid_w = out_valid_r;
        case (state_r)
            IDLE: begin
                if (i_start) begin
                    state_w = READ;
                    buf_w = i_mode[1] ? {buf_r[247:0], i_data[0], i_data[1], i_data[2], i_data[3], i_data[4], i_data[5], i_data[6], i_data[7]} : {buf_r[247:0], i_data};
                    cnt_w = 1;
                end
            end

            READ: begin
                cnt_w = cnt_r + 1;
                if (i_start) begin
                    buf_w = i_mode[1] ? {buf_r[247:0], i_data[0], i_data[1], i_data[2], i_data[3], i_data[4], i_data[5], i_data[6], i_data[7]} : {buf_r[247:0], i_data};
                    if (cnt_r==5'd31) begin
                        if (i_mode[1]) begin
                            state_w = SHA;
                            sha3_start_w = 1;
                        end
                        else begin
                            state_w = AES;
                            aes_start_w = 1;
                        end
                    end
                end
                else begin
                    sha3_pad_w = 1;
                    buf_w = i_mode[1] ? {buf_r[247:0], 3'b011, 5'd0} :{buf_r[247:0], 8'd0};
                    if (cnt_r==5'd31) begin
                        if (i_mode[1]) begin
                            state_w = SHA;
                            sha3_start_w = 1;
                        end
                        else begin
                            state_w = AES;
                            aes_start_w = 1;
                        end
                    end
                    else begin
                        state_w = PAD;
                    end
                end
            end
            PAD: begin
                cnt_w = cnt_r + 1;
                buf_w = {buf_r[247:0], 8'd0};
                if (cnt_r==5'd31) begin
                    if (i_mode[1]) begin
                        state_w = SHA;
                        sha3_start_w = 1;
                    end
                    else begin
                        state_w = AES;
                        aes_start_w = 1;
                    end
                end
            end
            AES: begin
                if (aes_ready) begin
                    buf_w[127:0] = aes_out;
                    state_w = OUT;
                    cnt_w = 16;
                    out_valid_w = 1;
                end
            end

            SHA: begin
                if (sha3_ready) begin
                    buf_w = sha3_out;
                    state_w = OUT;
                    cnt_w = 0;
                    out_valid_w = 1;
                end
            end

            OUT: begin
                if (cnt_r==5'd31) begin
                    state_w = IDLE;
                    out_valid_w = 0;
                    cnt_w = 0;
                end
                else begin
                    buf_w = {buf_r[7:0], buf_r[255:8]};
                    cnt_w = cnt_r + 1;
                end
            end
            default: begin
                state_w = state_r;
                buf_w = buf_r;
                cnt_w = cnt_r;
                sha3_pad_w = sha3_pad_r;
                sha3_start_w = sha3_start_r;
                sha3_more_w = sha3_more_r;
                aes_start_w = aes_start_r;
                out_valid_w = out_valid_r;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_r <= IDLE;
            buf_r <= 0;
            cnt_r <= 0;
            sha3_pad_r <= 0;
            sha3_start_r <= 0;
            sha3_more_r <= 0;
            aes_start_r <= 0;
            out_valid_r <= 0;
        end
        else begin
            state_r <= state_w;
            buf_r <= buf_w;
            cnt_r <= cnt_w;
            sha3_pad_r <= sha3_pad_w;
            sha3_start_r <= sha3_start_w;
            sha3_more_r <= sha3_more_w;
            aes_start_r <= aes_start_w;
            out_valid_r <= out_valid_w;
        end
    end




  
endmodule