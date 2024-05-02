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

    logic [31:0] pc, instr, readdata;

    mips mips1(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);
    IMEM imem(pc[7:2], instr);
    DMEM dmem(clk, memwrite, dataadr, writedata, readdata);
    
endmodule
