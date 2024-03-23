#  实验1：MIPS程序设计

##  调试程序

  ### p1
  从main标签处开始运行
  下为每一条语句的运行结果：
  ```
  main:				# Program starts at main.
    ori	$t2, $0, 40	
    # $t2的值变为40
  
	  ori	$t3, $0, 17	
    # $t3的值变为17
  
	  add	$t3, $t2, $t3	
    # $t3的值变为40+17=57
  
	  ori	$0, $0, 40	
    # $0的值变为40
  
	  ori	$t4, $0, 0	# ... but it really doesn't
    # $0的值变回0，$t4的值也仍保持为0
  
  
	  ori	$v0, $0, 10	
	  syscall			
    # main函数 return
  ```
  运行结果：先给`<img src="https://latex.codecogs.com/gif.latex?t2`,`"/>t3`两个寄存器赋值，再将值相加，结果存储到`<img src="https://latex.codecogs.com/gif.latex?t3`
%20%20并且，若给`"/>0`赋不为0的值，只会短暂地使`<img src="https://latex.codecogs.com/gif.latex?0`的值不为0，下一条指令时`"/>0`会自动复原
  ### P2
  从main标签处开始运行
  下为每一条语句的运行结果：
  ```
  main:				
        ori	$t2, $0, 40	
        # $t2的值变为40
  
	lui	$t2, 0x1234	
        # $t2的值变为0x12340000        
        ori	$t2, $t2, 40	
        # $t2的值变为0x12340028
  
	li	$t3, 0x12340028 
        # t3的值变为0x12340028
  
	li	$v0, 10		
	syscall			
  # 函数返回
  ```
  运行结果：这个程序列举了给寄存器赋值的三种方法：
   1. ori 以`<img src="https://latex.codecogs.com/gif.latex?0`基准，使目标寄存器%20=0|x即x
%20%20%20%20但因为立即数只占16bit，所以最大不超过0x7fff，如果大于这个值，就不能只用ori赋值
%20%20%202.%20lui，ori
%20%20%20%20高位和低位分开赋值，lui可以将一个16位立即数传入寄存器高16位，ori可以传入低16位，这样可以完整赋值
%20%20%203.%20li
%20%20%20%20直接用寄存器和32位立即数赋值
###%20%20P3

%20%20data中声明了一个数组和一个占1个字的整型变量
%20%20main中运行结果：
%20%20```
%20%20%20%20main:%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20
%20%20%20%20%20%20%20%20la"/>t0, h          
        # <img src="https://latex.codecogs.com/gif.latex?t0%20的值变为%200x10010000，是h在内存中的地址
%20%20%20%20%20%20
%20%20%20%20%20%20%20%20la"/>t1, A          
        # <img src="https://latex.codecogs.com/gif.latex?t1%20的值变为%200x10010040,是A的第一个元素在内存中的地址

%20%20%20%20%20%20%20%20lw"/>t2, 0(<img src="https://latex.codecogs.com/gif.latex?t0)%20%20%20%20%20
%20%20%20%20%20%20%20%20#"/>t2 的值变为40，即h的值

        lw      <img src="https://latex.codecogs.com/gif.latex?t3,%2032("/>t1)    
        # <img src="https://latex.codecogs.com/gif.latex?t3%20的值变为19，即A[8]的值

%20%20%20%20%20%20%20%20add"/>t3, <img src="https://latex.codecogs.com/gif.latex?t2,"/>t3   
        # <img src="https://latex.codecogs.com/gif.latex?t3%20的值变为40+19=59
%20%20%20%20%20%20%20%20
%20%20%20%20%20%20%20%20sw"/>t3, 48(<img src="https://latex.codecogs.com/gif.latex?t1)%20%20%20%20
%20%20%20%20%20%20%20%20#%20内存中A[12]%20的值变为59

%20%20%20%20%20%20%20%20li"/>v0, 10         
        syscall                 
        # 函数返回
  ```
  运行结果：
  该程序展现了对内存中变量的获取和赋值方法，可以直接用label名赋值给寄存器，得到其地址，对`4*i(该地址)`用lw可以访问到下标为i的元素。
  同理，对`4*i(该地址)`用sw可以给下标为i的数组元素赋值。
  
  
##  改写程序
  
