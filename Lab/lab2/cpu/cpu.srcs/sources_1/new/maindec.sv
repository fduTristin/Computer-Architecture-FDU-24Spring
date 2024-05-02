`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 13:31:15
// Design Name: 
// Module Name: maindec
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


module maindec(
        input logic [5:0] op,
        output logic  memtoreg, memwrite,
        output logic  branchbeq, branchbne, alusrc,
        output logic  regdst, regwrite,
        output logic jump,
        output logic [2:0] aluop
    );

    logic [10:0] controls;
    
    assign { regwrite,regdst,alusrc,branchbeq,branchbne,memwrite,memtoreg,jump,aluop } = controls;
   
    always_comb
    case(op)
        6'b000000:controls <= 11'b110_00_00_0_100; //r
        6'b100011:controls <= 11'b101_00_01_0_000; //lw
        6'b101011:controls <= 11'b001_00_10_0_000; //sw
        6'b000100:controls <= 11'b000_10_00_0_001; //beq   
        6'b000101:controls <= 11'b000_01_00_0_001; //bne
        6'b001000:controls <= 11'b101_00_00_0_000; //addi 001000
        6'b001100:controls <= 11'b101_00_00_0_010; //andi
        6'b001101:controls <= 11'b101_00_00_0_011; //ori
        6'b001010:controls <= 11'b101_00_00_0_101; //slti
        6'b000010:controls <= 11'b000_00_00_1_000; //j
        default:  controls <= 11'bxxxxxxxxxxx;
        endcase

endmodule
