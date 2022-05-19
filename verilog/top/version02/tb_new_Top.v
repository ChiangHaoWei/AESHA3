`timescale 1ns/10ps
`define CYCLE	14
`define HCYCLE	7

`define MODE_IN "new_top_patterns/input_mode.dat"
`define MSG_IN "new_top_patterns/input_msg.dat"
`define GOLDEN "new_top_patterns/output_golden.dat"
`define SDFFILE    "./synthesis/Top_syn.sdf"


module tb_new_Top;
    localparam DataLength = 20;
    localparam GoldenLength = 32;
    localparam MsgLength = 14;

    reg clk, rst_n, start, stop;

    reg [7:0] data_in;
    reg [1:0] mode;
    wire [7:0] data_out;
    wire out_valid;

    reg [GoldenLength*8-1:0] golden;
    reg [GoldenLength*8-1:0] chip_output;
    
    reg [GoldenLength*8-1:0] golden_mem [0:DataLength-1];
    reg [MsgLength*8-1:0] msg_mem [0:DataLength-1];
    reg [1:0] mode_mem [0:DataLength-1];

    integer i, j, err_num;

    Top top(
        .clk(clk),
        .rst_n(rst_n),
        .i_data(data_in),
        .i_mode(mode),
        .i_start(start),
        .o_data(data_out),
        .o_valid(out_valid)
    );

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, top);
    `endif

    initial $readmemh(`MSG_IN, msg_mem);
    initial $readmemh(`GOLDEN, golden_mem);
    initial $readmemb(`MODE_IN, mode_mem);

    initial begin
        clk = 1;
        rst_n = 1;
    end

    always #(`HCYCLE) clk = ~clk;

    initial begin
        $dumpfile("Top_new.vcd");
		$dumpvars();
    end

    initial begin
        start = 0;
        stop = 0;
        mode = 0;
        err_num = 0;
        data_in = 0;
        golden = 0;
        i=0;

        #(`CYCLE);
        rst_n = 0;
        #(`CYCLE);
        rst_n = 1;
        #(`CYCLE);
        #(`HCYCLE);
        mode = mode_mem[i];
        golden = golden_mem[i];
        start = 1;
        for (j=MsgLength-1; j>=0; j=j-1) begin
            data_in = msg_mem[i][j*8+:8];
            #(`CYCLE);
        end
        start = 0;
        #(`HCYCLE);
    end

    always @(posedge out_valid) begin
        #(`HCYCLE);
        for (j=0; j<GoldenLength; j=j+1) begin
            chip_output[j*8+:8] = data_out;
            #(`CYCLE);
        end
        if (chip_output!=golden) begin
            err_num = err_num + 1;
            $display("Error at %d:\ninput=%h\noutput=%h\nexpect=%h", i, msg_mem[i], chip_output, golden_mem[i]);
        end
        #(`HCYCLE);
        #(`CYCLE*2);
        i = i + 1;
        if (i==DataLength) stop = 1;
        else begin
            #(`CYCLE);
            rst_n = 0;
            #(`CYCLE);
            rst_n = 1;
            #(`CYCLE);
            #(`HCYCLE);
            mode = mode_mem[i];
            golden = golden_mem[i];
            start = 1;
            for (j=MsgLength-1; j>=0; j=j-1) begin
                data_in = msg_mem[i][j*8+:8];
                #(`CYCLE);
            end
            start = 0;
            #(`HCYCLE);
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