`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Ngo Tran Hoang An
//            ngotranhoangan2007@gmail.com
// Create Date: 12/03/2025 04:10:51 PM
// Design Name: Cipher_text
// Module Name: Cipher
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


module Cipher#(
    parameter DATA_WIDTH =32
)
(   
    input wire clk, rst_n,
    input wire [2:0]              FSM_core_in
    input wire [3:0]              core_count_in,
    input wire [DATA_WIDTH -1: 0] text_0_in,  
    input wire [DATA_WIDTH -1: 0] text_1_in,
    input wire [DATA_WIDTH -1: 0] text_2_in,
    input wire [DATA_WIDTH -1: 0] text_3_in,

    input wire [DATA_WIDTH -1: 0] key_0_in,
    input wire [DATA_WIDTH -1: 0] key_1_in,
    input wire [DATA_WIDTH -1: 0] key_2_in,
    input wire [DATA_WIDTH -1: 0] key_3_in,


    output wire [DATA_WIDTH -1: 0] text_0_out,
    output wire [DATA_WIDTH -1: 0] text_1_out,
    output wire [DATA_WIDTH -1: 0] text_2_out,
    output wire [DATA_WIDTH -1: 0] text_3_out,
    output wire                    cipher_dv_flag
);
//==================================================//
//                   Registers                      //
//==================================================//
    reg [DATA_WIDTH -1 :0]          address_r       [0:3];                           

    wire [2:0]                  FSM_state_w;
    wire [3:0]                  round_count_w;
    // Round 0
    wire [DATA_WIDTH-1:0]      ARK_in0_r0_w , ARK_in1_r0_w, ARK_in2_r0_w , ARK_in3_r0_w; 
    wire [DATA_WIDTH-1:0]      ARK_out0_r0_w,ARK_out1_r0_w, ARK_out2_r0_w, ARK_out3_r0_w;

    // Round 1 to 9
    wire [DATA_WIDTH-1:0]      ARK_in0_r_w, ARK_in1_r_w, ARK_in2_r_w, ARK_in3_r_w;             
    wire [DATA_WIDTH-1:0]      ARK_out0_r_w, ARK_out1_r_w, ARK_out2_r_w, ARK_out3_r_w;          
    wire [DATA_WIDTH-1:0]      SR_in0_r_w,  SR_in1_r_w , SR_in2_r_w , SR_in3_r_w;             
    wire [DATA_WIDTH-1:0]      MC_in0_r_w,  MC_in1_r_w , MC_in2_r_w , MC_in3_r_w;             

    // Round 10
    wire [DATA_WIDTH-1:0]      ARK_in0_r10_w, ARK_in1_r10_w, ARK_in2_r10_w, ARK_in3_r10_w;      
    wire [DATA_WIDTH-1:0]      ARK_out0_r10_w, ARK_out1_r10_w, ARK_out2_r10_w, ARK_out3_r10_w;  
    wire [DATA_WIDTH-1:0]      SR_in0_r10_w,  SR_in1_r10_w , SR_in2_r10_w , SR_in3_r10_w;       


//==================================================//
//             Combinational Logic                  //
//==================================================//
    assign FSM_state_w      = FSM_core_in;
    assign round_count_w    = core_count_in;
    assign cipher_dv_flag   = (FSM_state_w == 3'b100);

    assign text_0_out =(FSM_state_w == 3'b100)? address_r[0] : 32'd0;
    assign text_1_out =(FSM_state_w == 3'b100)? address_r[1] : 32'd0;
    assign text_2_out =(FSM_state_w == 3'b100)? address_r[2] : 32'd0;
    assign text_3_out =(FSM_state_w == 3'b100)? address_r[3] : 32'd0;

//==================================================//
//             Instantiate module                   //
//==================================================//

    // Round 0
    AddRoundkey#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .i_state0(address_r[0]),
        .i_state1(address_r[1]),
        .i_state2(address_r[2]),
        .i_state3(address_r[3]),

        .i_key0  (key_0_in),
        .i_key1  (key_1_in),
        .i_key2  (key_2_in),
        .i_key3  (key_3_in),

        .dout0   (ARK_out0_r0_w),
        .dout1   (ARK_out1_r0_w),
        .dout2   (ARK_out2_r0_w),
        .dout3   (ARK_out3_r0_w)
    );
    // Round 1 to 9
    SubBytes#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .i_s0(address_r[0]),
        .i_s1(address_r[1]),
        .i_s2(address_r[2]),
        .i_s3(address_r[3]),

        .o_out0(SR_in0_r_w),
        .o_out1(SR_in1_r_w),
        .o_out2(SR_in2_r_w),
        .o_out3(SR_in3_r_w),
    );

    ShiftRows#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .in_sr0(SR_in0_r_w),
        .in_sr1(SR_in1_r_w),
        .in_sr2(SR_in2_r_w),
        .in_sr3(SR_in3_r_w),

        .out_sr0(MC_in0_r_w),
        .out_sr1(MC_in1_r_w),
        .out_sr2(MC_in2_r_w),
        .out_sr3(MC_in3_r_w)
    );

    MixColumns#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .in_mc0(MC_in0_r_w),
        .in_mc1(MC_in1_r_w)
        .in_mc2(MC_in2_r_w),
        .in_mc3(MC_in3_r_w),

        .out_mc0(ARK_in0_r_w),
        .out_mc1(ARK_in1_r_w),
        .out_mc2(ARK_in2_r_w),
        .out_mc3(ARK_in3_r_w)
    );

    AddRoundkey#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .i_state0(ARK_in0_r_w),
        .i_state1(ARK_in1_r_w),
        .i_state2(ARK_in2_r_w),
        .i_state3(ARK_in3_r_w),

        .i_key0  (key_0_in),
        .i_key1  (key_1_in),
        .i_key2  (key_2_in),
        .i_key3  (key_3_in),

        .dout0   (ARK_out0_r_w),
        .dout1   (ARK_out1_r_w),
        .dout2   (ARK_out2_r_w),
        .dout3   (ARK_out3_r_w)
    );

    // Round 10
    SubBytes#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .i_s0(address_r[0]),
        .i_s1(address_r[1]),
        .i_s2(address_r[2]),
        .i_s3(address_r[3]),

        .o_out0(SR_in0_r10_w),
        .o_out1(SR_in1_r10_w),
        .o_out2(SR_in2_r10_w),
        .o_out3(SR_in3_r10_w),
    );

    ShiftRows#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .in_sr0(SR_in0_r10_w),
        .in_sr1(SR_in1_r10_w),
        .in_sr2(SR_in2_r10_w),
        .in_sr3(SR_in3_r10_w),

        .out_sr0(ARK_in0_r10_w),
        .out_sr1(ARK_in1_r10_w),
        .out_sr2(ARK_in2_r10_w),
        .out_sr3(ARK_in3_r10_w)
    );

    AddRoundkey#(
        .DATA_WIDTH(DATA_WIDTH)
    )
    (
        .i_state0(ARK_in0_r10_w),
        .i_state1(ARK_in1_r10_w),
        .i_state2(ARK_in2_r10_w),
        .i_state3(ARK_in3_r10_w),

        .i_key0  (key_0_in),
        .i_key1  (key_1_in),
        .i_key2  (key_2_in),
        .i_key3  (key_3_in),

        .dout0   (ARK_out0_r10_w),
        .dout1   (ARK_out1_r10_w),
        .dout2   (ARK_out2_r10_w),
        .dout3   (ARK_out3_r10_w)
    );


//==================================================//
//                   Datapath                       //
//==================================================//
    integer i;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < 4; i= i+1 )begin
                address_r[i]        <= 32'd0;
            end
        end else begin
            if(FSM_state_w == 3'b010) begin
                address_r[0]        <= text_0_in;
                address_r[1]        <= text_1_in;
                address_r[2]        <= text_2_in;
                address_r[3]        <= text_3_in;
            
            end else if(FSM_state_w == 3'b011) begin
                if(round_count_w == 4'd0) begin
                    address_r[0]        <= ARK_out0_r0_w;
                    address_r[1]        <= ARK_out1_r0_w;
                    address_r[2]        <= ARK_out2_r0_w;
                    address_r[3]        <= ARK_out3_r0_w;

                end else if(round_count_w >= 1 && round_count_w < 10) begin
                    address_r[0]        <= ARK_out0_r_w;
                    address_r[1]        <= ARK_out1_r_w;
                    address_r[2]        <= ARK_out2_r_w;
                    address_r[3]        <= ARK_out3_r_w;
                end else begin
                    address_r[0]        <= ARK_out0_r10_w;
                    address_r[1]        <= ARK_out1_r10_w;
                    address_r[2]        <= ARK_out2_r10_w;
                    address_r[3]        <= ARK_out3_r10_w;
                end
            end 
        end
    end

endmodule
