//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

`define IN_DATA "sha3_patterns/input_pi.dat"
`define GOLDEN "sha3_patterns/golden_pi.dat"


module tb_Chi;

    localparam DataLength = 20;
    reg  [1599:0] in_data;
    reg  [1599:0] out_ans;
    wire [1599:0] out_data;

    reg [1599:0] in_mem         [0:DataLength-1];
    reg [1599:0] golden_mem     [0:DataLength-1];

    integer i, err_num;

    Pi pi0(.in(in_data), .out(out_data));

    initial	$readmemh (`IN_DATA,  in_mem);
    initial	$readmemh (`GOLDEN,  golden_mem);

   initial begin
       $fsdbDumpfile("pi.fsdb");
       $fsdbDumpvars;
   end

    initial begin
        in_data = 0;
        out_ans = 0;
        i    = 0;
        err_num = 0;

        $display("Testing Pi Stage...");
        // $display("test mod %d mod %d = %d", -1, 64, -1%64);
        for (i=0; i<DataLength; i=i+1) begin
            #(`CYCLE);
            in_data = in_mem[i];
            out_ans = golden_mem[i];

            #(`HCYCLE);
            if (out_data !== out_ans) begin
              $display("Error at %d:\nin=%h\noutput=%h\nexpect=%h", i, in_data, out_data, out_ans);
              err_num = err_num + 1;
            end
            
            #(`HCYCLE);
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