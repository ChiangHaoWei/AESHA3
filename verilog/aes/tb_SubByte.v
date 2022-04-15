//always block tb
`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

`define IN_DATA "aes_patterns/input_sub_bytes.dat"
`define GOLDEN "aes_patterns/golden_sub_bytes.dat"
`define INV_IN "aes_patterns/input_inv_sub_bytes.dat"
`define INV_GOLDEN "aes_patterns/golden_inv_sub_bytes.dat"


module tb_SubByte;

    localparam DataLength = 20;
    reg  [127:0] in_data, inv_in;
    reg  [127:0] out_ans, inv_ans;
    wire [127:0] out_data, inv_out;

    reg [127:0] in_mem         [0:DataLength-1];
    reg [127:0] inv_in_mem     [0:DataLength-1];
    reg [127:0] golden_mem     [0:DataLength-1];
    reg [127:0] inv_golden_mem [0:DataLength-1];

    integer i, err_num;

    SubByte sub_byte(.in(in_data), .out(out_data));
    InvSubByte inv_sub_byte(.in(inv_in), .out(inv_out));

    initial	$readmemh (`IN_DATA,  in_mem);
    initial	$readmemh (`GOLDEN,  golden_mem);
    initial $readmemh (`INV_IN, inv_in_mem);
    initial $readmemh (`INV_GOLDEN, inv_golden_mem);

   initial begin
       $fsdbDumpfile("sub_bytes.fsdb");
       $fsdbDumpvars;
   end

    initial begin
        in_data = 0;
        out_ans = 0;
        i    = 0;
        err_num = 0;

        $display("Testing SubByte...");
        for (i=0; i<DataLength; i=i+1) begin
            #(`CYCLE);
            in_data = in_mem[i];
            out_ans = golden_mem[i];

            #(`HCYCLE);
            if (out_data != out_ans) begin
              $display("Error at %d: in=%h, output=%h, expect=%h", i, in_data, out_data, out_ans);
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

        #(`CYCLE);
        inv_in = 0;
        inv_ans = 0;
        i    = 0;
        err_num = 0;

        $display("Testing InvSubByte...");
        for (i=0; i<DataLength; i=i+1) begin
            #(`CYCLE);
            inv_in = inv_in_mem[i];
            inv_ans = inv_golden_mem[i];

            #(`HCYCLE);
            if (inv_out != inv_ans) begin
              $display("Error at %d: in=%h, output=%h, expect=%h", i, inv_in, inv_out, inv_ans);
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
