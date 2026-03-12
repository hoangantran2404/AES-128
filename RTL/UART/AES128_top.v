`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ngo Tran Hoang An
//           ngotranhoangan2007@gmail.com
// Create Date: 12/13/2025 03:50:08 PM
// Design Name: 
// Module Name: AES128_top
// Project Name: AES128
// Target Devices: ZCU102
// Tool Versions: Vivado 2022.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module AES128_top(
    input wire clk, 
    input wire rst_n,
    input wire data_in,

    output wire data_out
);
    //==================================================//
    //                      WIRE                        //
    //==================================================//
    wire        UART_dv_out_w;
    wire        MP_in_dv_out_w;
    wire        core_dv_out_w;
    wire        MP_out_dv_out_w;
    wire        TX_done_w;
    wire        TX_active_w;
    wire [7:0]  RX_data_out_w;
    wire [7:0]  MP_out_data_out_w;
    wire [31:0] MP_in_plaintext_out_w;
    wire [31:0] MP_in_key_out_w;
    wire [31:0] core_data_out_w;
    
    
    //==================================================//
    //                  Instantiate                     //
    //==================================================//

    receiver UART_RX(
        .CLK            (clk                    ),
        .Rx_Serial_in   (data_in                ),

        .Rx_DV_out      (UART_dv_out_w          ),
        .Rx_Byte_out    (RX_data_out_w          )
    );

    MP_in module_Message_Packer_in(
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .RX_DV_in       (UART_dv_out_w          ),
        .uart_byte_in   (RX_data_out_w          ),

        .MP_plaintext_out(MP_in_plaintext_out_w ),
        .MP_key_out     (MP_in_key_out_w        ),
        .MP_dv_out      (MP_in_dv_out_w         )
    );

    AES128_core module_AES128_core(
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .plaintext_in   (MP_in_plaintext_out_w  ),
        .key_in         (MP_in_key_out_w        ),
        .MP_dv_in       (MP_in_dv_out_w         ),

        .data_out       (core_data_out_w        ),
        .core_dv_out    (core_dv_out_w          )
    );

    MP_out module_Message_Packer_out(
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .RX_DV_in       (core_dv_out_w          ),
        .core_byte_in   (core_data_out_w        ),
        .TX_active_in   (TX_active_w            ),
        .TX_done_in     (TX_done_w              ),

        .MP_data_out    (MP_out_data_out_w      ),
        .MP_dv_out      (MP_out_dv_out_w        )
    );

    transmitter UART_TX(
        .CLK            (clk                    ),
        .Tx_DV_in       (MP_out_dv_out_w        ),
        .Tx_Byte_in     (MP_out_data_out_w      ),

        .Tx_Active_out  (TX_active_w            ),
        .Tx_Done_out    (TX_done_w              ),
        .Tx_Serial_out  (data_out               )
    );
endmodule
