`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 13:31:15
// Design Name: 
// Module Name: controller
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


module controller(
        input logic [5:0] op, funct,
        input logic zero,
        output logic memtoreg, memwrite, pcsrc, alusrc, regdst, regwrite, jump,
        output logic [2:0] alucontrol
    );

    logic [2:0] aluop;
    logic branchbeq,branchbne;

    maindec md(op, memtoreg, memwrite, branchbeq, branchbne, alusrc, regdst, regwrite, jump, aluop);
    aludec ad(funct, aluop, alucontrol);

    assign pcsrc = (branchbeq & zero) | (branchbne & !zero);
endmodule
