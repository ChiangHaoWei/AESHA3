//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

`define IN_DATA "aes_patterns/input_key_schedule.dat"
`define GOLDEN "aes_patterns/golden_key_schedule.dat"


module tb_SubByte;

    localparam DataLength = 20;
    reg  clk, rst;
    reg  [127:0] in_data;
    reg  [1279:0] out_ans;
    wire [1279:0] out_data;

    reg [127:0] in_mem         [0:DataLength-1];
    reg [1279:0] golden_mem     [0:DataLength-1];

    reg start, stop;
    wire finish;

    integer i, err_num;

    KeySchedule key_schedule(.key(in_data), .roundkeys(out_data), .clk(clk), .rst(rst), .start(start), .finish(finish));

    initial	$readmemh (`IN_DATA,  in_mem);
    initial	$readmemh (`GOLDEN,  golden_mem);
    initial begin
        clk = 0;
        rst = 0;
    end
    always #(`HCYCLE) clk = ~clk;

    initial begin
        $fsdbDumpfile("key_schedule.fsdb");
        $fsdbDumpvars;
    end

    initial begin
        in_data = 0;
        out_ans = 0;
        start = 0;
        stop = 0;
        i    = 0;
        err_num = 0;

        $display("Testing KeySchedule...");
        #(`CYCLE);
        rst = 1;
        #(`CYCLE);
        rst = 0;

        #(`CYCLE);
        start = 1;
        in_data = in_mem[i];
        out_ans = golden_mem[i];
        #(`CYCLE*2);
        start = 0;
    end


    always @(posedge finish) begin
        #(`HCYCLE);
        if (out_data !== out_ans) begin
            $display("Error at %d:\nin=%h\noutput=%h\nexpect=%h", i, in_data, out_data, out_ans);
            err_num = err_num + 1;
        end
        i = i + 1;
        #(`HCYCLE);
        if (i == DataLength) stop = 1;
        else begin
            #(`CYCLE);
            rst = 1;
            #(`CYCLE);
            rst = 0;

            #(`CYCLE);
            start = 1;
            in_data = in_mem[i];
            out_ans = golden_mem[i];
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
        #(`CYCLE*100*DataLength);
        $display("--------------------FAIL--------------------\n");
        $display("Too slow....");
        #(`CYCLE) $finish;
    end
endmodule
