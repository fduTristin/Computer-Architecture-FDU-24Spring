`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 15:03:29
// Design Name: 
// Module Name: tb_IO
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


module tb_IO();

    logic CLK100MHZ,BTNC,BTNL,BTNR;
    logic [15:0] SW;
    logic [7:0] AN;
    logic [6:0] A2G;
    logic [1:0] LED;
   
   
    topmips T(CLK100MHZ,BTNC,BTNL,BTNR,LED,SW,AN,A2G);
    
    initial 
    begin
        #0; BTNC <= 1;
        #2; BTNC <= 0;
        #2; BTNL <= 1; BTNR <= 1;
        #2; SW <= 16'b00010001_00100100;
    end
        
   always 
   begin
    CLK100MHZ <= 1;# 5;CLK100MHZ <= 0;# 5;
   end
   
endmodule
