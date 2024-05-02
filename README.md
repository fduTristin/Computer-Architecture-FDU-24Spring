# 计算机组成与体系结构

## 实验安排

* 20' week1~4 MIPS程序设计
* 30' week5~8 单周期MIPS处理器
* 30' week9~12 多周期MIPS处理器
* 20'week13~16 cache模拟器

## 实验条件

* 计算机
  * Vivado19.02
  * QtSPIM
  * MingW64编译器
  * vscode
* 实验板NEXYS4 DDR XC7A100T

## 实验简介

### lab1: MIPS程序设计

#### 实验目的

* 熟悉QtSPIM模拟器；
* 熟悉编译器、汇编程序和链接器；
* 熟悉MIPS体系结构的计算，包括
  * MIPS的数据表示；
  * 熟悉MIPS指令格式和寻址方式；
  * 熟悉MIPS汇编语言；
  * 熟悉MIPS的各种机器代码表示，包括
    * 选择结构；
    * 循环结构；
    * **过程调用：调用与返回、栈、调用约定**等；
    * 系统调用。

#### 实验任务

##### 1. 调试给定程序

调试给定的程序p1.asm，p2.asm和p3.asm，记录程序运行的结果。

##### 2.改写程序

改写程序p1.asm，使用MIPS汇编指令和QtSPIM模拟器，接收两个整数，计算结果后输出。典型的运行例子如下：

```shell
Please enter 1st number: 20
Please enter 2nd number: 50
The result of 20 & 50 is: 70
Do you want to try another(0—continue/1—exit):
```

##### 3.C代码翻译为MIPS代码

把下面的C代码翻译成MIPS代码

```C
#include <stdio.h>
int sumn(int *arr, int n)
{
  int sum = 0;
  for (int idx = 0; idx < n; idx++)
  sum += arr[idx];
  return sum;
}
int main()
{
  int arrs[] = {9, 7, 15, 19, 20, 30, 11, 18};
  int N = 8;
  int result = sumn(arrs, N);
  printf("The result is: %d", result);
  return 0;
}
```

##### 4.代码优化

请仔细阅读参考文献的第3章，编写一个名为fib-op.asm文件，使得其性能优于fib-o.asm；并解释为什么

### lab2 单周期MIP处理器

#### 实验目的

* 熟悉Vivado软件
* 熟悉在Vivado软件下进行硬件设计的流程
* 设计单周期MIPS处理器，包括：
  * 完成单周期MIPS处理器的设计
  * 在Vivado软件上进行仿真
  * 编写MIPS代码验证单周期MIPS处理器
  * 在NEXYS4 DDR板上进行验证

#### 实验任务

##### 1.设计单周期MIPS处理器

单周期MIPS处理器包含的指令（共15条）如下：

* add,sub,addi
* and,or,andi,ori
* slt,slti
* sw,lw
* beq,bne
* j
* nop

##### 2.仿真

##### 3.验证

##### 4.板上验证
