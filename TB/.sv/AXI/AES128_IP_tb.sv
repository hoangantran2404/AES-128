`timescale 1ns / 1ps

`define START_BASE_PHYS     40'h00A0000000
`define DONE_BASE_PHYS      40'h00A0000008
`define PLAINTEXT_BASE_PHYS 40'h00A0000010
`define KEY_BASE_PHYS       40'h00A0000020
`define VALID_BASE_PHYS     40'h00A0000000
`define RESULT_BASE_PHYS    40'h00A0000030

module AES128_IP_tb();

    //==================================================//
    //              Parameters                          //
    //==================================================//
    parameter integer C_S_AXI_ID_WIDTH     = 1;
    parameter integer C_S_AXI_DATA_WIDTH   = 32;
    parameter integer C_S_AXI_ADDR_WIDTH   = 40;
    parameter integer C_S_AXI_AWUSER_WIDTH = 0;
    parameter integer C_S_AXI_ARUSER_WIDTH = 0;
    parameter integer C_S_AXI_WUSER_WIDTH  = 0;
    parameter integer C_S_AXI_RUSER_WIDTH  = 0;
    parameter integer C_S_AXI_BUSER_WIDTH  = 0;

    //==================================================//
    //               Input / Output                      //
    //==================================================//
    logic                                 S_AXI_ACLK;
    logic                                 S_AXI_ARESETN;

    // Write Address Channel
    logic [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_AWID;
    logic [C_S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_AWADDR;
    logic [7 : 0]                         S_AXI_AWLEN;
    logic [2 : 0]                         S_AXI_AWSIZE;
    logic [1 : 0]                         S_AXI_AWBURST;
    logic                                 S_AXI_AWLOCK;
    logic [3 : 0]                         S_AXI_AWCACHE;
    logic [2 : 0]                         S_AXI_AWPROT;
    logic [3 : 0]                         S_AXI_AWQOS;
    logic [3 : 0]                         S_AXI_AWREGION;
    logic [C_S_AXI_AWUSER_WIDTH-1 : 0]    S_AXI_AWUSER;
    logic                                 S_AXI_AWVALID;
    logic                                 S_AXI_AWREADY;

    // Write Data Channel
    logic [C_S_AXI_DATA_WIDTH-1 : 0]      S_AXI_WDATA;
    logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0]  S_AXI_WSTRB;
    logic                                 S_AXI_WLAST;
    logic [C_S_AXI_WUSER_WIDTH-1 : 0]     S_AXI_WUSER;
    logic                                 S_AXI_WVALID;
    logic                                 S_AXI_WREADY;

    // Write Response Channel
    logic [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_BID;
    logic [1 : 0]                         S_AXI_BRESP;
    logic [C_S_AXI_BUSER_WIDTH-1 : 0]     S_AXI_BUSER;
    logic                                 S_AXI_BVALID;
    logic                                 S_AXI_BREADY;

    // Read Address Channel
    logic [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_ARID;
    logic [C_S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_ARADDR;
    logic [7 : 0]                         S_AXI_ARLEN;
    logic [2 : 0]                         S_AXI_ARSIZE;
    logic [1 : 0]                         S_AXI_ARBURST;
    logic                                 S_AXI_ARLOCK;
    logic [3 : 0]                         S_AXI_ARCACHE;
    logic [2 : 0]                         S_AXI_ARPROT;
    logic [3 : 0]                         S_AXI_ARQOS;
    logic [3 : 0]                         S_AXI_ARREGION;
    logic [C_S_AXI_ARUSER_WIDTH-1 : 0]    S_AXI_ARUSER;
    logic                                 S_AXI_ARVALID;
    logic                                 S_AXI_ARREADY;

    // Read Data Channel
    logic [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_RID;
    logic [C_S_AXI_DATA_WIDTH-1 : 0]      S_AXI_RDATA;
    logic [1 : 0]                         S_AXI_RRESP;
    logic                                 S_AXI_RLAST;
    logic [C_S_AXI_RUSER_WIDTH-1 : 0]     S_AXI_RUSER;
    logic                                 S_AXI_RVALID;
    logic                                 S_AXI_RREADY;

    //==================================================//
    //                 Instantiate DUT                  //
    //==================================================//
    AXI4_Mapping #(
        // Parameters mapping
        .C_S_AXI_ID_WIDTH(C_S_AXI_ID_WIDTH),
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) dut (
        .S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        
        .S_AXI_AWID(S_AXI_AWID), .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWLEN(S_AXI_AWLEN), .S_AXI_AWSIZE(S_AXI_AWSIZE),
        .S_AXI_AWBURST(S_AXI_AWBURST), .S_AXI_AWLOCK(S_AXI_AWLOCK),
        .S_AXI_AWCACHE(S_AXI_AWCACHE), .S_AXI_AWPROT(S_AXI_AWPROT),
        .S_AXI_AWQOS(S_AXI_AWQOS), .S_AXI_AWREGION(S_AXI_AWREGION),
        .S_AXI_AWUSER(S_AXI_AWUSER), .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        
        .S_AXI_WDATA(S_AXI_WDATA), .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WLAST(S_AXI_WLAST), .S_AXI_WUSER(S_AXI_WUSER),
        .S_AXI_WVALID(S_AXI_WVALID), .S_AXI_WREADY(S_AXI_WREADY),
        
        .S_AXI_BID(S_AXI_BID), .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BUSER(S_AXI_BUSER), .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        
        .S_AXI_ARID(S_AXI_ARID), .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARLEN(S_AXI_ARLEN), .S_AXI_ARSIZE(S_AXI_ARSIZE),
        .S_AXI_ARBURST(S_AXI_ARBURST), .S_AXI_ARLOCK(S_AXI_ARLOCK),
        .S_AXI_ARCACHE(S_AXI_ARCACHE), .S_AXI_ARPROT(S_AXI_ARPROT),
        .S_AXI_ARQOS(S_AXI_ARQOS), .S_AXI_ARREGION(S_AXI_ARREGION),
        .S_AXI_ARUSER(S_AXI_ARUSER), .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        
        .S_AXI_RID(S_AXI_RID), .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP), .S_AXI_RLAST(S_AXI_RLAST),
        .S_AXI_RUSER(S_AXI_RUSER), .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY)
    );

    //==================================================//
    //                 Clock Generation                 //
    //==================================================//
    always #5 S_AXI_ACLK = ~S_AXI_ACLK;

    //==================================================//
    //               Data Structures cho Test           //
    //==================================================//
    typedef struct {
        string                  test_name;
        logic [127:0]           pt;         // Plaintext
        logic [127:0]           key;        // Key
        logic [127:0]           exp_ct;     // Expected Ciphertext
    } test_vector_t;

    test_vector_t test_cases[3] = '{
        '{"NIST SP800-38A", 128'h6bc1bee22e409f96e93d7e117393172a, 128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3ad77bb40d7a3660a89ecaf32466ef97},
        '{"NIST FIPS-197" , 128'h3243f6a8885a308d313198a2e0370734, 128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3925841d02dc09fbdc118597196a0b32},
        '{"ALL ZEROS"     , 128'h00000000000000000000000000000000, 128'h00000000000000000000000000000000, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e}
    };

    int passed_cases = 0;
    int failed_cases = 0;

    //==================================================//
    //                   AXI4 Tasks                     //
    //==================================================//
    task automatic axi_write(input logic [39:0] addr, input logic [31:0] data);
        begin
            @(posedge S_AXI_ACLK);
            S_AXI_AWADDR  <= addr; S_AXI_AWVALID <= 1'b1;
            wait(S_AXI_AWREADY == 1'b1);
            @(posedge S_AXI_ACLK); S_AXI_AWVALID <= 1'b0;
            
            S_AXI_WDATA  <= data; S_AXI_WSTRB  <= 4'b1111;
            S_AXI_WVALID <= 1'b1; S_AXI_WLAST  <= 1'b1;
            wait(S_AXI_WREADY == 1'b1);
            @(posedge S_AXI_ACLK); S_AXI_WVALID <= 1'b0; S_AXI_WLAST  <= 1'b0;
            
            S_AXI_BREADY <= 1'b1;
            wait(S_AXI_BVALID == 1'b1);
            @(posedge S_AXI_ACLK); S_AXI_BREADY <= 1'b0;
        end
    endtask

    task automatic axi_read(input logic [39:0] addr, output logic [31:0] data);
        begin
            @(posedge S_AXI_ACLK);
            S_AXI_ARADDR  <= addr; S_AXI_ARVALID <= 1'b1;
            wait(S_AXI_ARREADY == 1'b1);
            @(posedge S_AXI_ACLK); S_AXI_ARVALID <= 1'b0;
            
            S_AXI_RREADY <= 1'b1;
            wait(S_AXI_RVALID == 1'b1);
            data = S_AXI_RDATA;
            @(posedge S_AXI_ACLK); S_AXI_RREADY <= 1'b0;
        end
    endtask

    //==================================================//
    //                      Test Case                   //
    //==================================================//
    task automatic run_axi_test_case(input int id, input test_vector_t tv);
        logic [31:0] read_val;
        logic [127:0] actual_ct;
        int timeout_counter = 0;

        $display("--------------------------------------------------");
        $display("[RUNNING] Case %0d: %s in AXI4", id, tv.test_name);
        
        axi_write(`KEY_BASE_PHYS + 40'h0, tv.key[127:96]);
        axi_write(`KEY_BASE_PHYS + 40'h4, tv.key[95:64]);
        axi_write(`KEY_BASE_PHYS + 40'h8, tv.key[63:32]);
        axi_write(`KEY_BASE_PHYS + 40'hC, tv.key[31:0]);

        axi_write(`PLAINTEXT_BASE_PHYS + 40'h0, tv.pt[127:96]);
        axi_write(`PLAINTEXT_BASE_PHYS + 40'h4, tv.pt[95:64]);
        axi_write(`PLAINTEXT_BASE_PHYS + 40'h8, tv.pt[63:32]);
        axi_write(`PLAINTEXT_BASE_PHYS + 40'hC, tv.pt[31:0]);

        axi_write(`START_BASE_PHYS, 32'h00000001);

        read_val = 0;
        while (read_val[0] == 1'b0) begin
            axi_read(`VALID_BASE_PHYS, read_val);
            #10;
            timeout_counter++;
            if (timeout_counter > 500) begin
                $error("[FAILED] Case %0d: TIMEOUT !", id);
                failed_cases++;
                return; 
            end
        end

        axi_read(`RESULT_BASE_PHYS + 40'h0, actual_ct[127:96]);
        axi_read(`RESULT_BASE_PHYS + 40'h4, actual_ct[95:64]);
        axi_read(`RESULT_BASE_PHYS + 40'h8, actual_ct[63:32]);
        axi_read(`RESULT_BASE_PHYS + 40'hC, actual_ct[31:0]);


        if (actual_ct === tv.exp_ct) begin
            $display("[PASSED] Case %0d MATCHED \n   Act: %h\n   Exp: %h", id, actual_ct, tv.exp_ct);
            passed_cases++;
        end else begin
            $error("[FAILED] Case %0d FAILER! \n   Act: %h\n   Exp: %h", id, actual_ct, tv.exp_ct);
            failed_cases++;
        end

        axi_write(`START_BASE_PHYS, 32'h00000000);
        axi_write(`DONE_BASE_PHYS,  32'h00000001); 
        #50;
        axi_write(`DONE_BASE_PHYS,  32'h00000000); 
        #50;
    endtask

    //==================================================//
    //                   Main Test                      //
    //==================================================//
    initial begin
        S_AXI_ACLK     = 0;  S_AXI_ARESETN  = 0;
        S_AXI_AWID     = 0;  S_AXI_AWADDR   = 0;  S_AXI_AWLEN    = 0;  S_AXI_AWSIZE   = 3'b010; 
        S_AXI_AWBURST  = 2'b00; S_AXI_AWLOCK   = 0;  S_AXI_AWCACHE  = 0;  S_AXI_AWPROT   = 0;  
        S_AXI_AWQOS    = 0;  S_AXI_AWREGION = 0;  S_AXI_AWUSER   = 0;  S_AXI_AWVALID  = 0;
        S_AXI_WDATA    = 0;  S_AXI_WSTRB    = 0;  S_AXI_WLAST    = 0;  S_AXI_WUSER    = 0;
        S_AXI_WVALID   = 0;  S_AXI_BREADY   = 0;  S_AXI_ARID     = 0;  S_AXI_ARADDR   = 0;
        S_AXI_ARLEN    = 0;  S_AXI_ARSIZE   = 3'b010; S_AXI_ARBURST  = 2'b00; S_AXI_ARLOCK   = 0;  
        S_AXI_ARCACHE  = 0;  S_AXI_ARPROT   = 0;  S_AXI_ARQOS    = 0;  S_AXI_ARREGION = 0;  
        S_AXI_ARUSER   = 0;  S_AXI_ARVALID  = 0;  S_AXI_RREADY   = 0;

        $display("==================================================");
        $display("   TESTBENCH STARTING: AXI4_Mapping + AES128      ");
        $display("==================================================");

        #20 S_AXI_ARESETN = 1; 
        #20;

        foreach (test_cases[i]) begin
            run_axi_test_case(i + 1, test_cases[i]);
        end

        $display("==================================================");
        $display("               TEST SUMMARY                       ");
        $display("==================================================");
        $display("Total Cases: %0d", passed_cases + failed_cases);
        $display("Passed     : %0d", passed_cases);
        $display("Failed     : %0d", failed_cases);
        if (failed_cases == 0)
            $display(">>> ALL TESTS PASSED SUCCESSFULLY! <<<");
        else
            $display(">>> SOME TESTS FAILED. PLEASE CHECK LOG. <<<");
        $display("==================================================");

        $finish;
    end

endmodule
