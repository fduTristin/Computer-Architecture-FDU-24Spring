# 实验三：多周期mips处理器

[TOC]

## 1 实验目的

设计多周期MIPS处理器，包括

- 完成多周期MIPS处理器的设计
- 在vivado上仿真
- 编写MIPS代码验证多周期MIPS处理器
- 板上验证

## 2 实验过程

### 2.1 设计多周期MIPS处理器

#### 总述

在单周期处理器的基础上设计，较单周期而言，变化有：

1. 指令译码单元改变：

   从简单的switch语句指令译码改变为有限状态机，将指令拆分成状态，根据当前状态和op码决定下一个状态。

2. 增加寄存器：

   因为要使得取到的指令值在接下来的几个周期都不变化，增加一个有写使能的指令寄存器存储fetch到的指令，只在fetch状态s时可以写入。

3. 主存有变化：

   体系结构由哈佛结构变为冯诺依曼结构，不再将主存拆分为`dmen`和`imem`，而是只用一个存储器存储指令和数据

4. 组合部件变为时序部件

   将控制单元中的组合逻辑变为时序逻辑，在触发沿统一写入，使得数据在一个时钟周期内保持稳定，可以有效避免冲突和错误。

重点分析重构的`maindec`文件和`datapath`文件

对照下图进行处理器设计：
<img src="C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230506084917516.png" alt="image-20230506084917516" style="zoom:90%; box-shadow:10px 10px 10px rgba(0,0,0,0.4)" />



文件架构为下图：

<img src="C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230508191120094.png" alt="image-20230508191120094" style="zoom:80%;box-shadow:10px 10px 10px rgba(0,0,0,0.4)" />

#### 模块分析与核心代码

##### `maindec`

对`maindec`模块，如总述中提到，由直接译码转变为有限状态机，状态转移关系如下图：

<img src="C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230508191426738.png" alt="image-20230508191426738" style="box-shadow:10px 10px 10px rgba(0,0,0,0.4)" />

有限状态机的写法为：时序电路状态转移 + 组合电路分配下一状态和控制信号

为了提高代码的可读性，用localparam语句给状态编码和op码命名。

###### 核心代码（状态转移）

```verilog
    // 状态命名
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
    
    //op码
    localparam LW    = 6'b100011;
    localparam SW    = 6'b101011;
    localparam RTYPE = 6'b000000;
    localparam BEQ   = 6'b000100;
    localparam ADDI  = 6'b001000;
    localparam J     = 6'b000010;
    localparam BNE   = 6'b000101;
    localparam ANDI  = 6'b001100;
    localparam ORI   = 6'b001101;
    
    
    logic [3:0]  state,nextstate;
    logic [17:0] controls;
    
	//状态转移
    always_ff @(posedge clk or posedge reset)
        if(reset) state <= FETCH;
        else      state <= nextstate;
        
	//op码+当前状态 决定下一状态
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
            // alusrca=1 alusrcb=10 aluop=-
            SUBIEX : controls=18'b0000_1_0000_10_00_001_00; 
            // alusrca=1 alusrcb=10 aluop=and immext=1
            ANDIEX : controls=18'b0000_1_0000_10_00_010_01;
            // alusrca=1 alusrcb=10 aluop=or immext=1
            ORIEX  : controls=18'b0000_1_0000_10_00_011_01;
            // regwrite=1 memtoreg=0 regdst=0
            REGWB  : controls=18'b0001_0_0000_00_00_000_00;
            // pcsrc=10 pcwrite=1
            JEX    : controls=18'b1000_0_0000_00_10_000_00;
            default: controls=18'b0000_0_0000_00_00_000_00;
        endcase
```

##### `datapath`

遵照下图完成datapath的重构<img src="C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230506084917516.png" alt="image-20230506084917516" style="zoom:90%; box-shadow:10px 10px 10px rgba(0,0,0,0.4)" />

###### 核心代码（调用模块）

