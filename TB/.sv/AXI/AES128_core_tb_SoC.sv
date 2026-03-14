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
interface aes_interface #(parameter DATA_WIDTH = 128) (input bit clk);
    logic                   rst_n;
    logic                   start_in;
    logic                   done_in;
    logic [DATA_WIDTH-1:0]  plaintext_in;
    logic                   plaintext_dv_in;
    logic [DATA_WIDTH-1:0]  key_in;
    logic                   key_dv_in;
    logic [DATA_WIDTH-1:0]  data_out;
    logic                   core_dv_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output  rst_n;
        output  start_in,done_in;
        output  plaintext_in, plaintext_dv_in, key_in, key_dv_in;
        input   data_out, core_dv_out;
    endclocking
endinterface

//==========================================//
//              Testbench Top               //
//==========================================//
module AES128_core_SoC_tb;
    timeunit                1ns;
    timeprecision           1ps;
    
    //--------------------------------------
    // 1. Clock Generation
    //--------------------------------------
    bit clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  
    end

    //--------------------------------------
    // 2. Interface & DUT Instantiation
    //--------------------------------------
    aes_interface #(.DATA_WIDTH(128)) vif(clk);

    AES128_core #(.DATA_WIDTH(128)) DUT (
        .clk            (clk),
        .rst_n          (vif.rst_n),
        .start_in       (vif.start_in),
        .done_in        (vif.done_in),
        .plaintext_in   (vif.plaintext_in),
        .plaintext_dv_in(vif.plaintext_dv_in),
        .key_in         (vif.key_in),
        .key_dv_in      (vif.key_dv_in),
        .data_out       (vif.data_out),
        .core_dv_out    (vif.core_dv_out)
    );

    //--------------------------------------
    // 3. Data Structures for Test Vectors
    //--------------------------------------
    typedef struct {
        string                  test_name;
        logic [127:0]           pt;         // Plaintext
        logic [127:0]           key;        // Key
        logic [127:0]           exp_ct;     // Expected Ciphertext
    } test_vector_t;

    // Test cases from FIPS-197 of NIST's dataset)
    test_vector_t test_cases[3] = '{
        '{"NIST SP800-38A", 128'h6bc1bee22e409f96e93d7e117393172a, 128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3ad77bb40d7a3660a89ecaf32466ef97},
        '{"NIST FIPS-197" , 128'h3243f6a8885a308d313198a2e0370734, 128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3925841d02dc09fbdc118597196a0b32},
        '{"ALL ZEROS"     , 128'h00000000000000000000000000000000, 128'h00000000000000000000000000000000, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e}
    };

    int passed_cases = 0;
    int failed_cases = 0;

    //--------------------------------------
    // 4. Tasks 
    //--------------------------------------
    task automatic initialize_input();
        vif.rst_n           <= 0;
        vif.cb.start_in     <= 0;
        vif.cb.plaintext_in <= 0;
        vif.cb.plaintext_dv_in <= 0;
        vif.cb.key_in       <= 0;
        vif.cb.key_dv_in    <= 0;
        repeat(5) @(vif.cb);
        vif.rst_n           <= 1;
        repeat(2) @(vif.cb);
    endtask

    task automatic run_test_case(int id, test_vector_t tv);
        int timeout_counter = 0;

        $display("--------------------------------------------------");
        $display("[RUNNING] Case %0d: %s", id, tv.test_name);
        
        // Sending data
        @(vif.cb);
        vif.cb.plaintext_dv_in  <= 1;
        vif.cb.plaintext_in     <= tv.pt;
        vif.cb.key_dv_in        <= 1;
        vif.cb.key_in           <= tv.key;
        vif.cb.start_in         <= 1;

        @(vif.cb);
        vif.cb.plaintext_dv_in  <= 0;
        vif.cb.key_dv_in        <= 0;
        vif.cb.start_in         <= 0;

        // Wait for result
        while(vif.cb.core_dv_out == 1'b0) begin
            @(vif.cb);
            timeout_counter++;
            if (timeout_counter > 200) begin
                $error("[FAILED] Case %0d: TIMEOUT - No core_dv_out received!", id);
                failed_cases++;
                return; 
            end
        end

        if (vif.cb.data_out === tv.exp_ct) begin
            $display("[PASSED] Case %0d matched! \n   Act: %h\n   Exp: %h", id, vif.cb.data_out, tv.exp_ct);
            passed_cases++;
        end else begin
            $error("[FAILED] Case %0d mismatched! \n   Act: %h\n   Exp: %h", id, vif.cb.data_out, tv.exp_ct);
            failed_cases++;
        end
        
        vif.cb.done_in    <=    0;
        repeat(5) @(vif.cb);
    endtask

    //--------------------------------------
    // 5. Main Test Sequence
    //--------------------------------------
    initial begin
        $display("==================================================");
        $display("        TESTBENCH STARTING: AES128_core           ");
        $display("==================================================");

        initialize_input();

        foreach (test_cases[i]) begin
            run_test_case(i + 1, test_cases[i]);
        end

        $display("==================================================");
        $display("               TEST SUMMARY                       ");
        $display("==================================================");
        $display("Total Cases: %0d", passed_cases + failed_cases);
        $display("Passed     : %0d", passed_cases);
        $display("Failed     : %0d", failed_cases);
        if (failed_cases == 0)
            $display(">>> ALL TESTS PASSED SUCCESSFULLY! <<<");
        else
            $display(">>> SOME TESTS FAILED. PLEASE CHECK LOG. <<<");
        $display("==================================================");

        $finish;
    end

endmodule
