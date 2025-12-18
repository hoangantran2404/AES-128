`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 06:25:37 PM
// Design Name: 
// Module Name: AddRoundKey
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


module AddRoundKey #(
    parameter DATA_WIDTH=32
)
(
    input wire [DATA_WIDTH-1:0] i_state0,
    input wire [DATA_WIDTH-1:0] i_state1,
    input wire [DATA_WIDTH-1:0] i_state2,
    input wire [DATA_WIDTH-1:0] i_state3,
    input wire [DATA_WIDTH-1:0] i_key0,
    input wire [DATA_WIDTH-1:0] i_key1,
    input wire [DATA_WIDTH-1:0] i_key2,
    input wire [DATA_WIDTH-1:0] i_key3,

    output wire [DATA_WIDTH-1:0] dout0,
    output wire [DATA_WIDTH-1:0] dout1,
    output wire [DATA_WIDTH-1:0] dout2,
    output wire [DATA_WIDTH-1:0] dout3
);
    assign dout0 = i_state0 ^ i_key0;
    assign dout1 = i_state1 ^ i_key1;
    assign dout2 = i_state2 ^ i_key2;
    assign dout3 = i_state3 ^ i_key3;

endmodule
