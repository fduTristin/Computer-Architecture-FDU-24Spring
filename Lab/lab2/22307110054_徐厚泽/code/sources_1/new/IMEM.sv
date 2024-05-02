`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 09:08:11
// Design Name: 
// Module Name: IMEM
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


module IMEM(
    input logic [5:0] addr ,
    output logic [31:0] rd
    );
    
    logic [31:0] RAM [63:0];// 32*64 RAM
    
    initial
        begin
        //initialize memory
        $readmemh ("loop.dat",RAM);
        end
        
    assign rd = RAM[addr];
    
endmodule
