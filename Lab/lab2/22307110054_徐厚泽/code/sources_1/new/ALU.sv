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
           output  logic zero);
          
    always_comb
    case(alucont)
    3'b010:
    begin
        result <= a + b;
        zero <= 0;
    end 
    3'b110:
    begin
        result <= a - b;
        if(result == 0) zero <= 1;
        else zero <= 0;
    end
    3'b000:
    begin
        result <= a & b;
        zero <=  0;
    end   
    3'b001:
    begin
        result <= a | b;
        zero <=  0;
     end
    3'b111: 
    begin
        result <= ((a < b) ? 1 : 0);
        zero <= 0;
    end
    endcase
    
endmodule
