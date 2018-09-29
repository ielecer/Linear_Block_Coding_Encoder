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
// Description: (n, k) = (38, 32)
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
    input [8:1] Din,
    output [8:1] Qout1,
    output [8:1] Qout2,
    output [8:1] Qout3,
    output [8:1] Qout4,
    output [38:1] Cout
    );
    reg [38:1] Cout;
    
    reg [8:1] Q[4:1];
    reg Q_buf[4:1][6:1][6:1];
    
    reg C1[6:1][4:1];
    reg C1_buf[6:1][2:1];
    
    reg [8:1] Q_bus_buf[4:1][4:1];
    
    reg [1:0] select = 2'b00;
    
    assign Qout1 = Q[1];
    assign Qout2 = Q[2];
    assign Qout3 = Q[3];
    assign Qout4 = Q[4];
    
    // FSM
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
            2'b00: Q[1] <= Din;
            2'b01: Q[2] <= Din;
            2'b10: Q[3] <= Din;
            2'b11: Q[4] <= Din;
        endcase
    end
    
    always@(posedge clk)
    begin
        // First stage calculation
        // Q[1]
        Q_buf[1][1][1] <= Q[1][1] ^ Q[1][2];
        Q_buf[1][1][2] <= Q[1][4] ^ Q[1][5];
        Q_buf[1][1][3] <= Q[1][7];
        Q_buf[1][1][4] <= Q_buf[1][1][1];
        Q_buf[1][1][5] <= Q_buf[1][1][2] ^ Q_buf[1][1][3];
        
        Q_buf[1][2][1] <= Q[1][1] ^ Q[1][3];
        Q_buf[1][2][2] <= Q[1][4] ^ Q[1][6];
        Q_buf[1][2][3] <= Q[1][7];
        Q_buf[1][2][4] <= Q_buf[1][2][1];
        Q_buf[1][2][5] <= Q_buf[1][2][2] ^ Q_buf[1][2][3];
        
        Q_buf[1][3][1] <= Q[1][2] ^ Q[1][3];
        Q_buf[1][3][2] <= Q[1][4] ^ Q[1][8];
        Q_buf[1][3][3] <= Q_buf[1][3][1] ^ Q_buf[1][3][2];
        
        Q_buf[1][4][1] <= Q[1][5] ^ Q[1][6];
        Q_buf[1][4][2] <= Q[1][7] ^ Q[1][8];
        Q_buf[1][4][3] <= Q_buf[1][4][1] ^ Q_buf[1][4][2];
        
        // Q[2]
        Q_buf[2][1][1] <= Q[2][1] ^ Q[2][3];
        Q_buf[2][1][2] <= Q[2][4] ^ Q[2][6];
        Q_buf[2][1][3] <= Q[2][8];
        Q_buf[2][1][4] <= Q_buf[2][1][1];
        Q_buf[2][1][5] <= Q_buf[2][1][2] ^ Q_buf[2][1][3];
        
        Q_buf[2][2][1] <= Q[2][2] ^ Q[2][3];
        Q_buf[2][2][2] <= Q[2][5] ^ Q[2][6];
        Q_buf[2][2][3] <= Q_buf[2][2][1] ^ Q_buf[2][2][2];
        
        Q_buf[2][3][1] <= Q[2][1] ^ Q[2][2];
        Q_buf[2][3][2] <= Q[2][3] ^ Q[2][7];
        Q_buf[2][3][3] <= Q[2][8];
        Q_buf[2][3][4] <= Q_buf[2][3][1];
        Q_buf[2][3][5] <= Q_buf[2][3][2] ^ Q_buf[2][3][3];
        
        Q_buf[2][4][1] <= Q[2][1] ^ Q[2][2];
        Q_buf[2][4][2] <= Q[2][3];
        Q_buf[2][4][3] <= Q_buf[2][4][1] ^ Q_buf[2][4][2];
        
        Q_buf[2][5][1] <= Q[2][4] ^ Q[2][5];
        Q_buf[2][5][2] <= Q[2][6] ^ Q[2][7];
        Q_buf[2][5][3] <= Q[2][8];
        Q_buf[2][5][4] <= Q_buf[2][5][1];
        Q_buf[2][5][5] <= Q_buf[2][5][2] ^ Q_buf[2][5][3];
        
        // Q[3]
        Q_buf[3][1][1] <= Q[3][2] ^ Q[3][4];
        Q_buf[3][1][2] <= Q[3][6] ^ Q[3][8];
        Q_buf[3][1][3] <= Q_buf[3][1][1] ^ Q_buf[3][1][2];
        
        Q_buf[3][2][1] <= Q[3][1] ^ Q[3][2];
        Q_buf[3][2][2] <= Q[3][5] ^ Q[3][6];
        Q_buf[3][2][3] <= Q_buf[3][2][1] ^ Q_buf[3][2][2];
        
        Q_buf[3][3][1] <= Q[3][1] ^ Q[3][2];
        Q_buf[3][3][2] <= Q[3][7] ^ Q[3][8];
        Q_buf[3][3][3] <= Q_buf[3][3][1] ^ Q_buf[3][3][2];
        
        Q_buf[3][4][1] <= Q[3][3] ^ Q[3][4];
        Q_buf[3][4][2] <= Q[3][5] ^ Q[3][6];
        Q_buf[3][4][3] <= Q[3][7] ^ Q[3][8];
        Q_buf[3][4][4] <= Q_buf[3][4][1] ^ Q_buf[3][4][2];
        Q_buf[3][4][5] <= Q_buf[3][4][3];
        
        Q_buf[3][5][1] <= Q[3][1] ^ Q[3][2];
        Q_buf[3][5][2] <= Q[3][3] ^ Q[3][4];
        Q_buf[3][5][3] <= Q[3][5] ^ Q[3][6];
        Q_buf[3][5][4] <= Q[3][7] ^ Q[3][8];
        Q_buf[3][5][5] <= Q_buf[3][5][1] ^ Q_buf[3][5][2];
        Q_buf[3][5][6] <= Q_buf[3][5][3] ^ Q_buf[3][5][4];
        
        // Q[4]
        Q_buf[4][1][1] <= Q[4][2] ^ Q[4][3];
        Q_buf[4][1][2] <= Q[4][5] ^ Q[4][7];
        Q_buf[4][1][3] <= Q_buf[4][1][1] ^ Q_buf[4][1][2];
        
        Q_buf[4][2][1] <= Q[4][1] ^ Q[4][2];
        Q_buf[4][2][2] <= Q[4][4] ^ Q[4][5];
        Q_buf[4][2][3] <= Q[4][8];
        Q_buf[4][2][4] <= Q_buf[4][2][1];
        Q_buf[4][2][5] <= Q_buf[4][2][2] ^ Q_buf[4][2][3];
        
        Q_buf[4][3][1] <= Q[4][1] ^ Q[4][2];
        Q_buf[4][3][2] <= Q[4][6] ^ Q[4][7];
        Q_buf[4][3][3] <= Q[4][8];
        Q_buf[4][3][4] <= Q_buf[4][3][1];
        Q_buf[4][3][5] <= Q_buf[4][3][2] ^ Q_buf[4][3][3];
        
        Q_buf[4][4][1] <= Q[4][1];
        Q_buf[4][4][2] <= Q[4][2];
        Q_buf[4][4][3] <= Q_buf[4][4][1] ^ Q_buf[4][4][2];
        
        Q_buf[4][5][1] <= Q[4][1];
        Q_buf[4][5][2] <= Q[4][2];
        Q_buf[4][5][3] <= Q_buf[4][5][1] ^ Q_buf[4][5][2];
        
        Q_buf[4][6][1] <= Q[4][3] ^ Q[4][4];
        Q_buf[4][6][2] <= Q[4][5] ^ Q[4][6];
        Q_buf[4][6][3] <= Q[4][7] ^ Q[4][8];
        Q_buf[4][6][4] <= Q_buf[4][6][1] ^ Q_buf[4][6][2];
        Q_buf[4][6][5] <= Q_buf[4][6][3];
        
        // Second stage calculation
        C1[1][1] <= Q_buf[1][1][4] ^ Q_buf[1][1][5];
        C1[2][1] <= Q_buf[1][2][4] ^ Q_buf[1][2][5];
        C1[3][1] <= Q_buf[1][3][3];
        C1[4][1] <= Q_buf[1][4][3];
        
        C1[1][2] <= Q_buf[2][1][4] ^ Q_buf[2][1][5];
        C1[2][2] <= Q_buf[2][2][3];
        C1[3][2] <= Q_buf[2][3][4] ^ Q_buf[2][3][5];
        C1[4][2] <= Q_buf[2][4][3];
        C1[5][2] <= Q_buf[2][5][4] ^ Q_buf[2][5][5];
        
        C1[1][3] <= Q_buf[3][1][3];
        C1[2][3] <= Q_buf[3][2][3];
        C1[3][3] <= Q_buf[3][3][3];
        C1[4][3] <= Q_buf[3][4][4] ^ Q_buf[3][4][5];
        C1[5][3] <= Q_buf[3][5][5] ^ Q_buf[3][5][6];
        
        C1[1][4] <= Q_buf[4][1][3];
        C1[2][4] <= Q_buf[4][2][4] ^ Q_buf[4][2][5];
        C1[3][4] <= Q_buf[4][3][4] ^ Q_buf[4][3][5];
        C1[4][4] <= Q_buf[4][4][3];
        C1[5][4] <= Q_buf[4][5][3];
        C1[6][4] <= Q_buf[4][6][4] ^ Q_buf[4][6][5];
        
        // Third stage calculation
        C1_buf[1][1] <= C1[1][1] ^ C1[1][2];
        C1_buf[1][2] <= C1[1][3] ^ C1[1][4];
        Cout[1] <= C1_buf[1][1] ^ C1_buf[1][2];
        
        C1_buf[2][1] <= C1[2][1] ^ C1[2][2];
        C1_buf[2][2] <= C1[2][3] ^ C1[2][4];
        Cout[2] <= C1_buf[2][1] ^ C1_buf[2][2];
        
        C1_buf[3][1] <= C1[3][1] ^ C1[3][2];
        C1_buf[3][2] <= C1[3][3] ^ C1[3][4];
        Cout[3] <= C1_buf[3][1] ^ C1_buf[3][2];
        
        C1_buf[4][1] <= C1[4][1] ^ C1[4][2];
        C1_buf[4][2] <= C1[4][3] ^ C1[4][4];
        Cout[4] <= C1_buf[4][1] ^ C1_buf[4][2];
        
        C1_buf[5][1] <= C1[5][2] ^ C1[5][3];
        C1_buf[5][2] <= C1[5][4];
        Cout[5] <= C1_buf[5][1] ^ C1_buf[5][2];
        
        C1_buf[6][1] <= C1[6][4];
        Cout[6] <= C1_buf[6][1];
        
        // 
        Q_bus_buf[1][1][8:1] <= Q[1][8:1];
        Q_bus_buf[1][2][8:1] <= Q_bus_buf[1][1][8:1];
        Q_bus_buf[1][3][8:1] <= Q_bus_buf[1][2][8:1];
        Q_bus_buf[1][4][8:1] <= Q_bus_buf[1][3][8:1];
        Cout[14:7] <= Q_bus_buf[1][4][8:1];
        
        Q_bus_buf[2][1][8:1] <= Q[2][8:1];
        Q_bus_buf[2][2][8:1] <= Q_bus_buf[2][1][8:1];
        Q_bus_buf[2][3][8:1] <= Q_bus_buf[2][2][8:1];
        Q_bus_buf[2][4][8:1] <= Q_bus_buf[2][3][8:1];
        Cout[22:15] <= Q_bus_buf[2][4][8:1];
        
        Q_bus_buf[3][1][8:1] <= Q[3][8:1];
        Q_bus_buf[3][2][8:1] <= Q_bus_buf[3][1][8:1];
        Q_bus_buf[3][3][8:1] <= Q_bus_buf[3][2][8:1];
        Q_bus_buf[3][4][8:1] <= Q_bus_buf[3][3][8:1];
        Cout[30:23] <= Q_bus_buf[3][4][8:1];
        
        Q_bus_buf[4][1][8:1] <= Q[4][8:1];
        Q_bus_buf[4][2][8:1] <= Q_bus_buf[4][1][8:1];
        Q_bus_buf[4][3][8:1] <= Q_bus_buf[4][2][8:1];
        Q_bus_buf[4][4][8:1] <= Q_bus_buf[4][3][8:1];
        Cout[38:31] <= Q_bus_buf[4][4][8:1];
    end
endmodule
