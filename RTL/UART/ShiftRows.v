`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 05:33:54 PM
// Design Name: 
// Module Name: ShiftRows
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
module ShiftRows #(
    parameter DATA_WIDTH =32
)
(
    input wire [DATA_WIDTH-1:0] in_sr0,
    input wire [DATA_WIDTH-1:0] in_sr1,
    input wire [DATA_WIDTH-1:0] in_sr2,
    input wire [DATA_WIDTH-1:0] in_sr3,

    output wire [DATA_WIDTH-1:0] out_sr0,
    output wire [DATA_WIDTH-1:0] out_sr1,
    output wire [DATA_WIDTH-1:0] out_sr2,
    output wire [DATA_WIDTH-1:0] out_sr3
);
    wire [7:0] s00 = in_sr0[31:24]; 
    wire [7:0] s01 = in_sr0[23:16]; 
    wire [7:0] s02 = in_sr0[15:8] ; 
    wire [7:0] s03 = in_sr0[7:0]  ; 

    wire [7:0] s10 = in_sr1[31:24]; 
    wire [7:0] s11 = in_sr1[23:16]; 
    wire [7:0] s12 = in_sr1[15:8] ; 
    wire [7:0] s13 = in_sr1[7:0]  ; 

    wire [7:0] s20 = in_sr2[31:24]; 
    wire [7:0] s21 = in_sr2[23:16]; 
    wire [7:0] s22 = in_sr2[15:8] ; 
    wire [7:0] s23 = in_sr2[7:0]  ; 

    wire [7:0] s30 = in_sr3[31:24]; 
    wire [7:0] s31 = in_sr3[23:16]; 
    wire [7:0] s32 = in_sr3[15:8] ; 
    wire [7:0] s33 = in_sr3[7:0]  ; 


    
    assign out_sr0 = {s00, s11, s22, s33};
    assign out_sr1 = {s10, s21, s32, s03};
    assign out_sr2 = {s20, s31, s02, s13};
    assign out_sr3 = {s30, s01, s12, s23};

endmodule
