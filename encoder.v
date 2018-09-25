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
    input [8:1] D[4:1],
    output [38:1] C
    );
    reg [38:1] C;
    wire Z[6:1][4:1];
    
    assign Z[6][1] = D[1][1] ^ D[1][2] ^ D[1][4] ^ D[1][5] ^ D[1][7];
    assign Z[6][2] = D[2][1] ^ D[2][3] ^ D[2][4] ^ D[2][6] ^ D[2][8];
    assign Z[6][3] = D[3][2] ^ D[3][4] ^ D[3][6] ^ D[3][8];
    assign Z[6][4] = D[4][2] ^ D[4][3] ^ D[4][5] ^ D[4][7];
    
    assign Z[5][1] = D[1][1] ^ D[1][3] ^ D[1][4] ^ D[1][6] ^ D[1][7];
    assign Z[5][2] = D[2][2] ^ D[2][3] ^ D[2][5] ^ D[2][6];
    assign Z[5][3] = D[3][1] ^ D[3][2] ^ D[3][5] ^ D[5][6];
    assign Z[5][4] = D[4][1] ^ D[4][2] ^ D[4][4] ^ D[4][5] ^ D[4][8];
    
    assign Z[4][1] = D[1][2] ^ D[1][3] ^ D[1][4] ^ D[1][8];
    assign Z[4][2] = D[2][1] ^ D[2][2] ^ D[2][3] ^ D[2][7] ^ D[2][8];
    assign Z[4][3] = D[3][1] ^ D[3][2] ^ D[3][7] ^ D[3][8];
    assign Z[4][4] = D[4][1] ^ D[4][2] ^ D[4][6] ^ D[4][7] ^ D[4][8];
    
    assign Z[3][1] = D[1][5] ^ D[1][6] ^ D[1][7] ^ D[1][8];
    assign Z[3][2] = D[2][1] ^ D[2][2] ^ D[2][3];
    assign Z[3][3] = D[3][3] ^ D[3][4] ^ D[3][5] ^ D[3][6] ^ D[3][7] ^ D[3][8];
    assign Z[3][4] = D[4][1] ^ D[4][2];
    
    assign Z[2][2] = D[2][4] ^ D[2][5] ^ D[2][6] ^ D[2][7] ^ D[2][8];
    assign Z[2][3] = D[3][1] ^ D[3][2] ^ D[3][3] ^ D[3][4] ^ D[3][5] ^ D[3][6] ^ D[3][7] ^ D[3][8];
    assign Z[2][4] = D[4][1] ^ D[4][2];
    
    assign Z[1][4] = D[4][3] ^ D[4][4] ^ D[4][5] ^ D[4][6] ^ D[4][7] ^ D[4][8];
    
    always@(posedge clk)
    begin
        C[38:31] <= D[4][8:1];
        C[30:23] <= D[3][8:1];
        C[22:15] <= D[2][8:1];
        C[14:7] <= D[1][8:1];
        
        C[6] <= Z[6][1] ^ Z[6][2] ^ Z[6][3] ^ Z[6][4];
        C[5] <= Z[5][1] ^ Z[5][2] ^ Z[5][3] ^ Z[5][4];
        C[4] <= Z[4][1] ^ Z[4][2] ^ Z[4][3] ^ Z[4][4];
        C[3] <= Z[3][1] ^ Z[3][2] ^ Z[3][3] ^ Z[3][4];
        C[2] <= Z[2][1] ^ Z[2][2] ^ Z[2][3] ^ Z[2][4];
        C[1] <= Z[1][1] ^ Z[1][2] ^ Z[1][3] ^ Z[1][4];
    end
endmodule
