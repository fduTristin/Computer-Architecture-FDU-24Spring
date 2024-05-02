`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 14:06:05
// Design Name: 
// Module Name: mux7seg
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


module mux7seg(
    input logic [31:0]t,
    input logic clk,
    input logic reset,
    output logic [6:0]a2g,
    output logic [7:0]an
    );
    logic [4:0]digit;
    logic [2:0]s;
    logic [20:0]clkdiv;
    assign s=clkdiv[18:16];
    always_comb
        case(s)
            0:digit={1'b0,t[3:0]};
            1:digit={1'b0,t[7:4]};
            2:digit={1'b0,t[11:8]};
            3:digit=5'b10000;
            4:digit={1'b0,t[19:16]};
            5:digit={1'b0,t[23:20]};
            6:digit={1'b0,t[27:24]};
            7:digit={1'b0,t[31:28]};
            default:digit=5'b11111;
        endcase
    always_comb
        case(s)
            'o0:an=8'b1111_1110;
            'o1:an=8'b1111_1101;
            'o2:an=8'b1111_1011;
            'o3:an=8'b1111_0111;
            'o4:an=8'b1110_1111;
            'o5:an=8'b1101_1111;
            'o6:an=8'b1011_1111;
            'o7:an=8'b0111_1111;
            default:an=8'b1111_1111;
        endcase;
      always @(posedge clk) begin
          if(reset==1) clkdiv<=1;
          else clkdiv<=clkdiv+1;
      end
      seg s7(digit,a2g);
endmodule
