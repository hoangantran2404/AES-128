`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2025 04:11:13 PM
// Design Name: 
// Module Name: key_expansion_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module cipher_tb();
    parameter DATA_WIDTH =32;

    reg clk, rst_n;
    reg [2:0] FSM_core_in;
    reg [3:0] core_count_in;
    reg [DATA_WIDTH-1:0] text_0_in;
    reg [DATA_WIDTH-1:0] text_1_in;
    reg [DATA_WIDTH-1:0] text_2_in;
    reg [DATA_WIDTH-1:0] text_3_in;

    reg [DATA_WIDTH -1: 0] key_0_in;
    reg [DATA_WIDTH -1: 0] key_1_in;
    reg [DATA_WIDTH -1: 0] key_2_in;
    reg [DATA_WIDTH -1: 0] key_3_in;

    wire [DATA_WIDTH -1: 0] text_0_out;
    wire [DATA_WIDTH -1: 0] text_1_out;
    wire [DATA_WIDTH -1: 0] text_2_out;
    wire [DATA_WIDTH -1: 0] text_3_out;
    wire                    cipher_dv_flag;

    reg [DATA_WIDTH  -1:0] KE_byte_in   [0:43];
    reg [DATA_WIDTH  -1:0] plaintext_in [0:3];

    reg [127:0]             expected_result;
    wire[127:0]            actual_result;
    integer i;
    // ==========================================
    // 2. DUT Instantiation
    // ==========================================
    Cipher #(
        .DATA_WIDTH(DATA_WIDTH)
    ) module_Cipher_tb 
    (
        .clk(clk),
        .rst_n(rst_n),
        .FSM_core_in(FSM_core_in),
        .core_count_in(core_count_in),

        .text_0_in(text_0_in),
        .text_1_in(text_1_in),
        .text_2_in(text_2_in),
        .text_3_in(text_3_in),

        .key_0_in(key_0_in),
        .key_1_in(key_1_in),
        .key_2_in(key_2_in),
        .key_3_in(key_3_in),

        .text_0_out(text_0_out),
        .text_1_out(text_1_out),
        .text_2_out(text_2_out),
        .text_3_out(text_3_out),
        .cipher_dv_flag(cipher_dv_flag)
    );

    assign actual_result ={text_0_out,text_1_out,text_2_out,text_3_out};
    // ==========================================
    // 3. Clock Generation
    // ==========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    // ==========================================
    // 4. Main Test Sequence 
    // ==========================================
    initial begin
        $display("========================================");
        $display("TESTBENCH STARTING: AES128-cipher       ");
        $display("========================================");

        $readmemh("/home/hoangan2404/Project_0/FPGA/AO/AES128/project_1/project_1.srcs/sim_1/new/word.txt",KE_byte_in);

        plaintext_in[0] = 32'h41647661;
        plaintext_in[1] = 32'h6E636564; 
        plaintext_in[2] = 32'h20456E63; 
        plaintext_in[3] = 32'h72797074;

        expected_result = 128'h6f5ddb7f39560b0fe9eada49f87c4904;

        initialize_inputs();
        
        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;

        $display("[Time %0t] Reset released.", $time);

        @(posedge clk);
        FSM_core_in     <= 3'b001;
        core_count_in   <= 0;

        text_0_in       <= plaintext_in[0];
        text_1_in       <= plaintext_in[1];
        text_2_in       <= plaintext_in[2];
        text_3_in       <= plaintext_in[3];

        $display("[Time %0t] Loading Input Data...", $time);
        @(posedge clk);
        FSM_core_in     <= 3'b010;

        for(i=0 ; i<=10 ; i = i+1) begin
                key_0_in      <= KE_byte_in[4*i+0];
                key_1_in      <= KE_byte_in[4*i+1];
                key_2_in      <= KE_byte_in[4*i+2];
                key_3_in      <= KE_byte_in[4*i+3];
            
                core_count_in <=  i;

                $display("[Time %0t] Processing Round %0d", $time, i);
                @(posedge clk);
        end

        FSM_core_in <= 3'b011;
        #1;

        $display("----------------------------------------");
        $display("RESULT CHECK:");
        $display("   Expected: %h", expected_result);
        $display("   Actual  : %h", actual_result);

        if (actual_result == expected_result) begin
            $display("   STATUS  : [PASSED] Success!");
        end else begin
            $display("   STATUS  : [FAILED] Output mismatch!");
        end
        $display("========================================");
        $stop;
    end

    task initialize_inputs;
            begin
                rst_n           <= 0;
                FSM_core_in     <= 0;
                core_count_in   <= 0;
                key_0_in        <= 0;
                key_1_in        <= 0;
                key_2_in        <= 0;
                key_3_in        <= 0;
                text_0_in       <= 0;
                text_1_in       <= 0;
                text_2_in       <= 0;
                text_3_in       <= 0;
            end
        endtask
endmodule