在.data中存储需要被打印的字符串或者字符
在.text中书写程序正文
  
  ```
.data
    hint1:    .asciiz "Please Enter 1st number:"
    hint2:    .asciiz "Please Enter 2nd number:"
    result:   .asciiz "The result of "
    newline:	.asciiz "\n"
    char_and: .byte '&'
    space:		.asciiz  " "
    is:       .asciiz " is: "
    another:  .asciiz "Do you want to try another(0-continue/1-exit)\n"

.text
    main:
      # get the 1st number
        # print hint1
        li <img src="https://latex.codecogs.com/gif.latex?v0,4
%20%20%20%20%20%20%20%20la"/>a0,hint1
        syscall

        # get input
        li <img src="https://latex.codecogs.com/gif.latex?v0,5
%20%20%20%20%20%20%20%20syscall
%20%20%20%20%20%20%20%20or"/>t0, <img src="https://latex.codecogs.com/gif.latex?0,"/>v0	# Register <img src="https://latex.codecogs.com/gif.latex?t0%20gets%20the%201st%20value

%20%20%20%20%20%20#%20get%20the%20second%20number
%20%20%20%20%20%20%20%20#%20print%20hint2
%20%20%20%20%20%20%20%20li"/>v0,4
        la <img src="https://latex.codecogs.com/gif.latex?a0,hint2
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20#%20get%20input
%20%20%20%20%20%20%20%20li"/>v0,5
        syscall
        or	<img src="https://latex.codecogs.com/gif.latex?t1,"/>0, <img src="https://latex.codecogs.com/gif.latex?v0	#%20Register"/>t1 gets the 2nd value

        # add <img src="https://latex.codecogs.com/gif.latex?t0,"/>t1
        add <img src="https://latex.codecogs.com/gif.latex?t2,"/>t0,<img src="https://latex.codecogs.com/gif.latex?t1
    
    	#%20print%20result
%20%20%20%20%20%20%20%20li"/>v0,4
        la <img src="https://latex.codecogs.com/gif.latex?a0,result
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20#%20print%201st%20number
%20%20%20%20%20%20%20%20li"/>v0,1
        or <img src="https://latex.codecogs.com/gif.latex?a0,"/>0, <img src="https://latex.codecogs.com/gif.latex?t0
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20li"/>v0,4
        la <img src="https://latex.codecogs.com/gif.latex?a0,space
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20li"/>v0,4
        la <img src="https://latex.codecogs.com/gif.latex?a0,char_and
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20#%20print%202nd%20number
%20%20%20%20%20%20%20%20li"/>v0,1
        or <img src="https://latex.codecogs.com/gif.latex?a0,"/>0, <img src="https://latex.codecogs.com/gif.latex?t1
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20li"/>v0,4
        la <img src="https://latex.codecogs.com/gif.latex?a0,is
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20#%20print%20result
%20%20%20%20%20%20%20%20li"/>v0,1
        or <img src="https://latex.codecogs.com/gif.latex?a0,"/>0, <img src="https://latex.codecogs.com/gif.latex?t2
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20li"/>v0,4
        la <img src="https://latex.codecogs.com/gif.latex?a0,newline
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20#%20branch%20%20
%20%20%20%20%20%20%20%20li"/>v0,4
        la <img src="https://latex.codecogs.com/gif.latex?a0,another
%20%20%20%20%20%20%20%20syscall

%20%20%20%20%20%20%20%20li"/>v0,5
        syscall

        beq <img src="https://latex.codecogs.com/gif.latex?v0,"/>zero,main
      
        li <img src="https://latex.codecogs.com/gif.latex?v0,10
%20%20%20%20%20%20%20%20syscall

```
在qtspim中运行结果如图：
![result](result.png%20&quot;result&quot;)
与示例一致
##%20%20C代码编译
```c
#include%20&lt;stdio.h&gt;

int%20sumn(int%20*arr,%20int%20n)
%20%20{
%20%20%20%20int%20sum%20=%200;
%20%20%20%20for%20(int%20idx%20=%200;%20idx%20&lt;%20n;%20idx++)
%20%20%20%20%20%20sum%20+=%20arr[idx];

%20%20%20%20return%20sum;
%20%20}
int%20main()
%20%20{
%20%20%20%20int%20arrs[]%20=%20{9,%207,%2015,%2019,%2020,%2030,%2011,%2018};
%20%20%20%20int%20N%20=%208;
%20%20%20%20int%20result%20=%20sumn(arrs,%20N);
%20%20%20%20printf(&quot;The%20result%20is:%20%d&quot;,%20result);

%20%20%20%20return%200;
%20%20}
```
分析该程序，首先在main中，将数组的初值store到对应内存中，并给n赋值
然后按顺序将函数参数赋给`"/>a0`,`<img src="https://latex.codecogs.com/gif.latex?a1`,jal跳到对应函数sumn
在sumn中首先初始化sum,idx这两个值，然后跳到循环。在循环中首先判定idx是否满足要求，不满足则跳到exit，exit中将sum值赋给`"/>v0` (函数返回值),按ra中存储地址返回
若满足继续循环，从数组中取值：基于`<img src="https://latex.codecogs.com/gif.latex?a0`%20偏移%20idx*4个，所以先乘后加，最后lw到寄存器t4中，t4累加到sum上。操作完成后idx自加，回到循环j%20loop。

