`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang AN
//           ngotranhoangan2007@gmail.com
// Create Date: 12/01/2025 11:19:11 PM
// Design Name: 
// Module Name: AES128_core
// Project Name: AES128
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
module AES128_core #(
    parameter DATA_WIDTH =32
)
(
    input wire                         clk, rst_n,
    input wire [31:0]                  plaintext_in,
    input wire [31:0]                  key_in,
    input wire                         MP_dv_in,

    output wire [31:0]                 data_out,
    output wire                        core_dv_out
);
    //==================================================//
    //               Internal Signals                   //
    //==================================================//
    reg [127:0]                    address_key_r;
    reg [127:0]                    address_text_r;
    reg [127:0]                    address_r;           
    reg [3:0]                      core_count_r;

    wire                           load_done_flag_w;
    wire                           exec_done_flag_w;
    wire                           send_done_flag_w;  
    wire                           cipher_dv_out_w;

    wire [127:0]                   KE_byte_out_w; 
    wire [127:0]                   cipher_byte_out_w;    
    //==================================================//
    //                State Encoding                    //
    //==================================================//
    localparam s_IDLE           = 3'b000;
    localparam s_LOAD           = 3'b001;
    localparam s_EXECUTE        = 3'b010;
    localparam s_RX_data        = 3'b011;
    localparam s_SEND           = 3'b100;
    localparam s_CLEANUP        = 3'b101;

    reg [2:0] current_state_r   = s_IDLE;
    reg [2:0] next_state_r;
    //==================================================//
    //               Combinational Logic                //
    //==================================================//
    assign core_dv_out      = (current_state_r == s_SEND);

    assign load_done_flag_w = (current_state_r == s_LOAD    && core_count_r == 4'd4);
    assign exec_done_flag_w = (current_state_r == s_EXECUTE && core_count_r == 4'd11);
    assign send_done_flag_w = (current_state_r == s_SEND    && core_count_r == 4'd4);

    assign data_out         = (current_state_r == s_SEND) ? address_r[127 - 32*core_count_r -:32] : 32'd0;

    //==================================================//
    //                Instantiate module                //
    //==================================================//
    Key_Expansion #(
        .DATA_WIDTH(DATA_WIDTH)
    ) module_Key_Expansion
    (
        .clk            (clk                        ),
        .rst_n          (rst_n                      ),
        .FSM_core_in    (current_state_r            ),
        .core_count_in  (core_count_r               ),
        .data_in_0      (address_key_r[127:96]      ),
        .data_in_1      (address_key_r[95:64]       ),
        .data_in_2      (address_key_r[63:32]       ),
        .data_in_3      (address_key_r[31:0]        ),

        .data_out_0     (KE_byte_out_w[127:96]      ),
        .data_out_1     (KE_byte_out_w[95:64]       ),
        .data_out_2     (KE_byte_out_w[63:32]       ),
        .data_out_3     (KE_byte_out_w[31:0]        )
    );

    Cipher #(
        .DATA_WIDTH(DATA_WIDTH)
    ) module_Cipher
    (
        .clk            (clk                        ),
        .rst_n          (rst_n                      ),
        .FSM_core_in    (current_state_r            ),
        .core_count_in  (core_count_r               ),

        .text_0_in      (address_text_r[127:96]     ),
        .text_1_in      (address_text_r[95:64]      ),
        .text_2_in      (address_text_r[63:32]      ),
        .text_3_in      (address_text_r[31:0]       ),

        .key_0_in       (address_key_r[127:96]      ),
        .key_1_in       (address_key_r[95:64]       ),
        .key_2_in       (address_key_r[63:32]       ),
        .key_3_in       (address_key_r[31:0]        ),

        .text_0_out     (cipher_byte_out_w[127:96]  ),
        .text_1_out     (cipher_byte_out_w[95:64]   ),                       
        .text_2_out     (cipher_byte_out_w[63:32]   ),                   
        .text_3_out     (cipher_byte_out_w[31:0]    ),                 
        .cipher_dv_flag (cipher_dv_out_w            )
    );

    //==================================================//
    //                  Next State LogicS               //
    //==================================================//
    always @(MP_dv_in or load_done_flag_w or exec_done_flag_w or send_done_flag_w or current_state_r or cipher_dv_out_w) begin
        case(current_state_r)
            s_IDLE: 
                if(MP_dv_in == 1'b1)
                    next_state_r = s_LOAD;
                else 
                    next_state_r = s_IDLE;
            s_LOAD:
                if(load_done_flag_w)
                    next_state_r = s_EXECUTE;
                else
                    next_state_r = s_LOAD;
            s_EXECUTE:
                if(exec_done_flag_w)
                    next_state_r = s_RX_data;
                else
                    next_state_r = s_EXECUTE;
            s_RX_data:
                if(cipher_dv_out_w)
                    next_state_r = s_SEND;
                else
                    next_state_r = s_RX_data;
            s_SEND:
                if(send_done_flag_w)
                    next_state_r = s_CLEANUP;
                else
                    next_state_r = s_SEND;
            s_CLEANUP:
                next_state_r = s_IDLE;

            default: 
                next_state_r = s_IDLE;
        endcase
    end
    //==================================================//
    //              State Register (FSM)                //
    //==================================================//
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            current_state_r <= s_IDLE;
        else
            current_state_r <= next_state_r;
    end
    //==================================================//
    //                     Datapath                     //
    //==================================================//
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            address_key_r   <= 128'd0;
            address_text_r  <= 128'd0;
            address_r       <= 128'd0;
            core_count_r    <= 4'd0;
        end else begin
            if(current_state_r != next_state_r) begin
                core_count_r <= 0;

                if(current_state_r == s_IDLE && next_state_r == s_LOAD) begin
                    address_key_r[127 -:32]     <= key_in;
                    address_text_r[127 -:32]    <= plaintext_in;
                    core_count_r                <= 4'd1;
                end
            end else begin
                case(current_state_r)
                    s_IDLE: begin
                        if(MP_dv_in) begin
                            address_key_r [127 -:32]  <= key_in;
                            address_text_r[127 -:32]  <= plaintext_in;
                            core_count_r              <=  4'd1;
                        end
                    end
                    s_LOAD: begin
                        if(MP_dv_in) begin
                            address_text_r[127 - 32*core_count_r -:32]  <= plaintext_in;
                            address_key_r [127 - 32*core_count_r -:32]  <= key_in;
                            core_count_r                                <=  core_count_r + 4'd1;
                        end
                    end
                    s_EXECUTE: begin
                            address_key_r   <= KE_byte_out_w;     
                            core_count_r    <= core_count_r + 4'd1; 
                    end
                    s_RX_data: begin
                       if(cipher_dv_out_w) begin
                            address_r               <= cipher_byte_out_w;
                       end
                    end
                    s_SEND: begin
                            core_count_r           <= core_count_r + 4'd1;
                    end
                    s_CLEANUP: begin
                            core_count_r           <= 4'd0;
                    end
                endcase
            end
        end
    end
endmodule
