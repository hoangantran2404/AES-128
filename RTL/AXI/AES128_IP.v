`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 03:38:55 PM
// Design Name: 
// Module Name: AES128_IP
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


module AES128_IP #(
		parameter integer C_S_AXI_ID_WIDTH		= 1,
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 40,
		parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
		parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
		parameter integer C_S_AXI_WUSER_WIDTH	= 0,
		parameter integer C_S_AXI_RUSER_WIDTH	= 0,
		parameter integer C_S_AXI_BUSER_WIDTH	= 0
)
(
		input wire 	                            S_AXI_ACLK,
		input wire                              S_AXI_ARESETN,
		input wire [C_S_AXI_ID_WIDTH-1 : 0]     S_AXI_AWID,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   S_AXI_AWADDR,
		input wire [7 : 0]                      S_AXI_AWLEN,
		input wire [2 : 0]                      S_AXI_AWSIZE,
		input wire [1 : 0]                      S_AXI_AWBURST,
		input wire                              S_AXI_AWLOCK,
		input wire [3 : 0]                      S_AXI_AWCACHE,
		input wire [2 : 0]                      S_AXI_AWPROT,
		input wire [3 : 0]                      S_AXI_AWQOS,
		input wire [3 : 0]                      S_AXI_AWREGION,
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		input wire                              S_AXI_AWVALID,
		output wire                             S_AXI_AWREADY,

		input wire [C_S_AXI_DATA_WIDTH-1 : 0]   S_AXI_WDATA,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input wire                              S_AXI_WLAST,
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0]  S_AXI_WUSER,
		input wire                              S_AXI_WVALID,
		output wire                             S_AXI_WREADY,

		output wire [C_S_AXI_ID_WIDTH-1 : 0]    S_AXI_BID,
		output wire [1 : 0]                     S_AXI_BRESP,
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		output wire                             S_AXI_BVALID,
		input wire                              S_AXI_BREADY,

		input wire [C_S_AXI_ID_WIDTH-1 : 0]     S_AXI_ARID,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0]   S_AXI_ARADDR,
		input wire [7 : 0]                      S_AXI_ARLEN,
		input wire [2 : 0]                      S_AXI_ARSIZE,
		input wire [1 : 0]                      S_AXI_ARBURST,
		input wire                              S_AXI_ARLOCK,
		input wire [3 : 0]                      S_AXI_ARCACHE,
		input wire [2 : 0]                      S_AXI_ARPROT,
		input wire [3 : 0]                      S_AXI_ARQOS,
		input wire [3 : 0]                      S_AXI_ARREGION,
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		input wire                              S_AXI_ARVALID,
		output wire                             S_AXI_ARREADY,

		output wire [C_S_AXI_ID_WIDTH-1 : 0]    S_AXI_RID,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0]  S_AXI_RDATA,
		output wire [1 : 0]                     S_AXI_RRESP,
		output wire                             S_AXI_RLAST,
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		output wire                             S_AXI_RVALID,
		input wire                              S_AXI_RREADY
);
    AXI4_Mapping #(
        .C_S_AXI_ID_WIDTH           (C_S_AXI_ID_WIDTH),
		.C_S_AXI_DATA_WIDTH         (C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH         (C_S_AXI_ADDR_WIDTH),
		.C_S_AXI_AWUSER_WIDTH       (C_S_AXI_AWUSER_WIDTH),
		.C_S_AXI_ARUSER_WIDTH       (C_S_AXI_ARUSER_WIDTH),
		.C_S_AXI_WUSER_WIDTH        (C_S_AXI_WUSER_WIDTH),
		.C_S_AXI_RUSER_WIDTH        (C_S_AXI_RUSER_WIDTH)
    )u_AXI4_Mapping (
        // Global signals
        .S_AXI_ACLK                 (S_AXI_ACLK),
        .S_AXI_ARESETN              (S_AXI_ARESETN),
        
        // Write Address Channel
        .S_AXI_AWID                 (S_AXI_AWID),
        .S_AXI_AWADDR               (S_AXI_AWADDR),
        .S_AXI_AWLEN                (S_AXI_AWLEN),
        .S_AXI_AWSIZE               (S_AXI_AWSIZE),
        .S_AXI_AWBURST              (S_AXI_AWBURST),
        .S_AXI_AWLOCK               (S_AXI_AWLOCK),
        .S_AXI_AWCACHE              (S_AXI_AWCACHE),
        .S_AXI_AWPROT               (S_AXI_AWPROT),
        .S_AXI_AWQOS                (S_AXI_AWQOS),
        .S_AXI_AWREGION             (S_AXI_AWREGION),
        .S_AXI_AWUSER               (S_AXI_AWUSER),
        .S_AXI_AWVALID              (S_AXI_AWVALID),
        .S_AXI_AWREADY              (S_AXI_AWREADY),

        // Write Data Channel
        .S_AXI_WDATA                (S_AXI_WDATA),
        .S_AXI_WSTRB                (S_AXI_WSTRB),
        .S_AXI_WLAST                (S_AXI_WLAST),
        .S_AXI_WUSER                (S_AXI_WUSER),
        .S_AXI_WVALID               (S_AXI_WVALID),
        .S_AXI_WREADY               (S_AXI_WREADY),

        // Write Response Channel
        .S_AXI_BID                  (S_AXI_BID),
        .S_AXI_BRESP                (S_AXI_BRESP),
        .S_AXI_BUSER                (S_AXI_BUSER),
        .S_AXI_BVALID               (S_AXI_BVALID),
        .S_AXI_BREADY               (S_AXI_BREADY),

        // Read Address Channel
        .S_AXI_ARID                 (S_AXI_ARID),
        .S_AXI_ARADDR               (S_AXI_ARADDR),
        .S_AXI_ARLEN                (S_AXI_ARLEN),
        .S_AXI_ARSIZE               (S_AXI_ARSIZE),
        .S_AXI_ARBURST              (S_AXI_ARBURST),
        .S_AXI_ARLOCK               (S_AXI_ARLOCK),
        .S_AXI_ARCACHE              (S_AXI_ARCACHE),
        .S_AXI_ARPROT               (S_AXI_ARPROT),
        .S_AXI_ARQOS                (S_AXI_ARQOS),
        .S_AXI_ARREGION             (S_AXI_ARREGION),
        .S_AXI_ARUSER               (S_AXI_ARUSER),
        .S_AXI_ARVALID              (S_AXI_ARVALID),
        .S_AXI_ARREADY              (S_AXI_ARREADY),

        // Read Data Channel
        .S_AXI_RID                  (S_AXI_RID),
        .S_AXI_RDATA                (S_AXI_RDATA),
        .S_AXI_RRESP                (S_AXI_RRESP),
        .S_AXI_RLAST                (S_AXI_RLAST),
        .S_AXI_RUSER                (S_AXI_RUSER),
        .S_AXI_RVALID               (S_AXI_RVALID),
        .S_AXI_RREADY               (S_AXI_RREADY)
    );

endmodule
