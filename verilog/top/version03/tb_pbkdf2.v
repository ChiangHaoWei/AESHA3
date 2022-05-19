`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

`define PASSWORD_IN "pbkdf2_patterns/pbkdf2_passward_input.dat"
`define SALT_IN "pbkdf2_patterns/pbkdf2_salt_input.dat"
`define GOLDEN "pbkdf2_patterns/pbkdf2_golden.dat"
`define SDFFILE    "./PBKDF2_syn.sdf"


module tb_hmac;

    localparam DataLength = 20;

    // HMAC input
    reg  clk, rst_n, start, stop;
    reg  [1087:0] passward_in;
    reg  [127:0] salt_in;
    reg  [255:0] golden;
    wire [255:0] key_out;
    wire ready;

    reg [1087:0] pw_mem [0:DataLength-1];
    reg [127:0] salt_mem [0:DataLength-1];
    reg [255:0]  golden_mem [0:DataLength-1];

    integer i, err_num;

    PBKDF2 pbkdf2(
      .clk(clk),
      .rst_n(rst_n),
      .i_start(start),
      .i_pw(passward_in),
      .i_salt(salt_in),
      .o_key(key_out),
      .o_ready(ready)
    );

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, pbkdf2);
    `endif

    initial $readmemh(`PASSWORD_IN, pw_mem);
    initial $readmemh(`SALT_IN, salt_mem);
    initial $readmemh(`GOLDEN, golden_mem);

    initial begin
        clk = 0;
        rst_n = 1;
    end

    always #(`HCYCLE) clk = ~clk;

    initial begin
        $fsdbDumpfile("pbkdf2.fsdb");
        $fsdbDumpvars;
    end

    initial begin
        start = 0;
        stop = 0;
        err_num = 0;
        i = 0;
        passward_in = 0;
        salt_in = 0;
        golden = 0;
        #(`CYCLE);
        rst_n = 0;
        #(`CYCLE);
        rst_n = 1;
        #(`CYCLE);
        start = 1;
        passward_in = pw_mem[i];
        salt_in = salt_mem[i];
        golden = golden_mem[i];
        #(`CYCLE*2);
        start = 0;
    end

    always @(posedge ready) begin
        #(`HCYCLE);
        if (key_out !== golden) begin
            $display("Error at %d:\nmsg=%h\nkey=%h\noutput=%h\nexpect=%h", i, passward_in, salt_in, key_out, golden);
            err_num = err_num + 1;
        end
        i = i + 1;
        #(`HCYCLE);
        if (i == DataLength) stop = 1;
        else begin
            #(`CYCLE);
            rst_n = 0;
            #(`CYCLE);
            rst_n = 1;
            #(`CYCLE);
            #(`HCYCLE);
            start = 1;
            passward_in = pw_mem[i];
            salt_in = salt_mem[i];
            golden = golden_mem[i];
            #(`CYCLE*2);
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
        i    = 0;
        err_num = 0;
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        #(`CYCLE*10000*DataLength);
        $display("--------------------FAIL--------------------\n");
        $display("Too slow....");
        #(`CYCLE) $finish;
    end
    
endmodule