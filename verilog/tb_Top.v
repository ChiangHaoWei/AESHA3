`timescale 1ns/10ps
`define CYCLE	10
`define HCYCLE	5

`define SALT_IN "top_patterns/input_salt.dat"
`define PASSWARD_IN "top_patterns/input_passward.dat"
`define MSG_IN "top_patterns/input_msg.dat"
`define CIPHER_GOLDEN "top_patterns/golden_cipher.dat"
`define MAC_GOLDEN "top_patterns/golden_hmac_value.dat"
`define SDFFILE    "./Top_syn.sdf"


module tb_top;

    localparam DataLength = 20;
    localparam PwLength = 15*8;
    localparam INPUT_SALT_KEY = 0;
    localparam INPUT_MSG = 1;
    localparam OUTPUT_CIPHER = 0;
    localparam OUTPUT_MAC = 1;

    reg clk, rst_n, start, mode, stop, input_state, output_state;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire out_valid, running;

    reg [127:0] cipher_golden, cipher_out;
    reg [255:0] hmac_golden, hmac_out;
    reg has_error;

    reg [127:0]         salt_mem   [0:DataLength-1];
    reg [PwLength-1:0]  pw_mem     [0:DataLength-1];         
    reg [127:0]         cipher_mem [0:DataLength-1];
    reg [255:0]         hmac_mem   [0:DataLength-1];
    reg [127:0]         msg_mem    [0:DataLength-1];

    integer i, j, cipher_err, hmac_err;

    Top top(
        .clk(clk),
        .rst_n(rst_n),
        .i_data(data_in),
        .i_mode(mode),
        .i_start(start),
        .o_data(data_out),
        .o_valid(out_valid),
        .o_ien(running)
    );

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, pbkdf2);
    `endif


    initial $readmemh(`SALT_IN,   salt_mem);
    initial $readmemh(`PASSWARD_IN, pw_mem);
    initial $readmemh(`MSG_IN,        msg_mem);
    initial $readmemh(`CIPHER_GOLDEN, cipher_mem);
    initial $readmemh(`MAC_GOLDEN,    hmac_mem);

    initial begin
        clk = 1;
        rst_n = 1;
    end

    always #(`HCYCLE) clk = ~clk;

    initial begin
        $fsdbDumpfile("top.fsdb");
        $fsdbDumpvars;
    end

    initial begin
        input_state = INPUT_SALT_KEY;
        output_state = OUTPUT_CIPHER;
        cipher_golden = 0; hmac_golden = 0;
        start = 0; mode = 0; data_in = 0;
        stop = 0; i = 0; j=0;
        has_error = 0; cipher_err = 0; hmac_err = 0;
        #(`CYCLE);
        rst_n = 0;
        #(`CYCLE);
        rst_n = 1;
        #(`CYCLE);

        #(`HCYCLE);
        start = 1;
        for (j=15; j>=0; j=j-1) begin
            data_in = salt_mem[i][j*8+7:j*8];
            #(`CYCLE);
        end
        for (j=PwLength/8-1; j>=0; j=j-1) begin
            data_in = pw_mem[i][j*8+7:j*8];
            #(`CYCLE);
        end
        start = 0;
        #(`HCYCLE);
        #(`CYCLE*2);

    end

    always @(negedge running) begin
        if (input_state == INPUT_SALT_KEY) begin
            #(`HCYCLE);
            input_state = INPUT_MSG;
            start = 1;
            for (j=15; j>=0; j=j-1) begin
                data_in = msg_mem[i][j*8+7:j*8];
                #(`CYCLE);
            end
            start = 0;
            #(`HCYCLE);
        end
        else begin
            input_state = INPUT_SALT_KEY;
            i = i+1;
            if (i==DataLength) stop = 1;
            else begin
                // TODO: start next pattern
                #(`CYCLE*2);
                rst_n = 0;
                #(`CYCLE);
                rst_n = 1;
                #(`CYCLE);

                #(`HCYCLE);
                start = 1;
                for (j=15; j>=0; j=j-1) begin
                    data_in = salt_mem[i][j*8+7:j*8];
                    #(`CYCLE);
                end
                for (j=PwLength/8-1; j>=0; j=j-1) begin
                    data_in = pw_mem[i][j*8+7:j*8];
                    #(`CYCLE);
                end
                start = 0;
                #(`HCYCLE);
            end
        end
    end

    always @(posedge out_valid) begin
        if (output_state == OUTPUT_CIPHER) begin
            #(`HCYCLE);
            output_state = OUTPUT_MAC;
            cipher_golden = cipher_mem[i];
            for (j=0; j<16; j=j+1) begin
                cipher_out[j*8+7:j*8] = data_out;
            end
            if (cipher_out !== cipher_golden) begin
                cipher_err = cipher_err + 1;
                $display("Error at %d:\nsalt=%h\npassward=%h\nmsg=%h\ncipher=%h\nexpect=%h", i, salt_mem[i], pw_mem[i], msg_mem[i], cipher_out, cipher_golden);
            end
        end
        else begin
            #(`HCYCLE);
            output_state = OUTPUT_CIPHER;
            hmac_golden = hmac_mem[i];
            for (j=0; j<32; j=j+1) begin
                hmac_out[j*8+7:j*8] = data_out;
            end
            if (hmac_out !== hmac_golden) begin
                hmac_err = hmac_err + 1;
                $display("Error at %d:\nsalt=%h\npassward=%h\nmsg=%h\nhmac=%h\nexpect=%h", i, salt_mem[i], pw_mem[i], msg_mem[i], hmac_out, hmac_golden);
            end
        end
    end


    always @(posedge stop) begin
        if (hmac_err==0 && cipher_err==0) begin
            $display("---------------------------------------------\n");
            $display("All data have been generated successfully!\n");
            $display("--------------------PASS--------------------\n");
            $display("---------------------------------------------\n");
        end
        else begin
            if (cipher_err!=0) begin
                $display("---------------------------------------------\n");
                $display("There are %d errors!\n", cipher_err);
                $display("--------------------FAIL--------------------\n");
                $display("---------------------------------------------\n");
            end
            if (hmac_err!=0) begin
                $display("---------------------------------------------\n");
                $display("There are %d errors!\n", hmac_err);
                $display("--------------------FAIL--------------------\n");
                $display("---------------------------------------------\n");
            end
            
        end

        #(`CYCLE);
        // finish tb
        #(`CYCLE) $finish;
    end

    initial begin
        #(`CYCLE*100000*DataLength);
        $display("--------------------FAIL--------------------\n");
        $display("Too slow....");
        #(`CYCLE) $finish;
    end

  
endmodule