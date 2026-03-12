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
    parameter DATA_WIDTH =128
)
(
    input wire                              clk, rst_n,
    input wire                              start_in,
    input wire [DATA_WIDTH-1:0]             plaintext_in,
    input wire                              plaintext_dv_in,
    input wire [DATA_WIDTH-1:0]             key_in,
    input wire                              key_dv_in,

    output wire [DATA_WIDTH-1:0]            data_out,
    output wire                             core_dv_out
);
    //==================================================//
    //               Internal Signals                   //
    //==================================================//
    reg [127:0]                    address_key_r;
    reg [127:0]                    address_text_r;
    reg [127:0]                    address_r;            // save the output
    reg [3:0]                      core_count_r;
    reg                            done_flag_r;
    
    wire                           cipher_dv_out_w;

    wire [127:0]                   KE_byte_out_w; 
    wire [127:0]                   cipher_byte_out_w;    
    //==================================================//
    //                State Encoding                    //
    //==================================================//
    localparam s_IDLE           = 3'b000;
    localparam s_EXEC           = 3'b001;
    localparam s_DONE           = 3'b010;

    reg [2:0] current_state_r   = s_IDLE;
    reg [2:0] next_state_r;
    //==================================================//
    //               Combinational Logic                //
    //==================================================//
    assign core_dv_out      = done_flag_r;

    assign data_out         = address_r;

    //==================================================//
    //                Instantiate module                //
    //==================================================//
    Key_Expansion #(
        .DATA_WIDTH(2*DATA_WIDTH)
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
        .DATA_WIDTH(2*DATA_WIDTH)
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

        .key_0_in       (KE_byte_out_w[127:96]      ),
        .key_1_in       (KE_byte_out_w[95:64]       ),
        .key_2_in       (KE_byte_out_w[63:32]       ),
        .key_3_in       (KE_byte_out_w[31:0]        ),

        .text_0_out     (cipher_byte_out_w[127:96]  ),
        .text_1_out     (cipher_byte_out_w[95:64]   ),                       
        .text_2_out     (cipher_byte_out_w[63:32]   ),                   
        .text_3_out     (cipher_byte_out_w[31:0]    ),                 
        .cipher_dv_flag (cipher_dv_out_w            )
    );

    //==================================================//
    //                  Next State LogicS               //
    //==================================================//
    always @(start_in or cipher_dv_out_w) begin
        case(current_state_r)
            s_IDLE: 
                if(start_in == 1'b1)
                    next_state_r = s_EXEC;
                else 
                    next_state_r = s_IDLE;
            s_EXEC:
                if(cipher_dv_out_w)
                    next_state_r = s_DONE;
                else
                    next_state_r = s_EXEC;
            s_DONE:
                next_state_r    =   s_IDLE;
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
            done_flag_r     <= 0;
        end else begin
                case(current_state_r)
                    s_IDLE: begin
                        core_count_r            <=  0;
                        if(start_in) begin
                            address_text_r      <=  plaintext_in;
                            address_key_r       <=  key_in;
                            done_flag_r         <=  0;
                        end
                    end
                    s_EXEC: begin
                            core_count_r        <= core_count_r + 4'd1; 
                            if(cipher_dv_out_w) begin
                                address_r       <=  cipher_byte_out_w;
                            end 
                    end
                    s_DONE: begin
                       done_flag_r  <=  1;
                    end
                endcase
        end
    end
endmodule
