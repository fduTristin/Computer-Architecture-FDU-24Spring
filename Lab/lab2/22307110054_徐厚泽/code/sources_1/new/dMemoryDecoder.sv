`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 14:06:05
// Design Name: 
// Module Name: dMemoryDecoder
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


module dMemoryDecoder(
    input logic clk,
    input logic writeEN,
    input logic [7:0]addr,
    input logic [31:0]writeData,
    output logic [31:0]readData,
    input logic reset,
    input logic btnL,
    input logic btnR,
    input logic [15:0]switch,
    output logic[7:0]an,
    output logic [6:0]a2g
    );
    logic [31:0]readData1,readData2;
    logic [11:0]led;
    logic pread,pwrite,mwrite;
    assign pread=(addr[7])?1:0;
    assign pwrite=(addr[7])?writeEN:0;
    assign mwrite=(addr[7]==0)?writeEN:0;
    assign readData=(addr[7]==1)?readData2:readData1;
    
    DMEM dmemory(.clk(clk),
         .we(mwrite),
         .a(addr),
         .wd(writeData),
         .rd(readData1));
   
   
    IO io(.clk(clk),
          .reset(reset),
          .pRead(pread),
          .pWrite(pwrite),
          .addr(addr[3:2]),
          .pWriteData(writeData[11:0]),
          .pReadData(readData2),//output
          .buttonL(btnL),
          .buttonR(btnR),
          .switch(switch),
          .led(led));//output  
    //logic [31:0]
    mux7seg mux7seg(.t({switch,4'b0000,led}),
                    .clk(clk),
                    .reset(reset),
                    .a2g(a2g),
                    .an(an));
    
endmodule
