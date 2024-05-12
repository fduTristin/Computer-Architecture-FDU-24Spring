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
        output logic memwrite,
        output logic [31:0] adr, writedata,
        input logic [31:0] readdata
    );

    logic zero,pcen,irwrite,regwrite,alusrca,iord,memtoreg,regdst,immext;
    logic [1:0]alusrcb;
    logic [1:0]pcsrc;
    logic [2:0]alucontrol;
    logic [31:0]instr,data;

    flopr#(32) DR(clk,reset,readdata,data);
    flopenr#(32) IR(clk,reset,irwrite,readdata,instr);

    controller c(
              .clk(clk),
              .reset(reset),  
              .op(instr[31:26]),
              .funct(instr[5:0]),
              .zero(zero),
              .pcen(pcen),
              .memwrite(memwrite),
              .irwrite(irwrite),
              .regwrite(regwrite),
              .alusrca(alusrca),
              .iord(iord),
              .memtoreg(memtoreg),
              .regdst(regdst),
              .alusrcb(alusrcb),
              .pcsrc(pcsrc),
              .alucontrol(alucontrol),
              .immext(immext)
            );

    datapath dp(
                .clk(clk),
                .reset(reset),
                .pcen(pcen),
                .regwrite(regwrite),
                .alusrca(alusrca),
                .iord(iord),
                .memtoreg(memtoreg),
                .regdst(regdst),
                .alusrcb(alusrcb),
                .pcsrc(pcsrc),
                .alucontrol(alucontrol),
                .zero(zero),
                .instr(instr),
                .adr(adr),
                .writedata(writedata),
                .data(data),
                .immext(immext)
                );
endmodule
