module HMAC (
  clk, rst_n, start, key, message, mac_value, ready
);
    localparam BLOCK_SIZE = 136;
    localparam IPAD = 1088'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
    localparam OPAD = 1088'h36363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636;
    localparam IDLE = 0;
    localparam HASH_S1 = 1;
    localparam HASH_S2 = 2;
    
    input [1087:0] key;
    input [1087:0] message; 
    input clk, rst_n, start;
    output [255:0] mac_value;
    output ready;

    reg [1087:0] k_r, k_w;
    reg [1:0] state_r, state_w;
    reg hash_start_r, hash_start_w;
    reg ready_r, ready_w, more_r, more_w;
    reg [255:0] hash_out_r, hash_out_w;

    wire hash_ready, hash_next;
    wire [255:0] hash_out;

    assign ready = ready_r;
    assign mac_value = hash_out;

    SHA3 sha3_256(
        .in(k_r),
        .more(more_r), // more=1 if there are still some inputs needed to be fed in
        .input_valid(hash_start_r),
        .out(hash_out),
        .next(hash_next),   
        .ready(hash_ready)
    );

    always @(*) begin
        k_w = k_r;
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
                    k_w = key ^ IPAD;
                    hash_start_w = 1;
                    more_w = 1;
                end
            end
            HASH_S1: begin
                if (hash_ready) begin
                    state_w = HASH_S2;
                    k_w = key ^ OPAD;
                    hash_start_w = 1;
                    more_w = 1;
                    hash_out_w = hash_out;
                end
                else if (hash_next) begin
                    k_w = message;
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
                    k_w = {hash_out, 3'b011, 828'd0, 1'b1};
                    hash_start_w = 1;
                    more_w = 0;
                end
                else hash_start_w = 0;
            end
            default: begin
                hash_start_w = 0;
                ready_w = 0;
                k_w = 0;
                state_w = IDLE;
                hash_out_w = 0;
                more_w = 0;
            end
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            hash_start_r <= 0;
            ready_r <= 0;
            k_r <= 0;
            state_r <= IDLE;
            more_r <= 0;
            hash_out_r <= 0;
        end
        else begin
            hash_start_r <= hash_start_w;
            ready_r <= ready_w;
            k_r <= k_w;
            state_r <= state_w;
            more_r <= more_w;
            hash_out_r <= hash_out_w;
        end
    end

endmodule