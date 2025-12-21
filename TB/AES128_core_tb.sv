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
// ==========================================//
//            Interface Definition           //
// ==========================================//
interface aes_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                   rst_n;
    logic                   MP_dv_in;
    logic [DATA_WIDTH-1:0]  plaintext_in;
    logic [DATA_WIDTH-1:0]  key_in;
    logic [DATA_WIDTH-1:0]  plaintext_out;
    logic                   core_dv_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output MP_dv_in, plaintext_in, key_in;
        input plaintext_out, core_dv_out;
    endclocking
endinterface
// ==========================================//
//           Main Testbench Module           //
// ==========================================//
module  AES128_core_tb;
    timeunit      1ns;
    timeprecision 1ps;

    parameter DATA_WIDTH =32;

    bit clk;
    logic [DATA_WIDTH-1:0] test_plaintext [4];//0->3
    logic [DATA_WIDTH-1:0] test_key       [4];
    logic [127:0]          expected_result;
    logic [127:0]          actual_result;

    aes_interface #(.DATA_WIDTH(DATA_WIDTH)) vif(clk);// Virtual Interface
    
// ==========================================//
//             DUT INSTANTIATION             //
// ==========================================//
   AES128_core #(
        .DATA_WIDTH(DATA_WIDTH)
   ) dut
   (
        .clk          (clk              ),
        .rst_n        (vif.rst_n        ),
        .plaintext_in (vif.plaintext_in ),
        .key_in       (vif.key_in       ),
        .MP_dv_in     (vif.MP_dv_in     ),

        .data_out     (vif.plaintext_out),
        .core_dv_out  (vif.core_dv_out  )
   );  
// ==========================================//
//             CLOCK Generation             //
// ==========================================//
initial begin
    clk = 0;
    forever #5 clk =~clk;
end

// ==========================================//
//             Main Test Sequence            //
// ==========================================// 
initial begin
    test_plaintext  = '{32'h41647661, 32'h6E636564, 32'h20456E63, 32'h72797074};
    test_key        = '{32'h54686174, 32'h73204D79, 32'h204B756E, 32'h67204675};
    expected_result = 128'h6f5ddb7f39560b0fe9eada49f87c4904;

    initialize_input();
    
    $display("========================================");
    $display("SV TESTBENCH STARTING: AES128_core      ");
    $display("========================================");

    repeat(2) @(vif.cb);
    vif.cb.rst_n <= 1;
    $display("[Time %0t] Reset released.", $time);

    @(vif.cb);
    vif.cb.MP_dv_in <= 1;

    foreach(test_plaintext[i]) begin
        vif.cb.plaintext_in <= test_plaintext[i];
        vif.cb.key_in       <= test_key[i];
        @(vif.cb);
    end

    vif.cb.MP_dv_in <= 0;

    wait(vif.cb.core_dv_out);
    
    for(int i=0; i<4; i++) begin
        actual_result = {actual_result[95:0], vif.cb.plaintext_out};
        if(i<3)
            @(vif.cb);
    end

    repeat(5) @(vif.cb);

    verification();
    $stop;
end

task initialize_input ();
    begin
        vif.cb.rst_n           <= 0;
        vif.cb.MP_dv_in        <= 0;
        vif.cb.plaintext_in    <= 0;
        vif.cb.key_in          <= 0;
    end
endtask
task automatic verification();
    begin
        $display("----------------------------------------");
        $display("RESULT CHECK:");
        $display("   Expected: %h", expected_result);
        $display("   Actual  : %h", actual_result);
        
        assert (actual_result == expected_result)  // Instead of using if
            $display("   STATUS  : [PASSED] Success!");
        else 
            $error("   STATUS  : [FAILED] Output mismatch!");
            
        $display("========================================");
    end
endtask

endmodule