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

    GFMult (.a(s00),.b(4'h02),.p(o00));
    GFMult (.a(s01),.b(4'h01),.p(o01));
    GFMult (.a(s02),.b(4'h01),.p(o02));
    GFMult (.a(s03),.b(4'h03),.p(o03));

    assign out_mc0={o00, o01, o02, o03};
    // Output 1
    wire [7:0] o10 ;
    wire [7:0] o11 ;
    wire [7:0] o12 ;
    wire [7:0] o13 ;

    GFMult (.a(s10),.b(4'h03),.p(o10));
    GFMult (.a(s11),.b(4'h02),.p(o11));
    GFMult (.a(s12),.b(4'h01),.p(o12));
    GFMult (.a(s13),.b(4'h01),.p(o13));

    assign out_mc1={o10, o11, o12, o13};

    // Output 2
    wire [7:0] o20 = out_mc2[31:24];
    wire [7:0] o21 = out_mc2[23:16];
    wire [7:0] o22 = out_mc2[15:8] ;
    wire [7:0] o23 = out_mc2[7:0]  ;

    GFMult (.a(s20),.b(4'h01),.p(o20));
    GFMult (.a(s21),.b(4'h03),.p(o21));
    GFMult (.a(s22),.b(4'h02),.p(o22));
    GFMult (.a(s23),.b(4'h01),.p(o23));

    assign out_mc2={o20, o21, o22, o23};

    // Output 3
    wire [7:0] o30 ;
    wire [7:0] o31 ;
    wire [7:0] o32 ;
    wire [7:0] o33 ;

    GFMult (.a(s30),.b(4'h01),.p(o30));
    GFMult (.a(s31),.b(4'h01),.p(o31));
    GFMult (.a(s32),.b(4'h03),.p(o32));
    GFMult (.a(s33),.b(4'h02),.p(o33));

    assign out_mc3={o30, o31, o32, o33};

endmodule

module GFMult(
    input wire [7:0] a,
    input wire [3:0] b,

    output reg [7:0] p
);
// This is Galois Field Multiplication (GF) 
// You can search for the operating rules on Gen AI. 
// Constants: 8'h1B (0001 1011) is AES reduction modulo. x8 = x4 + x3 + x + 1
//            8'h80 (1000 0000) is MSB of a.
    reg [7:0] temp_a;

    always @(a or b) begin
        temp_a     <= a;
        p          <= 0;

        if(b[0]) begin
            p      <= p ^ temp_a;
            temp_a <= (temp_a << 1) ^ ( (temp_a & 8'h80) ? 8'h1B : 8'h00);
        end
        if(b[1]) begin
            p      <= p ^ temp_a;
            temp_a <= (temp_a << 1) ^ ( (temp_a & 8'h80) ? 8'h1B : 8'h00);
        end
        if (b[2])
            p      <= p ^ temp_a;
            temp_a <= (temp_a << 1) ^ ( (temp_a & 8'h80) ? 8'h1B : 8'h00);

        if (b[3]) 
            p      <= p ^ temp_a;
    end

endmodule
