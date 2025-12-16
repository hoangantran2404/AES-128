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

    output wire [DATA_WIDTH-1:0] out_mc0, 
    output wire [DATA_WIDTH-1:0] out_mc1,
    output wire [DATA_WIDTH-1:0] out_mc2,
    output wire [DATA_WIDTH-1:0] out_mc3
);
    Matrix_Multiplication MM0(.data_in(in_mc0),.data_out(out_mc0));
    Matrix_Multiplication MM1(.data_in(in_mc1),.data_out(out_mc1));
    Matrix_Multiplication MM2(.data_in(in_mc2),.data_out(out_mc2));
    Matrix_Multiplication MM3(.data_in(in_mc3),.data_out(out_mc3));

endmodule

module Matrix_Multiplication #(
    parameter DATA_WIDTH =32
)
(
    input wire  [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out
);
    wire [7:0] s0 = data_in[31:24];
    wire [7:0] s1 = data_in[23:16];
    wire [7:0] s2 = data_in[15:8];
    wire [7:0] s3 = data_in[7:0];

    wire [7:0] s0x2, s0x3;
    wire [7:0] s1x2, s1x3;
    wire [7:0] s2x2, s2x3;
    wire [7:0] s3x2, s3x3;

    GFMult m0x2(.a(s0),.b(4'd2),.p(s0x2));
    GFMult m0x3(.a(s0),.b(4'd3),.p(s0x3));

    GFMult m1x2(.a(s1),.b(4'd2),.p(s1x2));
    GFMult m1x3(.a(s1),.b(4'd3),.p(s1x3));

    GFMult m2x2(.a(s2),.b(4'd2),.p(s2x2));
    GFMult m2x3(.a(s2),.b(4'd3),.p(s2x3));

    GFMult m3x2(.a(s3),.b(4'd2),.p(s3x2));
    GFMult m3x3(.a(s3),.b(4'd3),.p(s3x3));

    wire [7:0] d0 = s0x2 ^ s1x3 ^ s2   ^ s3     ;
    wire [7:0] d1 = s0   ^ s1x2 ^ s2x3 ^ s3     ;
    wire [7:0] d2 = s0   ^ s1   ^ s2x2 ^ s3x3   ;
    wire [7:0] d3 = s0x3 ^ s1   ^ s2   ^ s3x2   ;

    assign data_out = {d0,d1,d2,d3};
endmodule

module GFMult(
    input wire [7:0] a,
    input wire [3:0] b,

    output reg [7:0] p
);
    reg [7:0] temp_a;

    always @(a or b) begin 
        temp_a     = a;
        p          = 0;

        if(b[0]) begin
            p = p ^ temp_a;
        end
        
        temp_a = (temp_a << 1) ^ ( (temp_a & 8'h80) ? 8'h1B : 8'h00);

        if(b[1]) begin
            p = p ^ temp_a;
        end

        temp_a = (temp_a << 1) ^ ( (temp_a & 8'h80) ? 8'h1B : 8'h00);

        if (b[2]) begin
            p = p ^ temp_a;
        end

        temp_a = (temp_a << 1) ^ ( (temp_a & 8'h80) ? 8'h1B : 8'h00);

        if (b[3]) 
            p = p ^ temp_a;
    end

endmodule
