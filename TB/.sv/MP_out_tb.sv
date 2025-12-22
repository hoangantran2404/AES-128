//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2025 04:47:48 PM
// Design Name: 
// Module Name: MP_out_tb
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
interface MP_out_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                  rst_n;
    logic [DATA_WIDTH-1:0] core_byte_in;
    logic TX_active_in, TX_done_in, RX_DV_in;
    logic [7:0]            MP_data_out;
    logic                  MP_dv_out;

    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output core_byte_in, TX_active_in, TX_done_in, RX_DV_in;
        input  MP_data_out, MP_dv_out; 
    endclocking
endinterface
    //==========================================//
    //          Main Testbench Module           //
    //==========================================//
module MP_out_tb;
    timeunit      1ns;
    timeprecision 1ps;

    parameter DATA_WIDTH = 32;

    bit clk;
    logic [127:0] expected_result;
    logic [127:0] actual_result;

    MP_out_interface #(.DATA_WIDTH(DATA_WIDTH)) vif(clk);
    //==========================================//
    //            DUT INSTANTIATION             //
    //==========================================//
    MP_out #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut
    (
        .clk                (clk                ),
        .rst_n              (vif.rst_n          ),
        .core_byte_in       (vif.core_byte_in   ),
        .TX_active_in       (vif.TX_active_in   ),
        .TX_done_in         (vif.TX_done_in     ),
        .RX_DV_in           (vif.RX_DV_in       ),

        .MP_data_out        (vif.MP_data_out    ),
        .MP_dv_out          (vif.MP_dv_out      )
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
        $display("TESTBENCH STARTING: AES128_MP_out       ");
        $display("========================================");

        expected_result = 128'h6f5ddb7f39560b0fe9eada49f87c4904;

        initialize_input();

        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;
        $display("[Time %0t] Reset released.", $time);

        @(vif.cb);
        vif.cb.RX_DV_in <= 1;

        SEND_data();

        vif.cb.RX_DV_in <= 0;

        repeat(5) @(vif.cb);
        $display("[Time %0t] Waiting for Output...", $time);

        RX_data();
        
        verification();
        $stop;
    end
    //==========================================//
    //            Task & Function               //
    //==========================================//
    task initialize_input();
        begin
            vif.cb.rst_n        <= 0;
            vif.cb.core_byte_in <= 0;
            vif.cb.TX_active_in <= 0;
            vif.cb.TX_done_in   <= 0;
            vif.cb.RX_DV_in     <= 0;
        end
    endtask
    task SEND_data();
        begin 
            for(int i=0; i<4; i++) begin
                vif.cb.core_byte_in <= expected_result[127-32*i -:32];
                @(vif.cb);
            end
        end
    endtask
    task RX_data();
        begin
            for(int i=0; i<16; i++) begin
                while (vif.cb.MP_dv_out == 0) begin
                    @(vif.cb);
                end

                actual_result[127 - 8*i -: 8] = vif.cb.MP_data_out;
                
                vif.cb.TX_active_in <= 1;
                repeat(4) @(vif.cb);
                vif.cb.TX_done_in   <= 1;
                @(vif.cb);
                
                vif.cb.TX_done_in   <= 0;
                vif.cb.TX_active_in <= 0; 
                
                @(vif.cb); 
            end
        end
    endtask
    task automatic verification();
        begin
            $display("========================================");
            if (actual_result == expected_result) begin
                $display(" TEST PASSED! ");
                $display(" Expected: %h", expected_result);
                $display(" Actual  : %h", actual_result);
            end else begin
                $display(" TEST FAILED! ");
                $display(" Expected: %h", expected_result);
                $display(" Actual  : %h", actual_result);
            end
        $display("========================================");
        end
    endtask

endmodule
