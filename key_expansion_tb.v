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

module key_expansion_tb();

    // ==========================================
    // 1. Parameters & Signals
    // ==========================================
    parameter DATA_WIDTH = 32;

    reg                   clk;
    reg                   rst_n;
    
    reg [2:0]             FSM_core_in;   
    reg [3:0]             core_count_in;
    
    reg [DATA_WIDTH -1:0] data_in_0;
    reg [DATA_WIDTH -1:0] data_in_1;
    reg [DATA_WIDTH -1:0] data_in_2;
    reg [DATA_WIDTH -1:0] data_in_3;

    wire [DATA_WIDTH -1:0] data_out_0;
    wire [DATA_WIDTH -1:0] data_out_1;
    wire [DATA_WIDTH -1:0] data_out_2;
    wire [DATA_WIDTH -1:0] data_out_3;

    reg [DATA_WIDTH -1:0]  KE_byte_in [0:3];
    
    integer i;

    // ==========================================
    // 2. DUT Instantiation
    // ==========================================
    Key_Expansion #(
        .DATA_WIDTH(DATA_WIDTH)
    ) module_Key_Expansion (
        .clk            (clk),
        .rst_n          (rst_n),
        .FSM_core_in    (FSM_core_in),
        .core_count_in  (core_count_in),
        .data_in_0      (data_in_0),
        .data_in_1      (data_in_1),
        .data_in_2      (data_in_2),
        .data_in_3      (data_in_3),

        .data_out_0     (data_out_0),
        .data_out_1     (data_out_1),
        .data_out_2     (data_out_2),
        .data_out_3     (data_out_3)
    );

    // ==========================================
    // 3. Clock Generation
    // ==========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ==========================================
    // 4. Main Test Sequence 
    // ==========================================
    initial begin
        $display("========================================");
        $display("TESTBENCH STARTING: AES128-Key_Expansion (Posedge Mode)");
        $display("========================================");

        KE_byte_in[0] = 32'h54686174;
        KE_byte_in[1] = 32'h73204D79;
        KE_byte_in[2] = 32'h204B756E;
        KE_byte_in[3] = 32'h67204675;


        initialize_inputs();
        rst_n <= 0;        
        @(posedge clk);    
        rst_n <= 1;        

        $display("[Time %0t] Reset released.", $time);

  
        @(posedge clk);
        FSM_core_in   <= 3'b001; 
        core_count_in <= 0;
        data_in_0     <= KE_byte_in[0];
        data_in_1     <= KE_byte_in[1];
        data_in_2     <= KE_byte_in[2];
        data_in_3     <= KE_byte_in[3];
        
        $display("[Time %0t] Loading Input Data...", $time);

        @(posedge clk);
        FSM_core_in   <= 3'b010; 

        for (i = 0; i <= 10; i = i + 1) begin
            
          
            if (i < 10) begin
                core_count_in <= (i + 1); 
            end

            #1; 
            
            $display("Round %0d (Time %0t):", i, $time);
            $display("   Key_0: %h", data_out_0);
            $display("   Key_1: %h", data_out_1);
            $display("   Key_2: %h", data_out_2);
            $display("   Key_3: %h", data_out_3);

            if (i < 10) begin 
                @(posedge clk);
            end
        end
        
        $display("TEST DONE");
        $stop;
    end


    task initialize_inputs;
        begin
            rst_n         <= 0;
            FSM_core_in   <= 0;
            core_count_in <= 0;
            data_in_0     <= 0;
            data_in_1     <= 0;
            data_in_2     <= 0;
            data_in_3     <= 0;
        end
    endtask

endmodule
