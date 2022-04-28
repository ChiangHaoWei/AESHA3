//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

`define IN_DATA "aes_patterns/full_input.dat"
`define GOLDEN "aes_patterns/full_cipher.dat"
`define KEY_IN "aes_patterns/full_key.dat"
`define DEC_GOLDEN "aes_patterns/full_plain.dat"


module tb_SubByte;

    localparam DataLength = 10;
    reg  [127:0] in_data;
    reg  [127:0] out_ans;
    wire [127:0] out_data;
    reg clk,rst_n;
    reg mode; // 0: encrypt, 1: decrypt

    reg [127:0] in_mem         [0:DataLength-1];
    reg [127:0] key_in_mem     [0:DataLength-1];
    reg [127:0] golden_mem     [0:DataLength-1];
    reg [127:0] dec_golden_mem [0:DataLength-1];

    integer i, err_num;

    AESTOP mix_column(  .clk(clk),
                        .rst_n(rst_n),
                        .mode(mode), //mode = 1 --> decode?
                        .i_start(start),
                        .i_key(in_key),
                        .i_in(in_data),
                        .o_cipher(out_data),
                        .o_ready(ready));
    // InvSubByte inv_sub_byte(.in(inv_in), .out(inv_out));

    initial	$readmemh (`IN_DATA,  in_mem);
    initial	$readmemh (`GOLDEN,  golden_mem);
    initial $readmemh (`KEY_IN, key_in_mem);
    initial $readmemh (`DEC_GOLDEN, dec_golden_mem);

    initial begin
        $fsdbDumpfile("AESTOP.fsdb");
        $fsdbDumpvars;
    end

    initial begin
        clk = 1'b0;
        forever #(`CYCLE * 0.5) clk = ~clk;
    end

    initial begin
        in_data = 0;
        out_ans = 0;
        i    = 0;
        rst_n = 1
        err_num = 0;
        mode = 0;
        start = 0;
        #(`CYCLE)
        rst_n = 0;
        #(`CYCLE*4)
        rst_n = 1;
        #(`HCYCLE)

        $display("Testing Encode...");
        for (i=0; i<DataLength; i=i) begin
            start = 1;
            in_data = in_mem[i];
            in_key = key_in_mem[i]
            out_ans = golden_mem[i];
            #(`CYCLE);
            start = 0;
            wait(ready);
            #(`HCYCLE);
            if (out_data !== out_ans) begin
              $display("Error at %d: in=%h, output=%h, expect=%h", i, in_data, out_data, out_ans);
              err_num = err_num + 1;
            end
            
            wait(clk);
        end
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
        in_data = 0;
        out_ans = 0;
        i    = 0;
        err_num = 0;
        mode = 1;

        $display("Testing Decode...");
        for (i=0; i<DataLength; i=i) begin
            start = 1;
            in_data = in_mem[i];
            in_key = key_in_mem[i]
            out_ans = dec_golden_mem[i];
            #(`CYCLE);
            start = 0;
            wait(ready);
            #(`HCYCLE);
            if (out_data !== out_ans) begin
              $display("Error at %d: in=%h, output=%h, expect=%h", i, in_data, out_data, out_ans);
              err_num = err_num + 1;
            end
            
            wait(clk);
        end
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
        
        // finish tb
        #(`CYCLE) $finish;
    end
endmodule
