`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 11:19:11 PM
// Design Name: 
// Module Name: KE
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


module KE#(
    parameter DATA_WIDTH =32
)
(
    input wire clk, rst_n,
    input wire dv_in,
    input wire data_in_0,
    input wire data_in_1,
    input wire data_in_2,
    input wire data_in_3

    output wire data_out_0,
    output wire data_out_1,
    output wire data_out_2,
    output wire data_out_3
);
// Register and wire
reg [3:0] core_count_r;

wire      ROUND1to9_flag_w ;
// State Encoding
reg [2:0] current_state_r;
reg [2:0] next_state_r   ;

parameter s_IDLE      = 3'b000;
parameter s_ROUND0    = 3'b001;
parameter s_ROUND1to9 = 3'b010;
parameter s_ROUND10   = 3'b011;
parameter s_SEND      = 3'b100;
parameter s_CLEANUP   = 3'b101;
// Combinational Logic

assign ROUND1to9_flag_w = (current_state_r == s_ROUND1to9 && core_count_r == 4'd9)




// State Register
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        current_state_r <= s_IDLE;
    else
        current_state_r <= next_state_r;
end
// Next State Logic 
always @(dv_in or current_state_r or ROUND1to9_flag_w) begin
    case(current_state_r)
        s_IDLE: 
            if(dv_in) 
                next_state_r <= s_ROUND0;
            else 
                next_state_r <= s_IDLE;
        s_ROUND0:
            next_state_r <= s_ROUND1to9;
        s_ROUND1to9:
            if(ROUND1to9_flag_w) 
                next_state_r <= s_ROUND10;
            else
                next_state_r <= s_ROUND1to9;
        s_ROUND10:
                next_state_r <= s_CLEANUP;
        s_CLEANUP:
                next_state_r <= s_IDLE;
        default: next_state_r <= s_IDLE;       
    endcase
end

// Datapath
integer i;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        core_count_r <= 0;
        
end
endmodule
