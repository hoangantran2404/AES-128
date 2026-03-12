`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 07:52:13 PM
// Design Name: 
// Module Name: RotWord
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


module RotWord #(
    parameter DATA_WIDTH = 8
)
(
    input wire [DATA_WIDTH -1 : 0] W0_in,
    input wire [DATA_WIDTH -1 : 0] W1_in,
    input wire [DATA_WIDTH -1 : 0] W2_in,
    input wire [DATA_WIDTH -1 : 0] W3_in,

    output wire [DATA_WIDTH -1 : 0] W0_out,
    output wire [DATA_WIDTH -1 : 0] W1_out,
    output wire [DATA_WIDTH -1 : 0] W2_out,
    output wire [DATA_WIDTH -1 : 0] W3_out
);
    assign W0_out = W1_in;
    assign W1_out = W2_in;
    assign W2_out = W3_in;
    assign W3_out = W0_in;
    
endmodule
