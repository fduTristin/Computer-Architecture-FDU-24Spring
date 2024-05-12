`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 00:38:51
// Design Name: 
// Module Name: MEM
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


module MEM(
        input logic clk,we,
        input logic [31:0]a,wd,
        output logic [31:0]rd
        );

    logic [31:0]RAM[63:0];

    initial $readmemh("testIO.dat",RAM);

    assign rd=RAM[a[31:2]];

    always_ff@(posedge clk) 
        if(we) RAM[a[31:2]]<=wd;
        
endmodule
