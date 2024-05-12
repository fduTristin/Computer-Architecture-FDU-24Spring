`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 09:12:04
// Design Name: 
// Module Name: ALU
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


module ALU(input  logic  [31:0] a,b,
           input  logic  [2:0] alucont,
           output logic  [31:0] result,
           output logic zero);
          
    always_comb
    case(alucont)
    3'b010:result = a + b;
    3'b110:result = a - b;
    3'b000:result = a & b;
    3'b001:result = a | b;
    3'b111:result = ((a < b) ? 1 : 0);
    endcase
    
    assign zero = result == 0;
endmodule