按照分析情况，代码如下:
```
.data%20
	myArrays:	.space%2032
	result:		.asciiz%20&quot;The%20result%20is:%20&quot;
.text
main:
	#%20数组赋初值
	#"/>t0:index,每次加4，便于寻址
	or <img src="https://latex.codecogs.com/gif.latex?t0,"/>0,<img src="https://latex.codecogs.com/gif.latex?0
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,9
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)
%20%20%20%20
%20%20%20%20addi"/>t0,<img src="https://latex.codecogs.com/gif.latex?t0,4
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,7
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)
%20%20%20%20
%20%20%20%20addi"/>t0,<img src="https://latex.codecogs.com/gif.latex?t0,4
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,15
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)
	
	addi"/>t0,<img src="https://latex.codecogs.com/gif.latex?t0,4
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,19
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)%20%20%20%20
%20%20%20%20
	addi"/>t0,<img src="https://latex.codecogs.com/gif.latex?t0,4
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,20
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)
%20%20%20%20
%20%20%20%20addi"/>t0,<img src="https://latex.codecogs.com/gif.latex?t0,4
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,30
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)
%20%20%20%20
%20%20%20%20addi"/>t0,<img src="https://latex.codecogs.com/gif.latex?t0,4
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,11
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)
%20%20%20%20
%20%20%20%20addi"/>t0,<img src="https://latex.codecogs.com/gif.latex?t0,4
%20%20%20%20ori"/>t1,<img src="https://latex.codecogs.com/gif.latex?0,18
%20%20%20%20sw"/>t1,myArrays(<img src="https://latex.codecogs.com/gif.latex?t0)
%20%20%20%20
%20%20%20%20#%20N=8
%20%20%20%20ori"/>t2,<img src="https://latex.codecogs.com/gif.latex?0,8
%20%20%20%20
%20%20%20%20#%20把两个函数参数放在"/>a0,<img src="https://latex.codecogs.com/gif.latex?a1中
%20%20%20%20la"/>a0,myArrays
    or <img src="https://latex.codecogs.com/gif.latex?a1,"/>0,<img src="https://latex.codecogs.com/gif.latex?t2
%20%20%20%20#%20调用函数sumn
%20%20%20%20jal%20sumn
%20%20%20%20
%20%20%20%20#%20存储返回值
%20%20%20%20or"/>s0,<img src="https://latex.codecogs.com/gif.latex?0,"/>v0
  
    # 打印result
    li <img src="https://latex.codecogs.com/gif.latex?v0,4
%20%20%20%20la"/>a0,result
    syscall
  
    # 打印计算结果
    li <img src="https://latex.codecogs.com/gif.latex?v0,1
%20%20%20%20or"/>a0,<img src="https://latex.codecogs.com/gif.latex?0,"/>s0
   	syscall
  
    #end
     li <img src="https://latex.codecogs.com/gif.latex?v0,10
%20%20%20%20%20syscall
%20%20%20%20
sumn:
	#%20开栈
	subu"/>sp,<img src="https://latex.codecogs.com/gif.latex?sp,32
	sw"/>ra, 28(<img src="https://latex.codecogs.com/gif.latex?sp)%20
	sw"/>fp, 24(<img src="https://latex.codecogs.com/gif.latex?sp)%20
	addu"/>fp, <img src="https://latex.codecogs.com/gif.latex?sp,%2032%20

	#%20sum=0
	or"/>t0,<img src="https://latex.codecogs.com/gif.latex?0,"/>0
	# index
	or <img src="https://latex.codecogs.com/gif.latex?t1,"/>0,<img src="https://latex.codecogs.com/gif.latex?0
	j%20loop
loop:
	#%20index&gt;=N%20就退出
	slt"/>t2,<img src="https://latex.codecogs.com/gif.latex?t1,"/>a1   	
	beq <img src="https://latex.codecogs.com/gif.latex?t2,0,exit
	
	#%20计算偏移值
	mul"/>t3,<img src="https://latex.codecogs.com/gif.latex?t1,4
	add"/>s0,<img src="https://latex.codecogs.com/gif.latex?a0,"/>t3
	# 从数组中取值
	lw 	<img src="https://latex.codecogs.com/gif.latex?t4,("/>s0)
	# 累加
	add <img src="https://latex.codecogs.com/gif.latex?t0,"/>t0,<img src="https://latex.codecogs.com/gif.latex?t4
	
	#%20index++
	addi"/>t1,<img src="https://latex.codecogs.com/gif.latex?t1,1
	
	j%20loop
	%20
exit:
%20%20%20%20or"/>v0,<img src="https://latex.codecogs.com/gif.latex?0,"/>t0
    # return 
 	lw <img src="https://latex.codecogs.com/gif.latex?ra,%2028("/>sp) 
	lw <img src="https://latex.codecogs.com/gif.latex?fp,%2024("/>sp) 
	addu <img src="https://latex.codecogs.com/gif.latex?sp,"/>sp, 32 
	jr <img src="https://latex.codecogs.com/gif.latex?ra
```
在qtspim中运行结果如图：
%20%20![result](result_c.png%20&quot;result&quot;)
129：答案正确！

