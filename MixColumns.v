`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 06:15:27 PM
// Design Name: 
// Module Name: MixColumns
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


module MixColumns #(
    parameter DATA_WIDTH = 32
)
(
    input wire [DATA_WIDTH-1:0] in_mc0,
    input wire [DATA_WIDTH-1:0] in_mc1,
    input wire [DATA_WIDTH-1:0] in_mc2,
    input wire [DATA_WIDTH-1:0] in_mc3,

    output wire [DATA_WIDTH-1:0] out_mc0, //Accord to column
    output wire [DATA_WIDTH-1:0] out_mc1,
    output wire [DATA_WIDTH-1:0] out_mc2,
    output wire [DATA_WIDTH-1:0] out_mc3
);
    // State 0
    wire [7:0] s00 = in_mc0[31:24];
    wire [7:0] s01 = in_mc0[23:16];
    wire [7:0] s02 = in_mc0[15:8] ;
    wire [7:0] s03 = in_mc0[7:0]  ;

    // State 1
    wire [7:0] s10 = in_mc1[31:24];
    wire [7:0] s11 = in_mc1[23:16];
    wire [7:0] s12 = in_mc1[15:8] ;
    wire [7:0] s13 = in_mc1[7:0]  ;

    // State 2
    wire [7:0] s20 = in_mc2[31:24];
    wire [7:0] s21 = in_mc2[23:16];
    wire [7:0] s22 = in_mc2[15:8] ;
    wire [7:0] s23 = in_mc2[7:0]  ;

    // State 3
    wire [7:0] s30 = in_mc3[31:24];
    wire [7:0] s31 = in_mc3[23:16];
    wire [7:0] s32 = in_mc3[15:8] ;
    wire [7:0] s33 = in_mc3[7:0]  ;

    // Output 0
    wire [7:0] o00 ;
    wire [7:0] o01 ;
    wire [7:0] o02 ;
    wire [7:0] o03 ;

    Mult (.a(s00),.b(4'h02),.m(o00));
    Mult (.a(s01),.b(4'h01),.m(o01));
    Mult (.a(s02),.b(4'h01),.m(o02));
    Mult (.a(s03),.b(4'h03),.m(o03));

    assign out_mc0={o00, o01, o02, o03};
    // Output 1
    wire [7:0] o10 ;
    wire [7:0] o11 ;
    wire [7:0] o12 ;
    wire [7:0] o13 ;

    Mult (.a(s10),.b(4'h03),.m(o10));
    Mult (.a(s11),.b(4'h02),.m(o11));
    Mult (.a(s12),.b(4'h01),.m(o12));
    Mult (.a(s13),.b(4'h01),.m(o13));

    assign out_mc1={o10, o11, o12, o13};

    // Output 2
    wire [7:0] o20 = out_mc2[31:24];
    wire [7:0] o21 = out_mc2[23:16];
    wire [7:0] o22 = out_mc2[15:8] ;
    wire [7:0] o23 = out_mc2[7:0]  ;

    Mult (.a(s20),.b(4'h01),.m(o20));
    Mult (.a(s21),.b(4'h03),.m(o21));
    Mult (.a(s22),.b(4'h02),.m(o22));
    Mult (.a(s23),.b(4'h01),.m(o23));

    assign out_mc2={o20, o21, o22, o23};

    // Output 3
    wire [7:0] o30 ;
    wire [7:0] o31 ;
    wire [7:0] o32 ;
    wire [7:0] o33 ;

    Mult (.a(s30),.b(4'h01),.m(o30));
    Mult (.a(s31),.b(4'h01),.m(o31));
    Mult (.a(s32),.b(4'h03),.m(o32));
    Mult (.a(s33),.b(4'h02),.m(o33));

    assign out_mc3={o30, o31, o32, o33};

endmodule

module Mult(
    input wire [7:0] a,
    input wire [3:0] b,

    output wire [7:0] m
);
    reg [7:0] m_r;

    always@(a or b) begin
        m_r <= a*b;
    end

endmodule
