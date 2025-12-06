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
    input wire                          clk, rst_n,
    input wire [2:0]                    FSM_core_in,
    input wire [3:0]                    core_count_in,
    input wire [DATA_WIDTH-1:0]         data_in_0,
    input wire [DATA_WIDTH-1:0]         data_in_1,
    input wire [DATA_WIDTH-1:0]         data_in_2,
    input wire [DATA_WIDTH-1:0]         data_in_3,

    output wire [DATA_WIDTH-1:0]        data_out_0,
    output wire [DATA_WIDTH-1:0]        data_out_1,
    output wire [DATA_WIDTH-1:0]        data_out_2,
    output wire [DATA_WIDTH-1:0]        data_out_3
);
    //==================================================//
    //                   Registers                      //
    //==================================================//
    reg [DATA_WIDTH-1:0]                KE_out0_r, KE_out1_r, KE_out2_r, KE_out3_r;

    wire [3:0]                          core_count_w;
    wire [2:0]                          FSM_core_w;
    wire [DATA_WIDTH-1:0]               KE_out0_w, KE_out1_w, KE_out2_w, KE_out3_w;
    wire [DATA_WIDTH-1:0]               RotWord_byte_w, SubWord_byte_w, RoundConst_byte_w;
    //==================================================//
    //             Combinational Logic                  //
    //==================================================//
    assign FSM_core_w   = FSM_core_in;
    assign core_count_w = core_count_in;

    assign data_out_0 =  KE_out0_w ;
    assign data_out_1 =  KE_out1_w ;
    assign data_out_2 =  KE_out2_w ;
    assign data_out_3 =  KE_out3_w ;

    assign KE_out0_w = KE_out0_r ^ RoundConst_byte_w;
    assign KE_out1_w = KE_out0_w ^ KE_out1_r;
    assign KE_out2_w = KE_out1_w ^ KE_out2_r;
    assign KE_out3_w = KE_out2_w ^ KE_out3_r;
    //==================================================//
    //             Instantiate module                   //
    //==================================================//
    RotWord #(
        .DATA_WIDTH(DATA_WIDTH/4)
    )   module_RotWord
    (
        .W0_in(KE_out3_r[31:24]       ),
        .W1_in(KE_out3_r[23:16]       ),
        .W2_in(KE_out3_r[15:8]        ),
        .W3_in(KE_out3_r[7:0]         ),

        .W0_out(RotWord_byte_w[31:24] ),
        .W1_out(RotWord_byte_w[23:16] ),
        .W2_out(RotWord_byte_w[15:8]  ),
        .W3_out(RotWord_byte_w[7:0]   )
    );

    SubWord #(
        .DATA_WIDTH(DATA_WIDTH/4)
    )   module_SubWord
    (
        .i_S0(RotWord_byte_w[31:24]   ),
        .i_S1(RotWord_byte_w[23:16]   ),
        .i_S2(RotWord_byte_w[15:8]    ),
        .i_S3(RotWord_byte_w[7:0]     ),

        .o_D0(SubWord_byte_w[31:24]   ),
        .o_D1(SubWord_byte_w[23:16]   ),
        .o_D2(SubWord_byte_w[15:8]    ),
        .o_D3(SubWord_byte_w[7:0]     )
    );

    RoundConst #(
        .DATA_WIDTH(DATA_WIDTH/8)
    )   module_RoundConst
    (
        .Round_const_in(core_count_w),
        .Rcon0_in(SubWord_byte_w[31:24]),
        .Rcon1_in(SubWord_byte_w[23:16]),
        .Rcon2_in(SubWord_byte_w[15:8] ),
        .Rcon3_in(SubWord_byte_w[7:0]  ),

        .Round_const_out(RoundConst_byte_w)
    );
    
    //==================================================//
    //                   Datapath                       //
    //==================================================//
    integer i;
    always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
            KE_out0_r <= 32'd0;
            KE_out1_r <= 32'd0;
            KE_out2_r <= 32'd0;
            KE_out3_r <= 32'd0;
       end else begin
            if(FSM_core_w == 3'b010) begin//Receive key
                    KE_out0_r <= data_in_0;
                    KE_out1_r <= data_in_1;
                    KE_out2_r <= data_in_2;
                    KE_out3_r <= data_in_3;
            end else if(FSM_core_w == 3'b011) begin//Key Expansion
                if(core_count_w == 4'd0) begin
                    // Do not reload again
                end else begin
                    KE_out0_r <= KE_out0_w;
                    KE_out1_r <= KE_out1_w;
                    KE_out2_r <= KE_out2_w;
                    KE_out3_r <= KE_out3_w;
                end
            end
       end
    end
endmodule
