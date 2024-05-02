`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 13:31:15
// Design Name: 
// Module Name: mips
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


module mips(
        input logic clk,reset,
        output logic [31:0] pc,
        input logic [31:0] instr,
        output logic memwrite,
        output logic [31:0] aluout, writedata,
        input logic [31:0] readdata
    );

    logic memtoreg, branch, pcsrc, zero, alusrc, regdst, regwrite, jump;

    logic [2:0] alucontrol;

    controller c(instr[31:26], instr[5:0], zero, memtoreg, memwrite, pcsrc, alusrc, regdst, regwrite, jump, alucontrol);

    datapath dp(clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump, alucontrol, zero, pc, instr, aluout, writedata, readdata);
    
endmodule
