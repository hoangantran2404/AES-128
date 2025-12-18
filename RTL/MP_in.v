`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2025 03:48:46 PM
// Design Name: 
// Module Name: MP_in
// Project Name: AES128
// Target Devices: ZCU102
// Tool Versions: 
// Description: Message Packer receives data from UART RX 8-bit/1 cycle clock and send data to core 32-bit/clock.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module MP_in #(
    parameter DATA_WIDTH    = 32
)(
    input  wire                             clk,    
    input  wire                             rst_n,  
    input  wire [7:0]                       uart_byte_in,     
    input  wire                             RX_DV_in,

    output wire [DATA_WIDTH-1 :0]           MP_plaintext_out,
    output wire [DATA_WIDTH-1 :0]           MP_key_out,
    output wire                             MP_dv_out     
);

    //==================================================//
    //                 State Encoding                   //
    //==================================================//
    reg  [2:0] current_state_r;
    reg  [2:0] next_state_r;

    localparam s_PRELOAD      = 3'b000;
    localparam s_RX_DATA_BITS = 3'b001; 
    localparam s_SEND         = 3'b010;
    localparam s_CLEANUP      = 3'b011;

    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg [5:0]                     MP_count_r;
    reg [127:0]                   plaintext_address_r ;  
    reg [127:0]                   key_address_r;

    wire                          RX_done_flag_w; 
    wire                          SEND_done_flag_w;    

    //==================================================//
    //             Combinational Logic                  //
    //==================================================//

    assign MP_dv_out        = (current_state_r == s_SEND);

    assign RX_done_flag_w   = (current_state_r == s_RX_DATA_BITS && MP_count_r == 6'd32) ; 
    assign SEND_done_flag_w = (current_state_r == s_SEND && MP_count_r == 6'd3); 

    assign MP_plaintext_out = (current_state_r == s_SEND) ?   plaintext_address_r[127-32*MP_count_r -:32]: 32'd0;
    assign MP_key_out       = (current_state_r == s_SEND) ?   key_address_r[127-32*MP_count_r -:32]:32'd0;
    //==================================================//
    //                  Next State Logic                //
    //==================================================//
    always @(current_state_r or RX_DV_in or RX_done_flag_w or SEND_done_flag_w) begin
        case(current_state_r)
            s_PRELOAD: 
                if(RX_DV_in) 
                    next_state_r = s_RX_DATA_BITS;
                else          
                    next_state_r = s_PRELOAD;
            
            s_RX_DATA_BITS: 
                if(RX_done_flag_w) 
                    next_state_r = s_SEND; 
                else               
                    next_state_r = s_RX_DATA_BITS;
        
            s_SEND: 
                if (SEND_done_flag_w) 
                    next_state_r = s_CLEANUP;    
                else                  
                    next_state_r = s_SEND;
            
            s_CLEANUP: 
                next_state_r = s_PRELOAD;
            
            default: 
                next_state_r = s_PRELOAD;
        endcase
    end

    //==================================================//
    //                State Register (FSM)              //
    //==================================================//
    always @(posedge clk or negedge rst_n ) begin
        if(!rst_n) 
            current_state_r <= s_PRELOAD;
        else       
            current_state_r <= next_state_r;
    end

    //==================================================//
    //                   Datapath                       //
    //==================================================//
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            MP_count_r <= 0;
            plaintext_address_r  <= 128'd0;
            key_address_r        <= 128'd0;
        end else begin
            if(next_state_r == s_SEND)
                MP_count_r <= 0;
            case(current_state_r)
                s_PRELOAD: begin
                   if (RX_DV_in) begin
                        plaintext_address_r[127 -: 8] <= uart_byte_in;
                        MP_count_r                    <= 1;
                    end
                end
                s_RX_DATA_BITS: begin
                    if(RX_DV_in) begin
                        if(MP_count_r < 6'd16) begin
                            plaintext_address_r[127 - 8*MP_count_r -:8] <= uart_byte_in;             
                        end else begin
                            key_address_r[127 -8*(MP_count_r-16) -:8] <= uart_byte_in;
                        end
                            MP_count_r <= MP_count_r + 1;
                    end 
                end
                s_SEND: begin
                    if(MP_count_r < 6'd4)
                        MP_count_r   <= MP_count_r + 1;        
                end

                s_CLEANUP: begin              
                    MP_count_r      <= 0;           
                end
            endcase
        end
    end
endmodule
