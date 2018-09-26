`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Electronic Science and Technology of China
// Engineer: Yajun Mei
// 
// Create Date: 09/21/2018 09:55:46 PM
// Design Name: 
// Module Name: encoder
// Project Name: Encoder_for_linear_block_coding
// Target Devices: Zynq UltraScale+ ZCU102 Evaluation Board (xczu9eg-ffvb1156-2-e)
// Tool Versions: Vivado 2018.2.1
// Description: 
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
    input [8:1] D,
    output [38:1] C
    );
    reg [38:1] C;
    reg [1:0] select = 2'b00;
    reg [8:1] Q[4:1];
    wire Z[6:1][4:1];
    
    wire Q4_12;
    wire Q2_12;
    
    // Q[4]
    wire Q64_buf[2:1];
    wire Q54_buf[2:1];
    wire Q44_buf[2:1];
    wire Q14_buf[4:1];
        
    // Q[3]
    wire Q63_buf[2:1];
    wire Q53_buf[2:1];
    wire Q43_buf[2:1];
    wire Q33_buf[4:1];
    wire Q23_buf[6:1];
        
    // Q[2]
    wire Q62_buf[3:1];
    wire Q52_buf[2:1];
    wire Q42_buf[3:1];
    wire Q32_buf;
    wire Q22_buf[3:1];
    
    // Q[1]
    wire Q61_buf[3:1];
    wire Q51_buf[3:1];
    wire Q41_buf[2:1];
    wire Q31_buf[2:1];
    
    wire Z6_buf[2:1];
    wire Z5_buf[2:1];
    wire Z4_buf[2:1];
    wire Z3_buf[2:1];
    wire Z2_buf;
    
    wire C_buf[6:1];
    
    // FSM for demux
    always@(posedge clk)
    begin
        case(select)
            2'b00: select <= 2'b01;
            2'b01: select <= 2'b10;
            2'b10: select <= 2'b11;
            2'b11: select <= 2'b00;
        endcase
    end
    
    // 1-to-4 demux
    always@(posedge clk)
    begin
        case(select)
            2'b00: Q[4] <= D;
            2'b01: Q[3] <= D;
            2'b10: Q[2] <= D;
            2'b11: Q[1] <= D;
        endcase
    end
        
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Q[4]
    // Q[6][4]
    assign Q64_buf[1] = Q[4][2] ^ Q[4][3];
    assign Q64_buf[2] = Q64_buf[1] ^ Q[4][5];
    assign Z[6][4] = Q64_buf[2] ^ Q[4][7];
    // Common use
    assign Q4_12 = Q[4][1] ^ Q[4][2];
    // Q[5][4]
    assign Q54_buf[1] = Q4_12 ^ Q[4][4];
    assign Q54_buf[2] = Q54_buf[1] ^ Q[4][5];
    assign Z[5][4] = Q54_buf[2] ^ Q[4][8];
    // Z[4][4]
    assign Q44_buf[1] = Q4_12 ^ Q[4][6];
    assign Q44_buf[2] = Q44_buf[1] ^ Q[4][7];
    assign Z[4][4] = Q44_buf[2] ^ Q[4][8];
    // Z[3][4]
    assign Z[3][4] = Q4_12;
    // Z[2][4]
    assign Z[2][4] = Q4_12;
    // Z[1][4]
    assign Q14_buf[1] = Q[4][3] ^ Q[4][4];
    assign Q14_buf[2] = Q14_buf[1] ^ Q[4][5];
    assign Q14_buf[3] = Q14_buf[2] ^ Q[4][6];
    assign Q14_buf[4] = Q14_buf[3] ^ Q[4][7];
    assign Z[1][4] = Q14_buf[4] ^ Q[4][8];
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Q[3]
    // Z[6][3]
    assign Q63_buf[1] = Q[3][2] ^ Q[3][4];
    assign Q63_buf[2] = Q63_buf[2] ^ Q[3][6];
    assign Z[6][3] = Q63_buf[2] ^ Q[3][8];
    // Z[5][3]
    assign Q53_buf[1] = Q[3][1] ^ Q[3][2];
    assign Q53_buf[2] = Q53_buf[1] ^ Q[3][5];
    assign Z[5][3] = Q53_buf[2] ^ Q[3][6];
    // Z[4][3]
    assign Q43_buf[1] = Q[3][1] ^ Q[3][2];
    assign Q43_buf[2] = Q43_buf[1] ^ Q[3][7];
    assign Z[4][3] = Q43_buf[2] ^ Q[3][8];
    // Z[3][3]
    assign Q33_buf[1] = Q[3][3] ^ Q[3][4];
    assign Q33_buf[2] = Q33_buf[1] ^ Q[3][5];
    assign Q33_buf[3] = Q33_buf[2] ^ Q[3][6];
    assign Q33_buf[4] = Q33_buf[3] ^ Q[3][7];
    assign Z[3][3] = Q33_buf[4] ^ Q[3][8];
    // Z[2][3]
    assign Q23_buf[1] = Q[3][1] ^ Q[3][2];
    assign Q23_buf[2] = Q23_buf[1] ^ Q[3][3];
    assign Q23_buf[3] = Q23_buf[2] ^ Q[3][4];
    assign Q23_buf[4] = Q23_buf[3] ^ Q[3][5];
    assign Q23_buf[5] = Q23_buf[4] ^ Q[3][6];
    assign Q23_buf[6] = Q23_buf[5] ^ Q[3][7];
    assign Z[2][3] = Q23_buf[6] ^ Q[3][8];
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Q[2]
    // Z[6][2]
    assign Q62_buf[1] = Q[2][1] ^ Q[2][3];
    assign Q62_buf[2] = Q62_buf[1] ^ Q[2][4];
    assign Q62_buf[3] = Q62_buf[2] ^ Q[2][6];
    assign Z[6][2] = Q62_buf[3] ^ Q[2][8];
    // Z[5][2]
    assign Q52_buf[1] = Q[2][2] ^ Q[2][3];
    assign Q52_buf[2] = Q52_buf[1] ^ Q[2][5];
    assign Z[5][2] = Q52_buf[2] ^ Q[2][6];
    // Common use
    assign Q2_12 = Q[2][1] ^ Q[2][2];
    // Z[4][2]
    assign Q42_buf[1] = Q2_12;
    assign Q42_buf[2] = Q42_buf[1] ^ Q[2][3];
    assign Q42_buf[3] = Q42_buf[2] ^ Q[2][7];
    assign Z[4][2] = Q42_buf[3] ^ Q[2][8];
    // Z[3][2]
    assign Q32_buf = Q2_12;
    assign Z[3][2] = Q32_buf ^ Q[2][3];
    // Z[2][2]
    assign Q22_buf[1] = Q[2][4] ^ Q[2][5];
    assign Q22_buf[2] = Q22_buf[1] ^ Q[2][6];
    assign Q22_buf[3] = Q22_buf[2] ^ Q[2][7];
    assign Z[2][2] = Q22_buf[3] ^ Q[2][8];
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // Q[1]
    // Z[6][1]
    assign Q61_buf[1] = Q[1][1] ^ Q[1][2];
    assign Q61_buf[2] = Q61_buf[1] ^ Q[1][4];
    assign Q61_buf[3] = Q61_buf[2] ^ Q[1][5];
    assign Z[6][1] = Q61_buf[3] ^ Q[1][7];
    // Z[5][1]
    assign Q51_buf[1] = Q[1][1] ^ Q[1][3];
    assign Q51_buf[2] = Q51_buf[1] ^ Q[1][4];
    assign Q51_buf[3] = Q51_buf[2] ^ Q[1][6];
    assign Z[5][1] = Q51_buf[3] ^ Q[1][7];
    // Z[4][1]
    assign Q41_buf[1] = Q[1][2] ^ Q[1][3];
    assign Q41_buf[2] = Q41_buf[1] ^ Q[1][4];
    assign Z[4][1] = Q41_buf[2] ^ Q[1][8];
    // Z[3][1]
    assign Q31_buf[1] = Q[1][5] ^ Q[1][6];
    assign Q31_buf[2] = Q31_buf[1] ^ Q[1][7];
    assign Z[3][1] = Q31_buf[2] ^ Q[1][8];
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // C_buf[6]
    assign Z6_buf[1] = Z[6][1] ^ Z[6][2];
    assign Z6_buf[2] = Z6_buf[1] ^ Z[6][3];
    assign C_buf[6] = Z6_buf[2] ^ Z[6][4];
    
    // C_buf[5]
    assign Z5_buf[1] = Z[5][1] ^ Z[5][2];
    assign Z5_buf[2] = Z5_buf[1] ^ Z[5][3];
    assign C_buf[5] = Z5_buf[2] ^ Z[5][4];
    
    // C_buf[4]
    assign Z4_buf[1] = Z[4][1] ^ Z[4][2];
    assign Z4_buf[2] = Z4_buf[1] ^ Z[4][3];
    assign C_buf[4] = Z4_buf[2] ^ Z[4][4];
    
    // C_buf[3]
    assign Z3_buf[1] = Z[3][1] ^ Z[3][2];
    assign Z3_buf[2] = Z3_buf[1] ^ Z[3][3];
    assign C_buf[3] = Z3_buf[2] ^ Z[3][4];
    
    // C_buf[2]
    assign Z2_buf = Z[2][2] ^ Z[2][3];
    assign C_buf[2] = Z2_buf ^ Z[2][4];

    // C_buf[1]
    assign C_buf[1] = Z[1][4];
    
    always@(posedge clk)
    begin
        C[38:31] <= Q[4][8:1];
        C[30:23] <= Q[3][8:1];
        C[22:15] <= Q[2][8:1];
        C[14:7] <= Q[1][8:1];
        
        C[6] <= C_buf[6];
        C[5] <= C_buf[5];
        C[4] <= C_buf[4];
        C[3] <= C_buf[3];
        C[2] <= C_buf[2];
        C[1] <= C_buf[1];
    end
endmodule
