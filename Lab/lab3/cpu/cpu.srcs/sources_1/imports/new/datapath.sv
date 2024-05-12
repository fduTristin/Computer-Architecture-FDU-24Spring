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
    input  logic clk,reset,
    input  logic pcen,regwrite,
    input  logic alusrca,iord,memtoreg,regdst,
    input  logic [1:0]alusrcb,
    input  logic [1:0]pcsrc,
    input  logic [2:0]alucontrol,
    output logic zero,
    input  logic [31:0]instr,
    output logic [31:0]adr,writedata,
    input  logic [31:0]data,
    input  logic immext
    );

    logic [4:0]a1,a2,a3;
    logic [31:0]pc,nextpc,aluout,wd3,rd1,rd2,a,b,srca,srcb,four,signimm,signimmsl2,aluresult,pcjump,instrsl2;

    assign a1 = instr[25:21];
    assign a2 = instr[20:16];
    // pc update

    flopenr #(32) pcreg(.clk(clk),
                    .reset(reset),
                    .en(pcen),
                    .d(nextpc),
                    .q(pc));
    // memader
    MUX2 #(32)  m0(.d0(pc),
                  .d1(aluout),
                  .s(iord),
                  .y(adr));
    // regdst
    MUX2 #(5)   m1(.d0(instr[20:16]),
                .d1(instr[15:11]),
                .s(regdst),
                .y(a3));
    // memtoreg
    MUX2 #(32)  m2(.d0(aluout),
                 .d1(data),
                 .s(memtoreg),
                 .y(wd3));
    // regfile
    REGFILE rf(.clk(clk),
               .we3(regwrite),
               .ra1(a1), 
               .ra2(a2),
               .wa3(a3),
               .wd3(wd3),
               .rd1(rd1),
               .rd2(rd2));

    flopr #(32) A(.clk(clk),
                  .reset(reset),
                  .d(rd1),
                  .q(a));

    flopr #(32) B(.clk(clk),
                  .reset(reset),
                  .d(rd2),
                  .q(b));
    
    assign writedata = b;

    MUX2 #(32)  m3(.d0(pc),
                  .d1(a),
                  .s(alusrca),
                  .y(srca));
                  
    assign four=8'h0000_0004;

    signext sn(.a(instr[15:0]),
               .y(signimm),
               .immext(immext));

    sl2 sl21 (.x(signimm),
              .y(signimmsl2));
             
    MUX4 #(32) m4(.d0(b),
                 .d1(four),
                 .d2(signimm),
                 .d3(signimmsl2),
                 .s(alusrcb),
                 .y(srcb));

    ALU alu (.a(srca),
             .b(srcb),
             .alucont(alucontrol),
             .result(aluresult),
             .zero(zero));

    flopr #(32) f5(.clk(clk),
                  .reset(reset),
                  .d(aluresult),
                  .q(aluout));

    sl2 sl22 (.x({6'b000000,instr[25:0]}),
              .y(instrsl2));

    assign pcjump={pc[31:28],instrsl2[27:0]};

    MUX4 #(32) m5(.d0(aluresult),
                 .d1(aluout),
                 .d2(pcjump),
                 .d3(pcjump),
                 .s(pcsrc),
                 .y(nextpc));

endmodule
