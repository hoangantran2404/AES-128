`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/11/2026 09:08:08 PM
// Design Name: 
// Module Name: AES128_core_SoC
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
    //==========================================//
    //           Interface Definition           //
    //==========================================//
interface aes_interface #(parameter DATA_WIDTH =128) (input bit clk);
    logic                   rst_n;
    logic                   start_in;
    logic [DATA_WIDTH-1:0]  plaintext_in;
    logic                   plaintext_dv_in;
    logic [DATA_WIDTH-1:0]  key_in;
    logic                   key_dv_in;
    logic [DATA_WIDTH-1:0]  data_out;
    logic                   core_dv_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output  rst_n;
        output  start_in;
        output  plaintext_in, plaintext_dv_in, key_in, key_dv_in;
        input   data_out, core_dv_out;
    endclocking
endinterface

module AES128_core_SoC_tb;
    timeunit        1ns;
    timeprecision    1ps;
    
    parameter DATA_WIDTH = 128;

    bit clk;
    logic [DATA_WIDTH-1:0]  initial_plaintext;
    logic [DATA_WIDTH-1:0]  initial_key;
    logic [DATA_WIDTH-1:0]  expected_result;
    logic [DATA_WIDTH-1:0]  actual_result;

    aes_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);
    //==========================================//
    //            DUT INSTANTIATION             //
    //==========================================//
    AES128_core dut(
        .clk                (clk                ),
        .rst_n              (vif.rst_n          ),
        .start_in           (vif.start_in       ),
        .plaintext_in       (vif.plaintext_in   ),
        .plaintext_dv_in    (vif.plaintext_dv_in),
        .key_in             (vif.key_in         ),
        .key_dv_in          (vif.key_dv_in      ),
        
        .data_out           (vif.data_out       ),
        .core_dv_out        (vif.core_dv_out    )
    );
    //==========================================//
    //            CLOCK Generation              //
    //==========================================//
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    //==========================================//
    //            Main Test Sequence            //
    //==========================================//
    initial begin
        initial_plaintext   =    128'h416476616E63656420456E6372797074;
        initial_key          =   128'h5468617473204D79204B756E67204675;
        expected_result     =    128'h6f5ddb7f39560b0fe9eada49f87c4904;

        initialize_input();
        $display("========================================");
        $display("TESTBENCH STARTING: AES128_core         ");
        $display("========================================");

        repeat(2)  @(vif.cb);
        vif.cb.rst_n    <=  1;
        $display("--------------------------------------------------");
        $display("SENDING PLAINTEXT & KEY");
        @(vif.cb);
        vif.cb.plaintext_dv_in  <=  1;
        vif.cb.plaintext_in     <=  initial_plaintext;
        vif.cb.key_dv_in        <=  1;
        vif.cb.key_in           <=  initial_key;
        vif.cb.start_in         <=  1;

        @(vif.cb);
        vif.cb.plaintext_dv_in  <=  0;
        vif.cb.key_dv_in        <=  0;
        vif.cb.start_in         <=  0;
        
        do @(vif.cb); 
        while(vif.cb.core_dv_out==1'b0);
        actual_result           = vif.cb.data_out;
        repeat(5) @(vif.cb);
        $display("========================================");
        $display("VERIFICATION RESULTS");
        $display("Expected: %h", expected_result);
        $display("Actual:   %h", actual_result);

        if (actual_result === expected_result) begin
            $display("STATUS: MATCHED [PASSED]");
        end else begin
            $display("STATUS: FAILED [ERROR]");
        end
        $display("========================================");
        
        $finish;
    end
    task initialize_input();
        begin
            vif.rst_n               <=  0;
            vif.cb.plaintext_dv_in  <=  0;
            vif.cb.key_dv_in        <=  0;
            vif.cb.start_in         <=  0;
            vif.cb.plaintext_in     <=  0;
            vif.cb.key_in           <=  0;
        end
    endtask
    
endmodule
