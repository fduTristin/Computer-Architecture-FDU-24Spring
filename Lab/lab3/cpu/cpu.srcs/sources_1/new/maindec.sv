`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 00:38:51
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


module maindec (input logic clk,
                input logic reset,
                input logic [5:0]op,
                output logic pcwrite,memwrite,irwrite,regwrite,
                output logic alusrca,iord,memtoreg,regdst, 
                output logic [1:0]alusrcb,pcsrc,
                output logic branchbeq,branchbne,
                output logic [2:0]aluop,
                output logic immext);
                
    localparam FETCH   = 4'b0000;
    localparam DECODE  = 4'b0001; //state 1
    localparam MEMADR  = 4'b0010; //state 2
    localparam MEMRD   = 4'b0011; //state 3
    localparam MEMWB   = 4'b0100; //state 4 from mem to reg
    localparam MEMMR   = 4'b0101; //state 5
    localparam RTYPEEX = 4'b0110; //state 6
    localparam RTYPEWB = 4'b0111; //state 7
    localparam BEQEX   = 4'b1000; //state 8
    localparam ADDIEX  = 4'b1001; //state 9
    localparam REGWB   = 4'b1010; //state 10 from reg to reg
    localparam JEX     = 4'b1011; //state 11
    localparam BNEEX   = 4'b1100; //state 12
    localparam ANDIEX  = 4'b1101; //state 13
    localparam ORIEX   = 4'b1110; //state 14
    localparam SLTIEX   = 4'b1111; //state 15
    
    
    localparam LW    = 6'b100011;
    localparam SW    = 6'b101011;
    localparam RTYPE = 6'b000000;
    localparam BEQ   = 6'b000100;
    localparam ADDI  = 6'b001000;
    localparam J     = 6'b000010;
    localparam BNE   = 6'b000101;
    localparam ANDI  = 6'b001100;
    localparam ORI   = 6'b001101;
    localparam SLTI   = 6'b001010;
    
    
    logic [3:0]  state,nextstate;
    logic [17:0] controls;
    
    always_ff @(posedge clk or posedge reset)
        if(reset) state <= FETCH;
        else      state <= nextstate;
        
    always_comb
       case(state)
        FETCH: nextstate = DECODE;    
        DECODE:
            case(op)
                LW:      nextstate = MEMADR;
                SW:      nextstate = MEMADR;
                RTYPE:   nextstate = RTYPEEX;
                BEQ:     nextstate = BEQEX;
                ADDI:    nextstate = ADDIEX;
                J:       nextstate = JEX;
                BNE:     nextstate = BNEEX;
                ORI:     nextstate = ORIEX;
                ANDI:    nextstate = ANDIEX;
                SLTI:    nextstate = SLTIEX;
                default: nextstate = 4'bx;
            endcase
        MEMADR: case(op)
                    LW:    nextstate = MEMRD;
                    SW:    nextstate = MEMMR;
                    default: nextstate = 4'bx;
                endcase
        MEMRD:  nextstate = MEMWB;
        MEMWB:  nextstate = FETCH;
        MEMMR:  nextstate = FETCH;
        RTYPEEX:nextstate = RTYPEWB;
        RTYPEWB:nextstate = FETCH;
        BEQEX:  nextstate = FETCH;
        BNEEX:  nextstate = FETCH;
        ADDIEX: nextstate = REGWB;
        ANDIEX: nextstate = REGWB;
        ORIEX:  nextstate = REGWB;
        REGWB:  nextstate = FETCH;
        JEX:    nextstate = FETCH;
        SLTIEX:  nextstate = REGWB;
        default:nextstate = 4'bx;
       endcase

    assign {pcwrite,memwrite,irwrite,regwrite,alusrca,branchbeq,iord,memtoreg,regdst,alusrcb,pcsrc,aluop,branchbne,immext}=controls;
   
    always_comb
        case(state) 
        // pcwrite,memwrite,irwrite,regwrite_alusrca_branchbeq,iord,memtoreg,regdst_alusrcb_pcsrc_aluop_branchbne,immext

            //irwrite=1 pcwrite=1 iord=0 aluop=+ alusrca=0 alusrcb=01 pcsrc=00
            FETCH  : controls=18'b1010_0_0000_01_00_000_00;   
            // regwrite=0 alusrca=0 alusrcb=11 aluop=+
            DECODE : controls=18'b0000_0_0000_11_00_000_00;
            // alusrca=1 alusrcb=10 aluop +
            MEMADR : controls=18'b0000_1_0000_10_00_000_00;
            // iord=1
            MEMRD  : controls=18'b0000_0_0100_00_00_000_00;
            // regwrite=1 memtoreg=1 regdst=0
            MEMWB  : controls=18'b0001_0_0010_00_00_000_00;
            // iord=1 memwrite=1
            MEMMR  : controls=18'b0100_0_0100_00_00_000_00; 
            // alusrca=0 alusrcb=00 aluop=func
            RTYPEEX: controls=18'b0000_1_0000_00_00_100_00;
            // regwrite=1 memtoreg=0 regdst=1
            RTYPEWB: controls=18'b0001_0_0001_00_00_000_00;
            // alusrca=1 alusrcb=00 aluop=- branchbeq pcsrc=01
            BEQEX  : controls=18'b0000_1_1000_00_01_001_00;
            // alusrca=1 alusrcb=00 aluop=- branchbne pcsrc=01
            BNEEX  : controls=18'b0000_1_0000_00_01_001_10;
            // alusrca=1 alusrcb=10 aluop=+
            ADDIEX : controls=18'b0000_1_0000_10_00_000_00;
            // alusrca=1 alusrcb=10 aluop=and immext=1
            ANDIEX : controls=18'b0000_1_0000_10_00_010_01;
            // alusrca=1 alusrcb=10 aluop=or immext=1
            ORIEX  : controls=18'b0000_1_0000_10_00_011_01;
            // alusrca=1 alusrcb=10 aluop=slt immext=1
            SLTIEX  : controls=18'b0000_1_0000_10_00_101_01;
            // regwrite=1 memtoreg=0 regdst=0
            REGWB  : controls=18'b0001_0_0000_00_00_000_00;
            // pcsrc=10 pcwrite=1
            JEX    : controls=18'b1000_0_0000_00_10_000_00;
            default: controls=18'b0000_0_0000_00_00_000_00;
        endcase
endmodule
