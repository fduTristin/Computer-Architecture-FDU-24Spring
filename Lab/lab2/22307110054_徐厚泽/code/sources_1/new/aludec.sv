`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 13:31:15
// Design Name: 
// Module Name: aludec
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


module aludec(
    input  logic [5:0] funct,
    input  logic [2:0] aluop,
    output logic [2:0] alucontrol
    );
    
    always_comb
    case(aluop)
        3'b000: alucontrol <= 3'b010; //addi lw/sw/addi
        3'b001: alucontrol <= 3'b110; //branch
        3'b010: alucontrol <= 3'b000; //andi
        3'b011: alucontrol <= 3'b001; //ori
        3'b101: alucontrol <= 3'b111; //slti
        3'b100: case(funct)
                6'b100000:alucontrol <= 3'b010; //add
                6'b100010:alucontrol <= 3'b110; //sub
                6'b100100:alucontrol <= 3'b000; //and
                6'b100101:alucontrol <= 3'b001; //or
                6'b101010:alucontrol <= 3'b111; //slt
                6'b000000:alucontrol <= 3'b000; //nop 
                default:  alucontrol <= 3'bxxx;
                endcase
     endcase

endmodule
