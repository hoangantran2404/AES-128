`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 06:48:28 PM
// Design Name: 
// Module Name: SubBytes
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


module SubBytes #(
    parameter DATA_WIDTH =32
)
(
    input wire [DATA_WIDTH-1:0] i_s0,
    input wire [DATA_WIDTH-1:0] i_s1,
    input wire [DATA_WIDTH-1:0] i_s2,
    input wire [DATA_WIDTH-1:0] i_s3,

    output wire [DATA_WIDTH-1:0] o_out0,
    output wire [DATA_WIDTH-1:0] o_out1,
    output wire [DATA_WIDTH-1:0] o_out2,
    output wire [DATA_WIDTH-1:0] o_out3
);
    SubWord SW0(
             .i_S0(i_s0  [7:0]), 
             .i_S1(i_s0  [15:8]),
             .i_S2(i_s0  [23:16]),
             .i_S3(i_s0  [31:24]), 
             .o_D0(o_out0[7:0]),
             .o_D1(o_out0[15:8]),
             .o_D2(o_out0[23:16]),
             .o_D3(o_out0[31:24])
            );
    SubWord SW1(
             .i_S0(i_s1  [7:0]), 
             .i_S1(i_s1  [15:8]),
             .i_S2(i_s1  [23:16]),
             .i_S3(i_s1  [31:24]), 
             .o_D0(o_out1[7:0]),
             .o_D1(o_out1[15:8]),
             .o_D2(o_out1[23:16]),
             .o_D3(o_out1[31:24])
    );
    SubWord SW2(
             .i_S0(i_s2  [7:0]), 
             .i_S1(i_s2  [15:8]),
             .i_S2(i_s2  [23:16]),
             .i_S3(i_s2  [31:24]), 
             .o_D0(o_out2[7:0]),
             .o_D1(o_out2[15:8]),
             .o_D2(o_out2[23:16]),
             .o_D3(o_out2[31:24])
    );
    SubWord SW3(
             .i_S0(i_s3  [7:0]), 
             .i_S1(i_s3  [15:8]),
             .i_S2(i_s3  [23:16]),
             .i_S3(i_s3  [31:24]), 
             .o_D0(o_out3[7:0]),
             .o_D1(o_out3[15:8]),
             .o_D2(o_out3[23:16]),
             .o_D3(o_out3[31:24])
    );

endmodule
