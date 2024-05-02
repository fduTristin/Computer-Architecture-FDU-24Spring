`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 13:31:15
// Design Name: 
// Module Name: datapath
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


module datapath(
        input logic clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,
        input logic [2:0] alucontrol,
        output logic zero,
        output logic [31:0] pc,
        input logic [31:0] instr,
        output logic [31:0] aluout, writedata,
        input logic [31:0] readdata
    );

    logic [4:0] writereg;
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
    logic [31:0] signimm, signimmsh;
    logic [31:0] srca, srcb;
    logic [31:0] result;

    flopr #(32) pcreg(clk, reset, pcnext, pc);
    Adder pcadd1(pc, 32'b100, pcplus4);
    sl2 immsh (signimm,signimmsh);
    Adder pcadd2(pcplus4, signimmsh, pcbranch);
    MUX2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
    MUX2 #(32) pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, jump, pcnext);

    REGFILE rf(clk, regwrite, instr[25:21], instr[20:16], writereg, result, srca, writedata);
    MUX2 #(5) wrmux(instr[20:16], instr[15:11], regdst, writereg);
    MUX2 #(32) resmux(aluout, readdata, memtoreg, result);
    signext se(instr[15:0], signimm);

    MUX2 #(32) srcbmux(writedata, signimm, alusrc, srcb);
    ALU alu(srca, srcb, alucontrol, aluout, zero);
endmodule
