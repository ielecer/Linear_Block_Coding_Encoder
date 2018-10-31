`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Electronic Science and Technology of China
// Engineer: Yajun Mei
// 
// Create Date: 09/21/2018 09:55:46 PM
// Design Name: Linear block code encoder
// Module Name: encoder
// Project Name: Encoder_for_linear_block_coding
// Target Devices: Zynq UltraScale+ ZCU102 Evaluation Board (xczu9eg-ffvb1156-2-e)
// Tool Versions: Vivado 2018.2.1
// Description: [n, k] = [38, 32] linear block code encoder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module encoder(
    input clk,
//    reg [7:0] Din,      // 8-bit input
    input [31:0] Din,     // 32-bit input
    output [7:0] Qout1,
    output [7:0] Qout2,
    output [7:0] Qout3,
    output [7:0] Qout4,
    output clk_test,
    output [5:0] C
    );
    reg [37:0] C_reg;
    
    reg [1:0] Cunt = 2'b00;
//    reg [1:0] select = 2'b00;
    
    reg [7:0] Q[3:0];
    reg Q_S1[3:0][5:0][3:0];
    reg Q_S2[3:0][5:0][1:0];
    reg Q_S3[5:0][3:0];
    reg Q_S3_reg[5:0][1:0];
    reg Q_S4[5:0][1:0];
    reg Q_S4_reg[5:0][1:0];
    reg [37:0] Q_S5;
    
    reg [7:0] Q_bus_buf[3:0][3:0];
    
    reg clk_start = 1'b0;
    reg [2:0] clk_cnt = 3'b000;
    reg clk_div2 = 1'b0;
    reg clk_div2_shf[6:0];
    reg clk_out = 1'b0;
        
    assign Qout1 = Q[0];
    assign Qout2 = Q[1];
    assign Qout3 = Q[2];
    assign Qout4 = Q[3];
    assign clk_test = clk_out;
    
    // Demux choice 1
    always@(posedge clk)
    begin
        Cunt <= Cunt + 1;

        case(Cunt[1])
            1'b0:
                case(Cunt[0])
                    1'b0: Q[0] <= Din[7:0];
                    1'b1: 
                        begin
                            Q[1] <= Din[15:8];
                            clk_div2 <= ~clk_div2;
                        end
                endcase
            1'b1:
                case(Cunt[0])
                    1'b0: Q[2] <= Din[23:16];
                    1'b1: 
                        begin
                            Q[3] <= Din[31:24];
                            clk_div2 <= ~clk_div2;
                        end
                endcase
        endcase
    end
    
    // Shift clock sequence
    // Use negedge to avoid Cmpetition & only half clock cycle delay exists
    always@(negedge clk)
    begin
        clk_div2_shf[0] <= clk_div2;
        clk_div2_shf[1] <= clk_div2_shf[0];
        clk_div2_shf[2] <= clk_div2_shf[1];
        clk_div2_shf[3] <= clk_div2_shf[2];
        clk_div2_shf[4] <= clk_div2_shf[3];
        clk_div2_shf[5] <= clk_div2_shf[4];
        clk_div2_shf[6] <= clk_div2_shf[5];
        clk_out <= clk_div2_shf[6];
    end
    
//    // Demux choice 2
//    // FSM
//    always@(posedge clk)
//    begin
//        case(select)
//            2'b00: select <= 2'b01;
//            2'b01: select <= 2'b10;
//            2'b10: select <= 2'b11;
//            2'b11: select <= 2'b00;
//        endcase
//    end
    
//    // 1-to-4 demux
//    always@(posedge clk)
//    begin
//        case(select)
//            2'b00: Q[0] <= Din;
//            2'b01: Q[1] <= Din;
//            2'b10: Q[2] <= Din;
//            2'b11: Q[3] <= Din;
//        endcased
//    end
    
    // Calculation
    always@(posedge clk)
    begin
        // C[0]: 17 XORs and 27 DFFs
            // Stage 1
                // Group 1
                Q_S1[0][0][0] <= Q[0][0] ^ Q[0][1];
                Q_S1[0][0][1] <= Q[0][3] ^ Q[0][4];
                Q_S1[0][0][2] <= Q[0][6];
                // Group 2
                Q_S1[1][0][0] <= Q[1][0] ^ Q[1][2];
                Q_S1[1][0][1] <= Q[1][3] ^ Q[1][5];
                Q_S1[1][0][2] <= Q[1][7];
                // Group 3
                Q_S1[2][0][0] <= Q[2][1] ^ Q[2][3];
                Q_S1[2][0][1] <= Q[2][5] ^ Q[2][7];
                // Group 4
                Q_S1[3][0][0] <= Q[3][1] ^ Q[3][2];
                Q_S1[3][0][1] <= Q[3][4] ^ Q[3][6];
            // Stage 2
                // Group 1
                Q_S2[0][0][0] <= Q_S1[0][0][0];
                Q_S2[0][0][1] <= Q_S1[0][0][1] ^ Q_S1[0][0][2];
                // Group 2
                Q_S2[1][0][0] <= Q_S1[1][0][0];
                Q_S2[1][0][1] <= Q_S1[1][0][1] ^ Q_S1[1][0][2];
                // Group 3
                Q_S2[2][0][0] <= Q_S1[2][0][0] ^ Q_S1[2][0][1];
                // Group 4
                Q_S2[3][0][0] <= Q_S1[3][0][0] ^ Q_S1[3][0][1];
            // Stage 3
                // Group 1
                Q_S3[0][0] <= Q_S2[0][0][0] ^ Q_S2[0][0][1];
                // Group 2
                Q_S3[0][1] <= Q_S2[1][0][0] ^ Q_S2[1][0][1];
                // Group 3
                Q_S3[0][2] <= Q_S2[2][0][0];
                // Group 4
                Q_S3[0][3] <= Q_S2[3][0][0];
            // Latency
                Q_S3_reg[0][0] <= Q_S3[0][0];
                Q_S3_reg[0][1] <= Q_S3[0][2];
            // Stage 4
                Q_S4[0][0] <= Q_S3_reg[0][0] ^ Q_S3[0][1];
                Q_S4[0][1] <= Q_S3_reg[0][1] ^ Q_S3[0][3];
            // Latency
                Q_S4_reg[0][0] <= Q_S4[0][0];
                Q_S4_reg[0][1] <= Q_S4_reg[0][0];
            // Stage 5
                Q_S5[0] <= Q_S4_reg[0][1] ^ Q_S4[0][1];
              
        // C[1]: 17 XORs and 27 DFFs
            // Stage 1
                // Group 1
                Q_S1[0][1][0] <= Q[0][0] ^ Q[0][2];
                Q_S1[0][1][1] <= Q[0][3] ^ Q[0][5];
                Q_S1[0][1][2] <= Q[0][6];
                // Group 2
                Q_S1[1][1][0] <= Q[1][1] ^ Q[1][2];
                Q_S1[1][1][1] <= Q[1][4] ^ Q[1][5];
                // Group 3
                Q_S1[2][1][0] <= Q[2][0] ^ Q[2][1];
                Q_S1[2][1][1] <= Q[2][4] ^ Q[2][5];
                // Group 4
                Q_S1[3][1][0] <= Q[3][0] ^ Q[3][1];
                Q_S1[3][1][1] <= Q[3][3] ^ Q[3][4];
                Q_S1[3][1][2] <= Q[3][7];
            // Stage 2
                // Group 1
                Q_S2[0][1][0] <= Q_S1[0][1][0];
                Q_S2[0][1][1] <= Q_S1[0][1][1] ^ Q_S1[0][1][2];
                // Group 2
                Q_S2[1][1][0] <= Q_S1[1][1][0] ^ Q_S1[1][1][1];
                // Group 3
                Q_S2[2][1][0] <= Q_S1[2][1][0] ^ Q_S1[2][1][1];
                // Group 4
                Q_S2[3][1][0] <= Q_S1[3][1][0];
                Q_S2[3][1][1] <= Q_S1[3][1][1] ^ Q_S1[3][1][2];
            // Stage 3
                // Group 1
                Q_S3[1][0] <= Q_S2[0][1][0] ^ Q_S2[0][1][1];
                // Group 2
                Q_S3[1][1] <= Q_S2[1][1][0];
                // Group 3
                Q_S3[1][2] <= Q_S2[2][1][0];
                // Group 4
                Q_S3[1][3] <= Q_S2[3][1][0] ^ Q_S2[3][1][1];
            // Latency
                Q_S3_reg[1][0] <= Q_S3[1][0];
                Q_S3_reg[1][1] <= Q_S3[1][2];
            // Stage 4
                Q_S4[1][0] <= Q_S3_reg[1][0] ^ Q_S3[1][1];
                Q_S4[1][1] <= Q_S3_reg[1][1] ^ Q_S3[1][3];
            // Latency
                Q_S4_reg[1][0] <= Q_S4[1][0];
                Q_S4_reg[1][1] <= Q_S4_reg[1][0];
            // Stage 5
                Q_S5[1] <= Q_S4_reg[1][1] ^ Q_S4[1][1];
                
        // C[2]: 17 XORs and 27 DFFs
            // Stage 1
                // Group 1
                Q_S1[0][2][0] <= Q[0][1] ^ Q[0][2];
                Q_S1[0][2][1] <= Q[0][3] ^ Q[0][7];
                // Group 2
                Q_S1[1][2][0] <= Q[1][0] ^ Q[1][1];
                Q_S1[1][2][1] <= Q[1][2] ^ Q[1][6];
                Q_S1[1][2][2] <= Q[1][7];
                // Group 3
                Q_S1[2][2][0] <= Q[2][0] ^ Q[2][1];
                Q_S1[2][2][1] <= Q[2][6] ^ Q[2][7];
                // Group 4
                Q_S1[3][2][0] <= Q[3][0] ^ Q[3][1];
                Q_S1[3][2][1] <= Q[3][5] ^ Q[3][6];
                Q_S1[3][2][2] <= Q[3][7]; 
            // Stage 2
                // Group 1
                Q_S2[0][2][0] <= Q_S1[0][2][0] ^ Q_S1[0][2][1];
                // Group 2
                Q_S2[1][2][0] <= Q_S1[1][2][0];
                Q_S2[1][2][1] <= Q_S1[1][2][1] ^ Q_S1[1][2][2];
                // Group 3
                Q_S2[2][2][0] <= Q_S1[2][2][0] ^ Q_S1[2][2][1];
                // Group 4
                Q_S2[3][2][0] <= Q_S1[3][2][0];
                Q_S2[3][2][1] <= Q_S1[3][2][1] ^ Q_S1[3][2][2];
            // Stage 3
                // Group 1
                Q_S3[2][0] <= Q_S2[0][2][0];
                // Group 2
                Q_S3[2][1] <= Q_S2[1][2][0] ^ Q_S2[1][2][1];
                // Group 3
                Q_S3[2][2] <= Q_S2[2][2][0];
                // Group 4
                Q_S3[2][3] <= Q_S2[3][2][0] ^ Q_S2[3][2][1];
            // Latency
                Q_S3_reg[2][0] <= Q_S3[2][0];
                Q_S3_reg[2][1] <= Q_S3[2][2];
            // Stage 4
                Q_S4[2][0] <= Q_S3_reg[2][0] ^ Q_S3[2][1];
                Q_S4[2][1] <= Q_S3_reg[2][1] ^ Q_S3[2][3];
            // Latency
                Q_S4_reg[2][0] <= Q_S4[2][0];
                Q_S4_reg[2][1] <= Q_S4_reg[2][0];
            // Stage 5
                Q_S5[2] <= Q_S4_reg[2][1] ^ Q_S4[2][1];
        
        // C[3]: 14 XORs and 24 DFFs
            // Stage 1
                // Group 1
                Q_S1[0][3][0] <= Q[0][4] ^ Q[0][5];
                Q_S1[0][3][1] <= Q[0][6] ^ Q[0][7];
                // Group 2
                Q_S1[1][3][0] <= Q[1][0] ^ Q[1][1];
                Q_S1[1][3][1] <= Q[1][2];
                //Group 3
                Q_S1[2][3][0] <= Q[2][2] ^ Q[2][3];
                Q_S1[2][3][1] <= Q[2][4] ^ Q[2][5];
                Q_S1[2][3][2] <= Q[2][6] ^ Q[2][7];
                // Group 4
                Q_S1[3][3][0] <= Q[3][0] ^ Q[3][1];
            // Stage 2
                // Group 1
                Q_S2[0][3][0] <= Q_S1[0][3][0] ^ Q_S1[0][3][1];
                // Group 2
                Q_S2[1][3][0] <= Q_S1[1][3][0] ^ Q_S1[1][3][1];
                // Group 3
                Q_S2[2][3][0] <= Q_S1[2][3][0] ^ Q_S1[2][3][1];
                Q_S2[2][3][1] <= Q_S1[2][3][2];
                // Group 4
                Q_S2[3][3][0] <= Q_S1[3][3][0];
            // Stage 3
                // Group 1
                Q_S3[3][0] <= Q_S2[0][3][0];
                // Group 2
                Q_S3[3][1] <= Q_S2[1][3][0];
                // Group 3
                Q_S3[3][2] <= Q_S2[2][3][0] ^ Q_S2[2][3][1];
                // Group 4
                Q_S3[3][3] <= Q_S2[3][3][0];
            // Latency
                Q_S3_reg[3][0] <= Q_S3[3][0];
                Q_S3_reg[3][1] <= Q_S3[3][2];
            // Stage 4
                Q_S4[3][0] <= Q_S3_reg[3][0] ^ Q_S3[3][1];
                Q_S4[3][1] <= Q_S3_reg[3][1] ^ Q_S3[3][3];
            // Latency
                Q_S4_reg[3][0] <= Q_S4[3][0];
                Q_S4_reg[3][1] <= Q_S4_reg[3][0];
            // Stage 5
                Q_S5[3] <= Q_S4_reg[3][1] ^ Q_S4[3][1];
                
        // C[4]: 14 XORs and 22 DFFs
            // Stage 1
                // Group 1
                // Group 2
                Q_S1[1][4][0] <= Q[1][3] ^ Q[1][4];
                Q_S1[1][4][1] <= Q[1][5] ^ Q[1][6];
                Q_S1[1][4][2] <= Q[1][7];
                // Group 3
                Q_S1[2][4][0] <= Q[2][0] ^ Q[2][1];
                Q_S1[2][4][1] <= Q[2][2] ^ Q[2][3];
                Q_S1[2][4][2] <= Q[2][4] ^ Q[2][5];
                Q_S1[2][4][3] <= Q[2][6] ^ Q[2][7];
                // Group 4
                Q_S1[3][4][0] <= Q[3][0] ^ Q[3][1];
            // Stage 2
                // Group 1
                // Group 2
                Q_S2[1][4][0] <= Q_S1[1][4][0];
                Q_S2[1][4][1] <= Q_S1[1][4][1] ^ Q_S1[1][4][2];
                // Group 3
                Q_S2[2][4][0] <= Q_S1[2][4][0] ^ Q_S1[2][4][1];
                Q_S2[2][4][1] <= Q_S1[2][4][2] ^ Q_S1[2][4][3];
                // Group 4
                Q_S2[3][4][0] <= Q_S1[3][4][0];
            // Stage 3
                // Group 1
                // Group 2
                Q_S3[4][1] <= Q_S2[1][4][0] ^ Q_S2[1][4][1];
                // Group 3
                Q_S3[4][2] <= Q_S2[2][4][0] ^ Q_S2[2][4][1];
                // Group 4
                Q_S3[4][3] <= Q_S2[3][4][0];
            // Latency
                Q_S3_reg[4][0] <= Q_S3[4][2];
            // Stage 4
                Q_S4[4][0] <= Q_S3[4][1];
                Q_S4[4][1] <= Q_S3_reg[4][0] ^ Q_S3[4][3];
            // Latency
                Q_S4_reg[4][0] <= Q_S4[4][0];
                Q_S4_reg[4][1] <= Q_S4_reg[4][0];
            // Stage 5
                Q_S5[4] <= Q_S4_reg[4][1] ^ Q_S4[4][1];
                
        // C[5]: 5 XORs and 8 DFFs
            // Stage 1
                // Group 1
                // Group 2
                // Group 3
                // Group 4
                Q_S1[3][5][0] <= Q[3][2] ^ Q[3][3];
                Q_S1[3][5][1] <= Q[3][4] ^ Q[3][5];
                Q_S1[3][5][2] <= Q[3][6] ^ Q[3][7];
            // Stage 2
                // Group 1
                // Group 2
                // Group 3
                // Group 4
                Q_S2[3][5][0] <= Q_S1[3][5][0] ^ Q_S1[3][5][1];
                Q_S2[3][5][1] <= Q_S1[3][5][2];
            // Stage 3
                // Group 1
                // Group 2
                // Group 3
                // Group 4
                Q_S3[5][3] <= Q_S2[3][5][0] ^ Q_S2[3][5][1];
            // Stage 4
                Q_S4[5][0] <= Q_S3[5][3];
            // Stage 5
                Q_S5[5] <= Q_S4[5][0];
                
        Q_bus_buf[0][0][7:0] <= Q[0][7:0];
        Q_bus_buf[0][1][7:0] <= Q_bus_buf[0][0][7:0];
        Q_bus_buf[0][2][7:0] <= Q_bus_buf[0][1][7:0];
        Q_bus_buf[0][3][7:0] <= Q_bus_buf[0][2][7:0];
        Q_S5[13:6] <= Q_bus_buf[0][3][7:0];
//        C_reg[13:6] <= Q[0][7:0];
          
        Q_bus_buf[1][0][7:0] <= Q[1][7:0];
        Q_bus_buf[1][1][7:0] <= Q_bus_buf[1][0][7:0];
        Q_bus_buf[1][2][7:0] <= Q_bus_buf[1][1][7:0];
        Q_bus_buf[1][3][7:0] <= Q_bus_buf[1][2][7:0];
        Q_S5[21:14] <= Q_bus_buf[1][3][7:0];
//        C_reg[21:14] <= Q[1][7:0];
        
        Q_bus_buf[2][0][7:0] <= Q[2][7:0];
        Q_bus_buf[2][1][7:0] <= Q_bus_buf[2][0][7:0];
        Q_bus_buf[2][2][7:0] <= Q_bus_buf[2][1][7:0];
        Q_bus_buf[2][3][7:0] <= Q_bus_buf[2][2][7:0];
        Q_S5[29:22] <= Q_bus_buf[2][3][7:0];
//        C_reg[29:22] <= Q[2][7:0];
        
        Q_bus_buf[3][0][7:0] <= Q[3][7:0];
        Q_bus_buf[3][1][7:0] <= Q_bus_buf[3][0][7:0];
        Q_bus_buf[3][2][7:0] <= Q_bus_buf[3][1][7:0];
        Q_bus_buf[3][3][7:0] <= Q_bus_buf[3][2][7:0];
        Q_S5[37:30] <= Q_bus_buf[3][3][7:0];
//        C_reg[37:30] <= Q[3][7:0];
    end
    
    // Output
    always@(posedge clk_out)
    begin
        C_reg[0] <= Q_S5[0];
        C_reg[1] <= Q_S5[1];
        C_reg[2] <= Q_S5[2];
        C_reg[3] <= Q_S5[3];
        C_reg[4] <= Q_S5[4];
        C_reg[5] <= Q_S5[5];
        C_reg[13:6] <= Q_S5[13:6];
        C_reg[21:14] <= Q_S5[21:14];
        C_reg[29:22] <= Q_S5[29:22];
        C_reg[37:30] <= Q_S5[37:30];
    end
    
    assign C[0] = C_reg[0];
    assign C[1] = C_reg[1];
    assign C[2] = C_reg[2];
    assign C[3] = C_reg[3];
    assign C[4] = C_reg[4];
    assign C[5] = C_reg[5];
endmodule
