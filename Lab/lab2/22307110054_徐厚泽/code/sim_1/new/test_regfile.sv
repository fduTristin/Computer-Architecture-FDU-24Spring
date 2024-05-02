`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/20 13:44:51
// Design Name: 
// Module Name: test_regfile
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


module test_regfile();
    reg clk;
    reg regWE;
    reg [4:0] regWA;
    reg [31:0] regWD;
    reg [4:0] RsAddr;
    reg [4:0] RtAddr;
    wire [31:0] RsData;
    wire [31:0] RtData;

    //instantiate
    REGFILE MUT(clk,regWE,regWA,regWD,RsAddr,RtAddr,RsData,RtData);

    //initialize
    initial begin
        clk = 0;
        regWE = 0;
        regWA = 0;
        regWD = 0;
        RsAddr = 0;
        RtAddr = 0;

        //wait 100ns
        #100;

        //add exitation signal
        regWE = 1;
        regWD = 32'h1234abcd;
    end

    //set clk
    parameter PERIOD = 20;
    always begin
        clk = 1'b0;
        #(PERIOD/2) clk = 1'b1;
        #(PERIOD/2);
    end

    //exitation signal
    always begin
        regWA = 8;
        RsAddr = 8;
        #PERIOD;
    end
endmodule
