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
module AES128_core_tb();
    // ==========================================
    // 1. Parameter and ports
    // ==========================================
    parameter DATA_WIDTH =32;

    reg                     clk;
    reg                     rst_n;
    reg                     MP_dv_in;
    reg [DATA_WIDTH-1:0]    plaintext_in;
    reg [DATA_WIDTH-1:0]    key_in;

    wire [DATA_WIDTH-1:0]   data_out;
    wire                    core_dv_out;

    reg [DATA_WIDTH-1:0]    plaintext_r [0:3];
    reg [DATA_WIDTH-1:0]    key_r       [0:3];
    reg [127:0]             expected_result;
    reg [127:0]             actual_result;

    integer i;
    // ==========================================
    // 2. DUT Instantiation
    // ==========================================
    AES128_core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) module_AES_128(
        .clk            (clk),
        .rst_n          (rst_n),
        .plaintext_in   (plaintext_in),
        .key_in         (key_in),
        .MP_dv_in       (MP_dv_in),
        
        .data_out       (data_out),
        .core_dv_out    (core_dv_out)
    );
    // ==========================================
    // 3. Clock Generation
    // ==========================================
    initial begin
        clk = 0;
        forever #5 clk =~clk;
    end
    // ==========================================
    // 4. Main Test Sequence 
    // ==========================================
    initial begin
        $display("========================================");
        $display("TESTBENCH STARTING: AES128_core         ");
        $display("========================================");

        plaintext_r[0] = 32'h41647661;
        plaintext_r[1] = 32'h6E636564; 
        plaintext_r[2] = 32'h20456E63; 
        plaintext_r[3] = 32'h72797074;

        key_r[0]       = 32'h54686174;
        key_r[1]       = 32'h73204D79;
        key_r[2]       = 32'h204B756E;
        key_r[3]       = 32'h67204675;

        expected_result = 128'h6f5ddb7f39560b0fe9eada49f87c4904;

        initialize_inputs();

        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;

        $display("[Time %0t] Reset released.", $time);
        @(posedge clk);
        MP_dv_in <= 1'b1;

        for( i=0; i < 4; i=i+1) begin
            plaintext_in <= plaintext_r[i];
            key_in       <= key_r[i];

            @(posedge clk);
        end

        MP_dv_in      <= 1'b0;   
        actual_result = 0;

        wait(core_dv_out);
        @(negedge clk); 

        for(i=0;i<4;i=i+1) begin
            actual_result = {actual_result[95:0],data_out};  
            if(i<3)
                @(negedge clk); 
        end
        #20;

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
            rst_n        <= 0;
            MP_dv_in     <= 0;
            plaintext_in <= 0;
            key_in       <= 0;
            actual_result<= 0;
        end
    endtask
endmodule
