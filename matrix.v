`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 04:44:13 PM
// Design Name: 
// Module Name: matrix
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


module round #(
    parameter DATA_WIDTH =128
)
(
    input wire clk, rst_n, start_in,
    input wire [DATA_WIDTH-1:0] state_in,
    input wire [DATA_WIDTH-1:0] key_in,
    
    output wire [DATA_WIDTH-1:0] data_out


);
    reg [7:0] state_r [0:3][0:3]; // [rs][columns]
    reg [7:0] key_r   [0:3][0:3];
    integer r,c;

    parameter IDLE    = 2'b00;
    parameter LOAD    = 2'b01;
    parameter EXECUTE = 2'b10;
    parameter DONE    = 2'b11;



    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(r = 0; r < 4; r = r+1 ) begin
                for(c = 0; c < 4; c = c+1) begin
                    state_r[r][c] <= 8'd0;
                    key_r  [r][c] <= 8'd0;
                end
            end
        end else if (start_in) begin
            for (r = 2'd0; r < 2'd4 ; r = r +2'd1) begin
                for(c = 0; c < 4; c = c+1) begin
                    state_r[r][c] <= state_in[127 - 8*(4*r + c) -: 8];// byte index = 4*r + c 
                    key_r  [r][c] <= key_in  [127 - 8*(4*r + c) -: 8]; 
                end

            end
        end
    end



endmodule
