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
module MP_in_tb();
    // ==========================================
    // 1. Parameter and ports
    // ==========================================
    parameter DATA_WIDTH = 32;

    reg                     clk;
    reg                     rst_n;
    reg  [7:0]              uart_byte_in;
    reg                     RX_DV_in;

    wire [DATA_WIDTH-1:0]   MP_plaintext_out;
    wire [DATA_WIDTH-1:0]   MP_key_out;
    wire                    MP_dv_out;

    reg [127:0]             plaintext_r;
    reg [127:0]             key_r;
    reg [127:0]             plaintext_result;
    reg [127:0]             key_result;
    
    integer i;
    // ==========================================
    // 2. DUT Instantiation
    // ==========================================
    MP_in #(
        .DATA_WIDTH(DATA_WIDTH)
    ) module_MP_in_tb
    (
        .clk                (clk),
        .rst_n              (rst_n),
        .uart_byte_in       (uart_byte_in),
        .RX_DV_in           (RX_DV_in),

        .MP_plaintext_out   (MP_plaintext_out),
        .MP_key_out         (MP_key_out),
        .MP_dv_out          (MP_dv_out)
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
        $display("TESTBENCH STARTING: AES128_MP_in        ");
        $display("========================================");

        plaintext_r = 128'h416476616E63656420456E6372797074;
        key_r       = 128'h5468617473204D79204B756E67204675;

        initialize_inputs();

        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n =1;

        $display("[Time %0t] Reset released.", $time);
        @(posedge clk);
        
        for(i=0; i< 16; i=i+1) begin
            RX_DV_in     <= 1'b1;
            uart_byte_in <= plaintext_r[127-8*i -:8];
            @(posedge clk);
        end
        for(i=0; i<16; i=i+1) begin
            RX_DV_in     <= 1'b1;
            uart_byte_in <= key_r[127-8*i -:8];
            @(posedge clk);
        end
    
        wait(MP_dv_out);
        @(negedge clk);

        for(i=0 ;i<4 ;i=i+1) begin
            plaintext_result <= {plaintext_result[95:0], MP_plaintext_out};
            key_result       <= {key_result[95:0], MP_key_out};

            if(i<3)
                @(negedge clk);
        end
        #20

        $display("----------------------------------------");
        $display("RESULT CHECK:");
        $display("   Plaintext: %h", plaintext_result);
        $display("   Expected : %h", plaintext_r);
        $display("   KEY      : %h", key_result);
        $display("   Expected : %h", key_r);

        if (plaintext_result == plaintext_r && key_result == key_r ) begin
            $display("   STATUS  : [PASSED] Success!");
        end else begin
            $display("   STATUS  : [FAILED] Output mismatch!");
        end
        $display("========================================");
        $stop;
    end
    task initialize_inputs;
        begin
            clk              <= 0;
            rst_n            <= 0;
            uart_byte_in     <= 0;
            RX_DV_in         <= 0;
            plaintext_result <= 0;
            key_result       <= 0;
        end
    endtask

endmodule
