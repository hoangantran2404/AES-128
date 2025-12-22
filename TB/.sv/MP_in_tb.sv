//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2025 04:47:48 PM
// Design Name: 
// Module Name: MP_in_tb
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
interface MP_in_interface #(parameter DATA_WIDTH =32) (input bit clk);
    logic                       rst_n;
    logic [7:0]                 uart_byte_in;
    logic                       RX_DV_in, MP_dv_out;
    logic [DATA_WIDTH-1:0]      MP_plaintext_out, MP_key_out;
    
    clocking cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output uart_byte_in;
        output RX_DV_in;

        input MP_plaintext_out, MP_key_out, MP_dv_out;
    endclocking
endinterface
    //==========================================//
    //          Main Testbench Module           //
    //==========================================//
module MP_in_tb;
    timeunit      1ns;
    timeprecision 1ps;
    parameter DATA_WIDTH = 32;

    bit clk;
    logic [127:0] plaintext_in, key_in;
    logic [127:0] plaintext_result, key_result;

    MP_in_interface #(.DATA_WIDTH(DATA_WIDTH)) vif (clk);

    //==========================================//
    //            DUT INSTANTIATION             //
    //==========================================//
    MP_in #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut
    (
        .clk                (clk                ),
        .rst_n              (vif.rst_n          ),
        .uart_byte_in       (vif.uart_byte_in   ),
        .RX_DV_in           (vif.RX_DV_in       ),

        .MP_plaintext_out   (vif.MP_plaintext_out),
        .MP_key_out         (vif.MP_key_out     ),
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
        $display("TESTBENCH STARTING: AES128_MP_in        ");
        $display("========================================");

        plaintext_in = 128'h416476616E63656420456E6372797074;
        key_in       = 128'h5468617473204D79204B756E67204675;
        
        initialize_input();

        repeat(2) @(vif.cb);
        vif.cb.rst_n <= 1;

        $display("[Time %0t] Reset released.", $time);
        @(vif.cb);

        SEND_data();

        wait(vif.cb.MP_dv_out);
        @(vif.cb);

        RX_data();

        repeat(5) @(vif.cb);

        verification();
        $stop;
    end
    //==========================================//
    //            Task & Function               //
    //==========================================//
    task initialize_input();
        begin
            vif.cb.rst_n            <= 0;
            vif.cb.uart_byte_in     <= 0;
            vif.cb.RX_DV_in         <= 0;
            plaintext_result        <= 0;
            key_result              <= 0;
        end
    endtask

    task SEND_data();
        begin
            for(int i=0; i< 16; i++) begin
                vif.cb.RX_DV_in         <= 1'b1;
                vif.cb.uart_byte_in     <= plaintext_in[127-8*i -:8];
                @(vif.cb);
            end

            for(int i=0; i<16; i++) begin
                vif.cb.RX_DV_in         <= 1'b1;
                vif.cb.uart_byte_in     <= key_in[127-8*i -:8];
                @(vif.cb);
            end
        end
    endtask

    task RX_data();
        begin
            for(int i=0; i<4; i++) begin
                plaintext_result <= {plaintext_result[95:0], vif.cb.MP_plaintext_out};
                key_result       <= {key_result[95:0], vif.cb.MP_key_out};

                if(i<3)
                    @(vif.cb);
            end
        end
    endtask

    task automatic verification();
        begin
            $display("----------------------------------------");
            $display("RESULT CHECK:");
            $display("   Plaintext: %h", plaintext_result);
            $display("   Expected : %h", plaintext_in);
            $display("   KEY      : %h", key_result);
            $display("   Expected : %h", key_in);

            if (plaintext_result == plaintext_in && key_result == key_in ) begin
                $display("   STATUS  : [PASSED] Success!");
            end else begin
                $display("   STATUS  : [FAILED] Output mismatch!");
            end
            $display("========================================");
        $stop;
        end
    endtask

endmodule