```verilog
    logic [4:0]a1,a2,a3;
    logic [31:0]pc,nextpc,aluout,wd3,rd1,rd2,a,b,srca,srcb,four,signimm,aluresult,pcjump;
    assign a1 = instr[25:21];
    assign a2 = instr[20:16];
    // pc update
    flopren#(32) f0(.clk(clk),
                    .reset(reset),
                    .en(pcen),
                    .d(nextpc),
                    .q(pc));
    // memader
    mux2#(32)  m0(.d0(pc),
                  .d1(aluout),
                  .s(iord),
                  .y(adr));
    // regdst
    mux2#(5) m1(.d0(instr[20:16]),
                .d1(instr[15:11]),
                .s(regdst),
                .y(a3));
    // memtoreg
    mux2#(32) m2(.d0(aluout),
                 .d1(data),
                 .s(memtoreg),
                 .y(wd3));
    // regfile
    regfile rf(.clk(clk),
               .we3(regwrite),
               .ral(a1), 
               .ra2(a2),
               .wa3(a3),
               .wd3(wd3),
               .rd1(rd1),
               .rd2(rd2));

    flopr#(32) f3(.clk(clk),
                  .reset(reset),
                  .d(rd1),
                  .q(a));

    flopr#(32) f4(.clk(clk),
                  .reset(reset),
                  .d(rd2),
                  .q(b));
    
    assign writedata=b;

    mux2#(32)  m3(.d0(pc),
                  .d1(a),
                  .s(alusrca),
                  .y(srca));
                  
    assign four=8'h0000_0004;

    signext sn(.a(instr[15:0]),
               .y(signimm),
               .immext(immext));
             
    mux4#(32) m4(.d0(b),
                 .d1(four),
                 .d2(signimm),
                 .d3(signimm<<2),
                 .s(alusrcb),
                 .y(srcb));

    alu alu(.a(srca),
            .b(srcb),
            .alucont(alucontrol),
            .result(aluresult),
            .zero(zero));
    flopr#(32) f5(.clk(clk),
                  .reset(reset),
                  .d(aluresult),
                  .q(aluout));
    assign pcjump={pc[31:28],(instr[25:0]<<2)};
    mux4#(32) m5(.d0(aluresult),
                 .d1(aluout),
                 .d2(pcjump),
                 .d3(pcjump),
                 .s(pcsrc),
                 .y(nextpc));
```

##### 其他变化

需要更改`signext`模块（增加控制信号immext，若为1则做0扩展，主要是为了扩展指令subi，ori）

```verilog
	always_comb
        if(!immext) y={{16{a[15]}},a};
        else y={{16{0}},a};
```

增加`mux4`，四选一复用器。

### 2.2 仿真

引入单周期的`testbench`文件，引入机器码文件`memfile.dat`，开始仿真，结果如下：

<img src="C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230508190748203.png" alt="image-20230508190748203" style="zoom:100%; box-shadow:10px 10px 10px rgba(0,0,0,0.4)" />

仿真成功！

### 2.3 验证

#### 验证程序 

用下列程序验证，是一个长度为5的数组累加的程序，修改`testbench`，若结果为70，则仿真成功

```assembly
	or $8,$0,$0 # $8  
    ori $9,$0,9 # $9 
    sw  $9,0($8)
    
    addi $8,$8,4
    ori $9,$0,7
    sw  $9,0($8)
    
    addi $8,$8,4
    ori $9,$0,15
    sw  $9,0($8)
	
	addi $8,$8,4
    ori $9,$0,19
    sw  $9,0($8)    
    
	addi $8,$8,4
    ori $9,$0,20
    sw  $9,0($8)
    
    ori $10,$0,5 # $t2=5
    
	or $8,$0,$0 # $t0=0 
	# index
	or $9,$0,$0 # $t1=0  
	bne $10,S0,loop 
loop:
	slt $11,$9,$10 # if($t1<6) $t3=1  	
	beq $11,$0,exit
	
	add $12,$9,$9 # 
	add $12,$12,$12 # $t4=4*$t1 018c6020
	lw 	$13,0($12) 
	add $8,$8,$12  
	
	# index++
	addi $9,$9,1
	j loop
exit:
	sw $8,84($0)
```

机器码：

>```
>00004025
>34090009
>ad090000
>21080004
>34090007
>ad090000
>21080004
>3409000f
>ad090000
>21080004
>34090013
>ad090000
>21080004
>34090014
>ad090000
>340a0005
>00004025
>00004825
>140a0000
>012a582a
>100b0006
>01296020
>018c6020
>8d8d0000
>010d4020
>21290001
>08000013
>ac080054
>```

#### `testbench`

修改`testbench`，若结果为70，则仿真成功，不为70则仿真失败

```verilog
always@(posedge clk)
    begin 
        if(memwrite) 
            begin
             if(dataadr === 84 & writedata === 70)
             begin 
             $display("Simulation succeeded!");
             $stop;
             end
        else if(dataadr === 84 & writedata != 70)
            begin
            $display("Simulation failed");
            $stop;
            end
           end
          end
```

#### 仿真结果

<img src="C:\Users\cos\AppData\Roaming\Typora\typora-user-images\image-20230508195907783.png" alt="image-20230508195907783" style="zoom:80%; box-shadow:10px 10px 10px rgba(0,0,0,0.5)" />

仿真结束！

## 3 实验结论

1. 在单周期处理器的基础上设计多周期处理器，用有限状态机的状态切换实现一条指令的多周期执行。
2. 熟悉了在vivado上debug的方法：自底向上，通过添加需要的变量到仿真窗口来排查出错的地方，添加instr可以更简单直观地模拟cpu的执行。

