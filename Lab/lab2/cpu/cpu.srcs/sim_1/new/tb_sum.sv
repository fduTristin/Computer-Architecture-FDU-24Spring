`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 22:54:09
// Design Name: 
// Module Name: tb_sum
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


module tb_sum();

    logic clk;
    logic reset;
    logic [31:0] writedata;
    logic [31:0] dataadr;
    logic memwrite;
   
   
    top dut(clk,reset,writedata,dataadr,memwrite);
    
    initial 
    begin
        reset <= 1; #22; reset <= 0; 
    end
        
   always 
   begin
    clk <= 1;# 5;clk <= 0;# 5;
   end
   
   always@(posedge clk)
    begin 
        if(memwrite) begin
            if(dataadr === 48 & writedata === 55) begin 
                $display("Simulation succeeded!");
                $stop;
            end

        // else if(dataadr !== 48) begin
        //         $display("Simulation failed");
        //         $stop;
        //     end
        end
    end
endmodule