##%20%20代码优化
优化思路是将函数调用改为循环，结果存储到数组中，即采用动态规划，fib[i]=fib[i-1]+fib[i-2]
但是由于这个数组的值是由输入的n决定的，因此不能直接在data中声明一个固定大小的空间。
所以想到，用`"/>sp`的变化在栈上开辟大小为`4*(n+1)`的空间，对这段空间采取类似数组一样的存储和调用方法。这是可行的，因为栈和数组都保存在主存中。
这样会提高速度：
一是省去了多次函数调用开栈销栈的时间花费，
二是保证每个值只被计算一次，递归函数中基本每个值会被重复计算两次，没有有效的方法记录下过去计算的值。而用动态规划数组就可以保证每个值只被计算一次，这里可以节省大约一半的时间。

下为具体思路：
  首先打印信息，得到N值，将N+1，先判定不开“数组”的情况，n==1时，直接打印1并返回。
  若不为1，开辟栈空间，将`<img src="https://latex.codecogs.com/gif.latex?sp`下移`4*(n+1)`,并赋初值fib[0]=0,fib[1]=1
%20%20接下来设置好index初值2，开始循环。
%20%20当index&gt;=(n+1)%20退出并打印结果，不要忘记将`"/>sp`加回去，复原栈空间。
  在循环内部，首先取出fib[i-1]，地址`<img src="https://latex.codecogs.com/gif.latex?t4=4(index-1)+"/>sp`,取出暂存在`<img src="https://latex.codecogs.com/gif.latex?s0`中，然后将`"/>t4`-4得到fib[i-2]的地址，lw到`<img src="https://latex.codecogs.com/gif.latex?s1`中，令`"/>s2=<img src="https://latex.codecogs.com/gif.latex?s1+"/>s0`，存到`<img src="https://latex.codecogs.com/gif.latex?t4+8`对应地址中(即fib[i])。
%20%20因为退出循环的时候最后一次的结果就在`"/>s2`中，所以打印时可以直接将`<img src="https://latex.codecogs.com/gif.latex?s2`的值赋给`"/>a0`，不用再从数组中sw。

  下为具体代码:

```
.data
	messageInput: .asciiz "Input n:"
	messageOutput: .asciiz "Fib[n]="
.text
	main:
		# print the messageInput
  
	li $v0,4
	la $a0,messageInput
	syscall
  
	li $v0,5
	syscall
  
	# n
	# t0=n+1
	addi $t0,$v0,1
  
	# 一个数占4个byte
	# 开栈，模拟有数组
  
	mul	$t1,$t0,4
	subu $sp,$sp,$t1
  
	# fib[0]=0
	# fib[1]=1
	sw	$0,0($sp)
	addi $t2,$0,1
	sw	$t2,4($sp)
  
	# if(n==1)
	# return
	beq	$t0,2,end
  
	# for(int i=2;i<=n;i++)
	# {
	# 	fib[i]=fib[i-1]+fib[i-2]
	# }
  
	# index:	t2
	addi $t2,$0,2
	j loop
loop:
  
	# if(!(index<i+1)) break
	slt $t3,$t2,$t0
	beq $t3,0,exit
  
	# 循环内部：
	# $t4=$t2-1
	subi $t4,$t2,1
	# t4=t4*4
	mul $t4,$t4,4
	# t4=$t4+$sp
	add $t4,$t4,$sp
	# S0=fib[i-1]
	lw $s0,($t4)
  
	# ss1=fib[i-2]
	subi $t4,$t4,4
	lw $s1,($t4)
  
	addi $t4,$t4,8
	add $s2,$s0,$s1
	sw	$s2,($t4)
  
	# index++
	addi $t2,$t2,1
	j loop
  
	# when n==1:
	end:
  
	li $v0,4
	la $a0,messageOutput
	syscall
  
	li $v0,1
	or $a0,$0,1
	syscall
  
	li $v0,10
	syscall
  
	exit:
  
	li $v0,4
	la $a0,messageOutput
	syscall
  
	li $v0,1
	or $a0,$0,$s2
	syscall
  
  # 栈空间复原
	addu $sp,$sp,$t1
  
	li $v0,10
	syscall
  
```
运行截图：
fib[1]=1
![result](fib1.png "result")
![result](fib2.png "result")
正确！