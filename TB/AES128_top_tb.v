`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 09:13:11 AM
// Design Name: 
// Module Name: AES128_top_tb
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


module AES128_top_tb();
    // ==========================================
    // 1. Parameter and ports
    // ==========================================
    parameter CLK_PERIOD   = 10;
    parameter CLKS_PER_BIT = 868;
    parameter BIT_PERIOD   = CLK_PERIOD * CLKS_PER_BIT;

    reg                 clk;
    reg                 rst_n;
    reg                 data_in;

    wire                data_out;

    reg [127:0]         initial_plaintext;
    reg [127:0]         initial_key;
    reg [127:0]         expected_result;

    // ==========================================
    // 2. DUT Instantiation
    // ==========================================
    AES128_top module_AES128_top(
        .clk        (clk    ),
        .rst_n      (rst_n  ),
        .data_in    (data_in),

        .data_out   (data_out)
    );
    // ==========================================
    // 3. Clock Generation
    // ==========================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    // ==========================================
    // 4. Data Prev 
    // ==========================================
    initial begin
        $display("========================================");
        $display("TESTBENCH STARTING: AES128_top          ");
        $display("========================================");

        initial_plaintext= 128'h416476616E63656420456E6372797074;

        initial_key      = 128'h5468617473204D79204B756E67204675;

        expected_result  = 128'h6f5ddb7f39560b0fe9eada49f87c4904;
    end
    // ==========================================
    // 5. Task 
    // ==========================================
    task UART_SEND_BYTE;
        input [7:0] i_Data;
        integer i;
        begin
                data_in = 1'b0; 
                #(BIT_PERIOD);

                for (i=0; i<8; i=i+1) begin
                    data_in = i_Data[i ];
                    #(BIT_PERIOD);
                end
                data_in = 1'b1; 
                #(BIT_PERIOD);
                #(BIT_PERIOD);
        end
    endtask

   
    task UART_RECEIVE_BYTE;
        output [7:0] o_Data;
        integer i;
        begin
                wait(data_out == 1'b0); 
                #(BIT_PERIOD + (BIT_PERIOD / 2)); 
                
                for (i=0; i<8; i=i+1) begin
                    o_Data[i] = data_out;
                    #(BIT_PERIOD);
                end
                #(BIT_PERIOD / 2);
        end
    endtask
    // ==========================================
    // 6. SEND process 
    // ==========================================
    integer send_i;
    initial begin
        rst_n   = 0;
        data_in = 1;
        #100;
        rst_n   = 1;

        $display("--------------------------------------------------");
        
        $display("[SEND] STARTING SENDING PLAINTEXT (16 BYTES)...");
        for(send_i = 0; send_i <16; send_i = send_i + 1 ) begin
            UART_SEND_BYTE(initial_plaintext[127 - 8* send_i -: 8]);
        end
        
        $display("[SEND] STARTING SENDING KEY (16 BYTES)...");
        for(send_i=0 ;send_i<16; send_i = send_i + 1) begin
            UART_SEND_BYTE(initial_key[127- 8*send_i -:8]);
        end

        $display("[SEND] FINISED SENDING.");
    end


    // ==========================================
    // 7. RECEIVE process 
    // ==========================================
    integer     rx_i;
    reg [7:0]   RX_byte;
    reg [127:0] actual_result;

    initial begin
        actual_result <= 128'b0;
        #200;

        $display(" [RX] RECEIVER LISTENING...");
        for(rx_i = 0; rx_i <16; rx_i = rx_i +1) begin
            UART_RECEIVE_BYTE(RX_byte);
            actual_result[127-8*rx_i -:8] = RX_byte;
            $display(" [RX] Received Byte %0d: %h", rx_i, RX_byte);
        end

        #1000;
        $display("==================================================");
        $display("Expected: %h", expected_result);
        $display("Actual  : %h", actual_result);
        $display("--------------------------------------------------");
        
        if (actual_result == expected_result) begin
            $display(" RESULT: *** PASSED *** ");
        end else begin
            $display(" RESULT: *** FAILED *** ");
        end
        $display("==================================================");
        $stop;
    end 
endmodule
