//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2025 04:47:48 PM
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
    //==========================================//
    //           Interface Definition           //
    //==========================================//
interface key_expansion_interface #(parameter DATA_WIDTH = 32) (input bit clk);
    logic                  rst_n;
    logic [2:0]            FSM_core_in;
    logic [3:0]            core_count_in;

    logic [DATA_WIDTH-1:0] data_in_0;
    logic [DATA_WIDTH-1:0] data_in_1;
    logic [DATA_WIDTH-1:0] data_in_2;
    logic [DATA_WIDTH-1:0] data_in_3;

    logic [DATA_WIDTH-1:0] data_out_0;
    logic [DATA_WIDTH-1:0] data_out_1;
    logic [DATA_WIDTH-1:0] data_out_2;
    logic [DATA_WIDTH-1:0] data_out_3;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output FSM_core_in, core_count_in;
        output data_in_0, data_in_1, data_in_2, data_in_3;
        input  data_out_0, data_out_1,data_out_2, data_out_3;
    endclocking
endinterface
    //==========================================//
    //          Main Testbench Module           //
    //==========================================//
module key_expansion_tb;
    timeunit      1ns;
    timeprecision 1ps;

    parameter DATA_WIDTH = 32;

    bit clk;
    logic [DATA_WIDTH-1:0] KE_byte_in [4];


    key_expansion_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);
    //==========================================//
    //            DUT INSTANTIATION             //
    //==========================================//
    Key_Expansion #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut
    (
        .clk                    (clk                ),
        .rst_n                  (vif.rst_n          ),
        .FSM_core_in            (vif.FSM_core_in    ),
        .core_count_in          (vif.core_count_in  ),
        .data_in_0              (vif.data_in_0      ),
        .data_in_1              (vif.data_in_1      ),
        .data_in_2              (vif.data_in_2      ),
        .data_in_3              (vif.data_in_3      ),

        .data_out_0             (vif.data_out_0     ),
        .data_out_1             (vif.data_out_1     ),
        .data_out_2             (vif.data_out_2     ),
        .data_out_3             (vif.data_out_3     )
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
        $display("========================================");
        $display("TESTBENCH STARTING: AES128-Key_Expansion");
        $display("========================================");
        
        KE_byte_in[0] = 32'h54686174;
        KE_byte_in[1] = 32'h73204D79;
        KE_byte_in[2] = 32'h204B756E;
        KE_byte_in[3] = 32'h67204675;

        initialize_input();
        
        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;

        $display("[Time %0t] Reset released.", $time);

        @(vif.cb);
        vif.cb.FSM_core_in      <= 3'b001;
        vif.cb.core_count_in    <= 0;

        vif.cb.data_in_0        <= KE_byte_in[0];
        vif.cb.data_in_1        <= KE_byte_in[1];
        vif.cb.data_in_2        <= KE_byte_in[2];
        vif.cb.data_in_3        <= KE_byte_in[3];

        $display("[Time %0t] Loading Input Data...", $time);

        @(vif.cb);
        vif.cb.FSM_core_in      <= 3'b010;
        
        repeat(2) @(vif.cb);
        for(int i=0; i<=10; i++ ) begin
            if (i < 10) begin
                vif.cb.core_count_in <= (i + 1); 
            end

            #1;
            
            $display("Round %0d (Time %0t):", i, $time);
            $display("   Key_0: %h", vif.cb.data_out_0);
            $display("   Key_1: %h", vif.cb.data_out_1);
            $display("   Key_2: %h", vif.cb.data_out_2);
            $display("   Key_3: %h", vif.cb.data_out_3);

            if (i < 10) begin 
                @(vif.cb);
            end
        end

        repeat(5) @(vif.cb);
        $stop;
    end
    //==========================================//
    //            Task & Function               //
    //==========================================//
    task initialize_input();
        begin
            vif.cb.rst_n        <= 0;
            vif.cb.FSM_core_in  <= 0;
            vif.core_count_in   <= 0;
            vif.data_in_0       <= 0;
            vif.data_in_1       <= 0;
            vif.data_in_2       <= 0;
            vif.data_in_3       <= 0;
        end
    endtask 

endmodule
