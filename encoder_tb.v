`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2018 11:14:45 AM
// Design Name: 
// Module Name: encoder_tb
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


module encoder_tb();

    reg clk;
    reg [31:0] Din;
    wire [7:0] D[3:0];
    wire clk_test;
    wire [5:0] C;
    encoder M1(
        .clk(clk),
        .Din(Din),
        .Qout1(D[0]),
        .Qout2(D[1]),
        .Qout3(D[2]),
        .Qout4(D[3]),
        .clk_test(clk_test),
        .C(C)
        );
    
    // 100MHz
    parameter PERIOD = 10;
    initial clk = 1'b0;
    always begin
        #(PERIOD/2) clk = ~clk;
    end
    
    integer i;
    initial begin
        Din = 0;
        #10 Din = 0;
        #10 Din = 0;
        #10 Din = 0;
        for(i = 1; i < 256; i = i + 1)      // illegal to use i++
            begin
                #10 Din = i;
                #10 Din = 0;
                #10 Din = 0;
                #10 Din = 0;
            end
    end
endmodule
