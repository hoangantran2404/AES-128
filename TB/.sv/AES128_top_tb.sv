`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2025 04:47:48 PM
// Design Name: AES128_top_tb using SystemVerilog 
// Module Name: AES128_top_tb
// Project Name: AES128
// Target Devices: ZCU102 Xilinx FPGA Board
// Tool Versions: Vivado 2022.2 and VS code
// Description: This testbench is runned on baudrate 116800, FREQ is 100MHz.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
    //==========================================//
    //           Interface Definition           //
    //==========================================//
interface AES128_top_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic rst_n;
    logic data_in;
    logic data_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
    endclocking
endinterface
    //==========================================//
    //          Main Testbench Module           //
    //==========================================//
module AES128_top_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH   = 32;
    parameter CLK_PERIOD   = 10;
    parameter CLKS_PER_BIT = 868; // BAUDRATE = 116800, clock 100MHz
    parameter BIT_PERIOD   = CLK_PERIOD * CLKS_PER_BIT;

    bit clk;
    logic [7:0]   RX_byte;
    logic [127:0] initial_plaintext;
    logic [127:0] initial_key;
    logic [127:0] expected_result;
    logic [127:0] actual_result;

    AES128_top_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);
     //==========================================//
    //            DUT INSTANTIATION             //
    //==========================================//
    AES128_top dut(
        .clk            (clk        ),
        .rst_n          (vif.rst_n  ),
        .data_in        (vif.data_in),
        .data_out       (vif.data_out)
    );
    //==========================================//
    //            CLOCK Generation              //
    //==========================================//
    initial begin
        clk = 0;
        forever #5 clk =~clk;
    end
    //==========================================//
    //            Main Test Sequence            //
    //==========================================//
    initial begin
        $display("========================================");
        $display("TESTBENCH STARTING: AES128_top          ");
        $display("========================================");

        initial_plaintext= 128'h416476616E63656420456E6372797074;

        initial_key      = 128'h5468617473204D79204B756E67204675;

        expected_result  = 128'h6f5ddb7f39560b0fe9eada49f87c4904;

        initialize_input();
        #200;
        vif.cb.rst_n <= 1;

        $display("--------------------------------------------------");
        fork
            begin
                $display("[SEND] STARTING SENDING PLAINTEXT (16 BYTES)...");
                for(int i = 0; i <16; i++ ) begin
                    UART_SEND(initial_plaintext[127 - 8*i -: 8]);
                end

                $display("[SEND] STARTING SENDING KEY (16 BYTES)...");
                for(int i=0 ;i<16; i++) begin
                    UART_SEND(initial_key[127- 8*i -:8]);
                end
            end
            begin
                $display(" [RX] RECEIVER LISTENING...");
                for(int i = 0; i <16; i++) begin
                    UART_RX(RX_byte);
                    actual_result[127-8*i -:8] = RX_byte;
                end
            end
        join
        $display("==================================================");
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
    //==========================================//
    //            Task & Function               //
    //==========================================//
    task UART_SEND();
        input [7:0] i_Data;
        begin
            vif.data_in <= 1'b0; 
            #(BIT_PERIOD);

            for (int i=0; i<8; i++) begin
                vif.data_in <= i_Data[i];
                #(BIT_PERIOD);
            end
            vif.data_in <= 1'b1; 
            #(BIT_PERIOD);
            #(BIT_PERIOD);
        end
    endtask

    task UART_RX();
        output [7:0] o_Data;
        begin
                @( negedge vif.data_out); 
                #(BIT_PERIOD + (BIT_PERIOD / 2)); 
                
                for (int i=0; i<8; i++) begin
                    o_Data[i] = vif.data_out;
                    #(BIT_PERIOD);
                end
                #(BIT_PERIOD / 2);
        end
    endtask

    task initialize_input();
        begin
            vif.cb.rst_n   <= 0;
            vif.data_in <= 0;
        end
    endtask

endmodule
