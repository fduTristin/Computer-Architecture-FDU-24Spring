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
            input   logic       clk,reset,
            input   logic [5:0] op,funct,
            input   logic       zero,
            output  logic       pcen,memwrite,irwrite,regwrite,
            output  logic       alusrca,iord,memtoreg,regdst,
            output  logic       [1:0]alusrcb,pcsrc,
            output  logic [2:0] alucontrol,
            output  logic       immext
        );
    
    logic [2:0] aluop;
    logic       branchbeq,branchbne,pcwrite;
    
    maindec md(.clk(clk),
                .reset(reset),
                .op(op),
                .pcwrite(pcwrite),
                .memwrite(memwrite),
                .irwrite(irwrite),
                .regwrite(regwrite),
                .alusrca(alusrca),
                .iord(iord),
                .memtoreg(memtoreg),
                .regdst(regdst), 
                .alusrcb(alusrcb),
                .pcsrc(pcsrc),
                .branchbeq(branchbeq),
                .branchbne(branchbne),
                .aluop(aluop),
                .immext(immext));
               
    aludec ad (.funct(funct),
               .aluop(aluop),
               .alucontrol(alucontrol));
               
               assign pcen = (branchbeq & zero)|(branchbne & !zero)|pcwrite;
    
endmodule
