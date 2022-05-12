//always block tb
`timescale 1ns/10ps
`define CYCLE	20
`define HCYCLE	10
`define NUM_DATA 2
`define IN_DATA "sha3_patterns/input_sha_top.dat"
`define GOLDEN "sha3_patterns/golden_sha_top.dat"

module tb_sha3top;

reg           clk;
reg         rst_n;
reg more,in_valid;


localparam DataLength = 4;
reg  [1087:0] in_data;
reg  [255:0] out_ans;
wire [255:0] out_data;
wire out_valid;
wire hash_next;

reg [1087:0] in_mem         [0:DataLength-1];
reg [255:0] golden_mem     [0:DataLength-1];

integer i,delay_num, err_num;
SHA3 sha3des(.clk(clk), .in(in_data) ,.more(more),.in_valid(in_valid),.hash_next(hash_next), .out(out_data), .out_valid(out_valid) ,.rst_n( rst_n));

initial begin
    $readmemh (`IN_DATA,  in_mem);
    $readmemh (`GOLDEN,  golden_mem);
    $fsdbDumpfile("SHA3TOP.fsdb");
    $fsdbDumpvars;
end
//more in_valid in_data  out_ans;
initial begin
    clk=1'b0;
    rst_n = 1;
    #(`CYCLE)
    rst_n=0;
    #(`CYCLE)
    rst_n=1;
    more =0;
    in_valid=0;
    out_ans=0;
    in_data=0;
    err_num=0;
    i    = 0;
    $display("-------------------------------------------");
    $display("Test function of SHATOP...");
    for (i=0; i<2; i=i+1) begin
        delay_num = $urandom%3;
        #(`CYCLE*delay_num)
        in_data=in_mem[2*i];
        in_valid=1;
        more=1;
        #(`CYCLE)
        in_data=0;
        in_valid=0;
        #(`CYCLE*48)
        in_data=in_mem[2*i+1];
        in_valid=1;
        #(`CYCLE)
        in_data=0;
        in_valid=0;
        more=0;
        #(`CYCLE*47)
         out_ans=golden_mem[i];
        if (out_valid) begin
            if (out_ans!==out_data) begin
                $display("Error at pattern number %d\nin=%h\noutput=%h\nexpect=%h", i,{in_mem[2*(i)],in_mem[2*(i)+1]} ,out_data, out_ans);
                err_num=err_num+1;
            end
            else begin
                $display("success at pattern number %d\nin=%h\noutput=%h\nexpect=%h", i,{in_mem[2*(i)],in_mem[2*(i)+1]} ,out_data, out_ans);
            end
        end
        else begin
            $display("Error :no out_valid");
        end
        #(`CYCLE)
         out_ans=0;
        #(`CYCLE);
    end
    if (err_num == 0)
        $display("Success!! You passed the simulation");
    #(`CYCLE)
    $finish;

end

always  #(`HCYCLE) clk = ~clk ;

endmodule
