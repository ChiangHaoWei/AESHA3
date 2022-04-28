`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

`define HMAC_IN "hmac_patterns/hmac_rev_msg_input.dat"
`define KEY_IN "hmac_patterns/hmac_key_input.dat"
`define GOLDEN "hmac_patterns/hmac_golden.dat"

module tb_hmac;

    localparam DataLength = 20;

    // HMAC input
    reg  clk, rst_n, start, stop;
    reg  [1087:0] key_in;
    reg  [1087:0] msg_in;
    reg  [255:0] golden;
    wire [255:0] hmac_value;
    wire hmac_ready;

    reg [1087:0] key_mem [0:DataLength-1];
    reg [1087:0] msg_mem [0:DataLength-1];
    reg [255:0]  mac_mem [0:DataLength-1];

    integer n, err_num;

    HMAC hmac(.clk(clk), .rst_n(rst_n), .start(start), .key(key_in), .message(msg_in), .mac_value(hmac_value), .ready(hmac_ready));

    initial $readmemh(`HMAC_IN, msg_mem);
    initial $readmemh(`KEY_IN, key_mem);
    initial $readmemh(`GOLDEN, mac_mem);



    initial begin
        $fsdbDumpfile("hmac.fsdb");
        $fsdbDumpvars;
    end

    initial begin
        start = 0;
        stop = 0;
        err_num = 0;
        n = 0;
        key_in = 0;
        msg_in = 0;
        golden = 0;
        #(`CYCLE);
        rst_n = 0;
        #(`CYCLE);
        rst_n = 1;
        #(`CYCLE);
        start = 1;
        key_in = key_mem[n];
        msg_in = msg_mem[n];
        golden = mac_mem[n];
        #(`CYCLE*2);
        start = 0;
    end

    initial begin
        clk = 0;
        rst_n = 1;
    end

    always #(`HCYCLE) clk = ~clk;

    always @(posedge hmac_ready) begin
        #(`HCYCLE);
        if (hmac_value !== golden) begin
            $display("Error at %d:\nmsg=%h\nkey=%h\noutput=%h\nexpect=%h", n, msg_in, key_in, hmac_value, golden);
            err_num = err_num + 1;
        end
        n = n + 1;
        #(`HCYCLE);
        if (n == DataLength) stop = 1;
        else begin
            #(`CYCLE*2);
            rst_n = 0;
            #(`CYCLE);
            rst_n = 1;
            #(`CYCLE);
            #(`HCYCLE);
            start = 1;
            key_in = key_mem[n];
            msg_in = msg_mem[n];
            golden = mac_mem[n];
            #(`CYCLE);
            start = 0;
        end
    end

    always @(posedge stop) begin
        if (err_num==0) begin
            $display("---------------------------------------------\n");
            $display("All data have been generated successfully!\n");
            $display("--------------------PASS--------------------\n");
            $display("---------------------------------------------\n");
        end
        else begin
            $display("---------------------------------------------\n");
            $display("There are %d errors!\n", err_num);
            $display("--------------------FAIL--------------------\n");
            $display("---------------------------------------------\n");
        end

        #(`CYCLE);
        n    = 0;
        err_num = 0;
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        #(`CYCLE*1000*DataLength);
        $display("--------------------FAIL--------------------\n");
        $display("Too slow....");
        #(`CYCLE) $finish;
    end
    
endmodule