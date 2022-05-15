module HMAC (
  clk, rst_n, start, key, message, mac_value, ready
);
    localparam BLOCK_SIZE = 136;
    localparam OPAD = 1088'h5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c;
    localparam IPAD = 1088'h36363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636;
    localparam IDLE = 0;
    localparam HASH_S1 = 1;
    localparam HASH_S2 = 2;
    localparam XOR_S1 = 3;
    localparam XOR_S2 = 4;
    
    input [1087:0] key;
    input [1087:0] message; 
    input clk, rst_n, start;
    output [255:0] mac_value;
    output ready;

    reg [1087:0] k_r, k_w;
    reg [2:0] state_r, state_w;
    reg hash_start_r, hash_start_w;
    reg ready_r, ready_w, more_r, more_w;
    reg [255:0] hash_out_r, hash_out_w;

    wire hash_ready, hash_next;
    wire [255:0] hash_out;

    reg [271:0] xor_in_a, xor_in_b;
    wire [271:0] flip_res;
    wire [255:0] flip_out;
    wire [271:0] xor_res;

    reg [1:0] cnt_r, cnt_w;

    assign ready = ready_r;
    assign mac_value = hash_out_r;
    assign xor_res = xor_in_b ^ xor_in_a;

    integer i, j;

    SHA3TOP sha3_256(
        .clk(clk),
        .rst_n(rst_n),
        .in(k_r),
        .more(more_r), // more=1 if there are still some inputs needed to be fed in
        .in_valid(hash_start_r),
        .out(hash_out),
        .hash_next(hash_next),   
        .out_valid(hash_ready)
    );

    ShiftBytes#(272) sb0(.in(xor_res), .out(flip_res));
    ShiftBytes#(256) sb1(.in(hash_out), .out(flip_out));

    // always @(*) begin
    //     for (i=31; i>=0; i=i-1) begin
    //         for (j=0; j<8; j=j+1) begin
    //             flip_out[i*8+7-j] = hash_out[i*8+j];
    //         end
    //     end
    // end

    always @(*) begin
        k_w = k_r;
        state_w = state_r;
        hash_start_w = hash_start_r;
        ready_w = ready_r;
        more_w = more_r;
        hash_out_w = hash_out_r;
        cnt_w = cnt_r;
        xor_in_a = IPAD;
        xor_in_b = IPAD;
        case (state_r)
            IDLE: begin
                ready_w = 0;
                if (start) begin
                    state_w = XOR_S1;
                    xor_in_a = IPAD[271:0];
                    xor_in_b = key[271:0];
                    k_w[271:0] = flip_res;
                    cnt_w = 1;
                end
            end
            XOR_S1: begin
                if (cnt_r == 2'd3) begin
                    state_w = HASH_S1;
                    hash_start_w = 1;
                    more_w = 1;
                end
                cnt_w = cnt_r + 1;
                case (cnt_r)
                    2'd1: begin
                        xor_in_a = IPAD[543:272];
                        xor_in_b = key[543:272];
                        k_w[543:272] = flip_res;
                    end
                    2'd2: begin
                        xor_in_a = IPAD[815:544];
                        xor_in_b = key[815:544];
                        k_w[815:544] = flip_res;
                    end
                    2'd3: begin
                        xor_in_a = IPAD[1087:816];
                        xor_in_b = key[1087:816];
                        k_w[1087:816] = flip_res;
                    end
                    default: begin
                        xor_in_a = IPAD[543:0];
                        xor_in_b = key[543:0];
                        k_w[543:0] = flip_res;
                    end
                endcase
                
            end
            HASH_S1: begin
                if (hash_ready) begin
                    state_w = XOR_S2;
                    xor_in_a = OPAD[271:0];
                    xor_in_b = key[271:0];
                    k_w[271:0] = flip_res;
                    hash_out_w = flip_out;
                    cnt_w = 1;
                end
                else if (hash_next) begin
                    k_w = message;
                    hash_start_w = 1;
                    more_w = 0;
                end
                else hash_start_w = 0;
            end
            
            XOR_S2: begin
                if (cnt_r == 2'd3) begin
                    state_w = HASH_S2;
                    hash_start_w = 1;
                    more_w = 1;
                end
                cnt_w = cnt_w + 1;
                case (cnt_r)
                    2'd1: begin
                        xor_in_a = OPAD[543:272];
                        xor_in_b = key[543:272];
                        k_w[543:272] = flip_res;
                    end
                    2'd2: begin
                        xor_in_a = OPAD[815:544];
                        xor_in_b = key[815:544];
                        k_w[815:544] = flip_res;
                    end
                    2'd3: begin
                        xor_in_a = OPAD[1087:816];
                        xor_in_b = key[1087:816];
                        k_w[1087:816] = flip_res;
                    end
                    default: begin
                        xor_in_a = OPAD[543:0];
                        xor_in_b = key[543:0];
                        k_w[543:0] = flip_res;
                    end
                endcase
                
            end

            HASH_S2: begin
                hash_start_w = 0;
                if (hash_ready) begin
                    state_w = IDLE;
                    ready_w = 1;
                    hash_out_w = hash_out;
                end
                else if (hash_next) begin
                    k_w = {hash_out_r, 3'b011, 828'd0, 1'b1};
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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hash_start_r <= 0;
            ready_r <= 0;
            k_r <= 0;
            state_r <= IDLE;
            more_r <= 0;
            hash_out_r <= 0;
            cnt_r <= 0;
        end
        else begin
            hash_start_r <= hash_start_w;
            ready_r <= ready_w;
            k_r <= k_w;
            state_r <= state_w;
            more_r <= more_w;
            hash_out_r <= hash_out_w;
            cnt_r <= cnt_w;
        end
    end

endmodule