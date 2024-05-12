`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/03 09:10:48
// Design Name: 
// Module Name: signext
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


module signext(
        input logic [15:0]a,
        output logic [31:0]y,
        input logic immext
    );
    
    always_comb
        if(!immext) y={{16{a[15]}},a};
        else y={{16{0}},a};

endmodule
