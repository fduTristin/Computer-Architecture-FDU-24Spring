 module maindec(input logic clk,
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
    localparam MEMWB   = 4'b0100; //state 4
    localparam MEMMR   = 4'b0101; //state 5
    localparam RTYPEEX = 4'b0110; //state 6
    localparam RTYPEWB = 4'b0111; //state 7
    localparam BEQEX   = 4'b1000; //state 8
    localparam ADDIEX  = 4'b1001; //state 9
    localparam REGWB   = 4'b1010; //state 10 写入寄存器
    localparam JEX     = 4'b1011; //state 11
    //
    localparam BNEEX   = 4'b1100; //state 12
    localparam ANDIEX  = 4'b1101; //state 13
    localparam ORIEX   = 4'b1110; //state 14
    localparam SUBIEX  = 4'b1111; //state 15
    
    
    localparam lw=6'b100011;
    localparam sw=6'b101011;
    localparam rtype=6'b000000;
    localparam beq=6'b000100;
    localparam addi=6'b001000;
    localparam subi=6'b001001;
    localparam j=6'b000010;
    localparam bne=6'b000101;
    localparam andi=6'b001100;
    localparam ori=6'b001101;
    
    
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
                LW:    nextstate = MEMADR;
                SW:    nextstate = MEMADR;
                RTYPE: nextstate = RTYPEEX;
                BEQ:   nextstate = BEQEX;
                ADDI:  nextstate = ADDIEX;
                SUBI:  nextstate = ADDIEX;
                J:     nextstate = JEX;
                BNE:   nextstate = BNEEX;
                ORI:   nextstate = ORIEX;
                ANDI:  nextstate = ANDIEX;
                SUBI:  nextstate = SUBIEX;
                default: nextstate = 4'bx;
            endcase
        MEMADR: ;
        MEMRD:  nextstate = MEMWB;




    assign { regwrite,regdst,alusrc,branchbeq,branchbne,memwrite,memtoreg,jump,aluop } = controls;
    
    // regwrite： 写入寄存器
    // regdst：指明目的寄存器是哪一个  0是i类型 1是第r类型 
    // alusrc : alu中第二个操作数来自reg还是立即数 0：寄存器 1：立即数
    //branch：也是控制选择器 若为1 就选择pc+4+branchlabel*4 若为0 就pc+4
    //memwrite 写入内存使能
    //memtoreg 因为写入寄存器的值可能来自两个地方：alu的结果0 或者从内存中读到的结果1 memtoreg也是选择器控制单元
    // j指令
    //aluop：00：+ 01：- 10：看func 11：undefined
    // aluop ：三位编码 000：+ 001：- 010：and 011：or 100：func 101:slti 110 111
   
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