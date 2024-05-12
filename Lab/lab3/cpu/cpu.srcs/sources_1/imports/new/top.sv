`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 13:31:15
// Design Name: 
// Module Name: top
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


module top(
        input logic clk, reset,
        output logic [31:0] writedata, dataadr,
        output logic memwrite
    );

    logic [31:0] readdata;

    mips mips1(clk, reset, memwrite, dataadr, writedata, readdata);
    MEM mem(clk, memwrite, dataadr, writedata, readdata);
endmodule
