module HMAC (
  clk, rst_n, start, key, message, mac_value, ready
);
    localparam BLOCK_SIZE = 136;
    localparam OPAD = 128'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
    localparam IPAD = 128'h36363636363636363636363636363636;
    localparam IDLE = 0;
    localparam HASH_S1 = 1;
    localparam HASH_S2 = 2;
    
    input [127:0] key;
    input [1087:0] message; 
    input clk, rst_n, start;
    output [255:0] mac_value;
    output ready;

    reg [1:0] state_r, state_w;
    reg hash_start_r, hash_start_w;
    reg ready_r, ready_w, more_r, more_w;
    reg [255:0] hash_out_r, hash_out_w;

    wire hash_ready, hash_next;
    wire [255:0] hash_out;

    wire [127:0] flip_res1, flip_res2;
    wire [255:0]  flip_out;
    wire [127:0] xor_in;
    wire [127:0] xor_res1, xor_res2;
    wire [1087:0] sha3_in;

    assign ready = ready_r;
    assign mac_value = hash_out_r;
    assign xor_in = (state_r==HASH_S1) ? IPAD : OPAD;
    assign xor_res1 = key ^ xor_in;
    assign sha3_in = (state_r==HASH_S1) ? (more_r) ? {flip_res1, {120{8'h6c}}} : message :  (more_r) ? {flip_res1, {120{8'h3a}}} : {hash_out_r, 3'b011, 828'd0, 1'b1};

    SHA3TOP sha3_256(
        .clk(clk),
        .rst_n(rst_n),
        .in(sha3_in),
        .more(more_r), // more=1 if there are still some inputs needed to be fed in
        .in_valid(hash_start_r),
        .out(hash_out),
        .hash_next(hash_next),   
        .out_valid(hash_ready)
    );

    ShiftBytes#(128) sb0(.in(xor_res1), .out(flip_res1));
    ShiftBytes#(256) sb2(.in(hash_out), .out(flip_out));


    always @(*) begin
        state_w = state_r;
        hash_start_w = hash_start_r;
        ready_w = ready_r;
        more_w = more_r;
        hash_out_w = hash_out_r;
        case (state_r)
            IDLE: begin
                ready_w = 0;
                if (start) begin
                    state_w = HASH_S1;
                    hash_start_w = 1;
                    more_w = 1;
                end
            end
            HASH_S1: begin
                if (hash_ready) begin
                    state_w = HASH_S2;
                    hash_start_w = 1;
                    more_w = 1;
                    hash_out_w = flip_out;
                end
                else if (hash_next) begin
                    hash_start_w = 1;
                    more_w = 0;
                end
                else hash_start_w = 0;
            end

            HASH_S2: begin
                hash_start_w = 0;
                if (hash_ready) begin
                    state_w = IDLE;
                    ready_w = 1;
                    hash_out_w = hash_out;
                end
                else if (hash_next) begin
                    hash_start_w = 1;
                    more_w = 0;
                end
                else hash_start_w = 0;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hash_start_r <= 0;
            ready_r <= 0;
            state_r <= IDLE;
            more_r <= 0;
            hash_out_r <= 0;
        end
        else begin
            hash_start_r <= hash_start_w;
            ready_r <= ready_w;
            state_r <= state_w;
            more_r <= more_w;
            hash_out_r <= hash_out_w;
        end
    end

endmodule