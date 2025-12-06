`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2025 09:15:37 PM
// Design Name: 
// Module Name: RoundConst
// Project Name: AES 128
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


module RoundConst(
    input wire [3:0]  Round_const_in,
    input wire [7:0]  Rcon0_in,
    input wire [7:0]  Rcon1_in,
    input wire [7:0]  Rcon2_in,
    input wire [7:0]  Rcon3_in,

    output reg [31:0] Round_const_out
    );
     //==================================================//
    //                   Registers                      //
    //==================================================//
    reg [7:0] byte_index_r;
    wire [7:0] Rcon0_w, Rcon1_w, Rcon2_w, Rcon3_w;

    always @(*) begin
        case (Round_const_in)
            4'd1:  byte_index_r = 8'h01;
            4'd2:  byte_index_r = 8'h02;
            4'd3:  byte_index_r = 8'h04;
            4'd4:  byte_index_r = 8'h08;
            4'd5:  byte_index_r = 8'h10;
            4'd6:  byte_index_r = 8'h20;
            4'd7:  byte_index_r = 8'h40;
            4'd8:  byte_index_r = 8'h80;
            4'd9:  byte_index_r = 8'h1B;
            4'd10: byte_index_r = 8'h36;
            default: byte_index_r = 8'h00;
        endcase
    end
    assign Rcon0_w = byte_index_r ^ Rcon1_in;
    assign Rcon1_w = Rcon1_in;
    assign Rcon2_w = Rcon2_in;
    assign Rcon3_w = Rcon3_in;

    assign Round_const_out = {Rcon0_w, Rcon1_w, Rcon2_w, Rcon3_w};
endmodule
