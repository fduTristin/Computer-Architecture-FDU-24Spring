`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 14:06:05
// Design Name: 
// Module Name: topmips
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


module topmips(
    input logic CLK100MHZ,
    input logic BTNC,
    input logic BTNL,
    input logic BTNR,
    output logic [1:0]LED,
    input logic [15:0]SW,
    output logic [7:0]AN,
    output logic [6:0]A2G
    );

    logic Write;
    logic [31:0] dataAdr,writeData,readData;
//    mips mips(
//    CLK100MHZ,BTNC,write,dataadr,writedata,readdata);

    mips mips2(.clk(CLK100MHZ),
              .reset(BTNC),
              .memwrite(Write),
              .adr(dataAdr),
              .writedata(writeData),
              .readdata(readData));
              
    dMemoryDecoder mdecoder(.clk(CLK100MHZ),
                           .writeEN(Write),
                           .addr(dataAdr[7:0]),
                           .writeData(writeData),
                           .readData(readData),
                           .reset(BTNC),
                           .btnL(BTNL),
                           .btnR(BTNR),
                           .switch(SW),
                           .an(AN),
                           .a2g(A2G));
      assign LED[0] = BTNR;
      assign LED[1] = BTNL;

endmodule