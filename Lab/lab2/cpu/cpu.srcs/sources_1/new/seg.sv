`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 15:35:43
// Design Name: 
// Module Name: seg
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


module seg(
    input logic [4:0] x,
    output logic [6:0] a2g );
    always_comb
    case (x)
        5'b00000: a2g = 7'b0000001;
        5'b00001: a2g = 7'b1001111;
        5'b00010: a2g = 7'b0010010;
        5'b00011: a2g = 7'b0000110;
        5'b00100: a2g = 7'b1001100;
        5'b00101: a2g = 7'b0100100;
        5'b00110: a2g = 7'b0100000;
        5'b00111: a2g = 7'b0001111;
        5'b01000: a2g = 7'b0000000;
        5'b01001: a2g = 7'b0000100;
        5'b01010: a2g = 7'b0001000; //a
        5'b01011: a2g = 7'b1100000; //b
        5'b01100: a2g = 7'b0110000; //c
        5'b01101: a2g = 7'b1000010; //d
        5'b01110: a2g = 7'b0110000; //e
        5'b01111: a2g = 7'b0111000; //f
        5'b10000: a2g = 7'b1110110; //=
        default: a2g = 7'b1111111;
      endcase
endmodule
