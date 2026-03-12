
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2025 04:47:48 PM
// Design Name: 
// Module Name: cipher_tb
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
interface cipher_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                  rst_n;
    logic [2:0]            FSM_core_in;
    logic [3:0]            core_count_in;
    logic [DATA_WIDTH-1:0] text_0_in, text_1_in, text_2_in, text_3_in;
    logic [DATA_WIDTH-1:0] key_0_in, key_1_in, key_2_in, key_3_in;
    logic [DATA_WIDTH-1:0] text_0_out, text_1_out, text_2_out, text_3_out;
    logic                  cipher_dv_flag;
    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output FSM_core_in,core_count_in;
        output text_0_in, text_1_in, text_2_in, text_3_in;
        output key_0_in, key_1_in, key_2_in, key_3_in;
        input  text_0_out, text_1_out, text_2_out, text_3_out;
        input  cipher_dv_flag;
    endclocking
endinterface
    //==========================================//
    //          Main Testbench Module           //
    //==========================================//
module cipher_tb;
    timeunit      1ns;
    timeprecision 1ps;

    parameter DATA_WIDTH =32;
    
    bit clk;
    logic [DATA_WIDTH-1:0] KE_byte_in [44];
    logic [DATA_WIDTH-1:0] plaintext_in[4];
    logic [127:0]          expected_result;
    logic [127:0]          actual_result;

    cipher_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);
     //==========================================//
    //            DUT INSTANTIATION             //
    //==========================================//
    Cipher #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut
    (
        .clk                (clk                ),
        .rst_n              (vif.rst_n          ),
        .FSM_core_in        (vif.FSM_core_in    ),
        .core_count_in      (vif.core_count_in  ),
        
        .text_0_in          (vif.text_0_in      ),
        .text_1_in          (vif.text_1_in      ),
        .text_2_in          (vif.text_2_in      ),
        .text_3_in          (vif.text_3_in      ),

        .key_0_in           (vif.key_0_in       ),
        .key_1_in           (vif.key_1_in       ),
        .key_2_in           (vif.key_2_in       ),
        .key_3_in           (vif.key_3_in       ),

        .text_0_out         (vif.text_0_out     ),
        .text_1_out         (vif.text_1_out     ),
        .text_2_out         (vif.text_2_out     ),
        .text_3_out         (vif.text_3_out     ),
        .cipher_dv_flag     (vif.cipher_dv_flag )
    );

    assign actual_result = {vif.cb.text_0_out,vif.cb.text_1_out,vif.cb.text_2_out,vif.cb.text_3_out};
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
        $display("========================================");
        $display("TESTBENCH STARTING: AES128-cipher       ");
        $display("========================================");

        $readmemh("/home/hoangan2404/Project_0/FPGA/AO/AES128/project_1/project_1.srcs/sim_1/new/word.txt",KE_byte_in);
    
        plaintext_in[0] = 32'h41647661;
        plaintext_in[1] = 32'h6E636564; 
        plaintext_in[2] = 32'h20456E63; 
        plaintext_in[3] = 32'h72797074;

        expected_result = 128'h6f5ddb7f39560b0fe9eada49f87c4904;

        initialize_input();

        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;

        $display("[Time %0t] Reset released.", $time);
        
        @(vif.cb);
        vif.cb.FSM_core_in      <= 3'b001;
        vif.cb.core_count_in    <= 0;

        vif.cb.text_0_in <= plaintext_in[0];
        vif.cb.text_1_in <= plaintext_in[1];
        vif.cb.text_2_in <= plaintext_in[2];
        vif.cb.text_3_in <= plaintext_in[3];

        $display("[Time %0t] Loading Input Data...", $time);
        @(vif.cb);
        vif.cb.FSM_core_in      <= 3'b010;

        for(int i =0; i<=10 ; i++) begin
            vif.cb.key_0_in <= KE_byte_in[4*i + 0];
            vif.cb.key_1_in <= KE_byte_in[4*i + 1];
            vif.cb.key_2_in <= KE_byte_in[4*i + 2];
            vif.cb.key_3_in <= KE_byte_in[4*i + 3];

            vif.cb.core_count_in <= i;
            $display("[Time %0t] Processing Round %0d", $time, i);
            @(vif.cb);
        end

        vif.cb.FSM_core_in <= 3'b011;

        repeat(5) @(vif.cb);
        verfication();
        $stop;    
    end
    //==========================================//
    //            Task & Function               //
    //==========================================//
    task initialize_input();
        begin
            vif.cb.rst_n           <= 0;
            vif.cb.FSM_core_in     <= 0;
            vif.cb.core_count_in   <= 0;
            vif.cb.text_0_in       <= 0;
            vif.cb.text_1_in       <= 0;
            vif.cb.text_2_in       <= 0;
            vif.cb.text_3_in       <= 0;
            vif.cb.key_0_in        <= 0;
            vif.cb.key_1_in        <= 0;
            vif.cb.key_2_in        <= 0;
            vif.cb.key_3_in        <= 0;
        
        end
    endtask

    task automatic verfication();
        begin
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
        end
    endtask
endmodule
