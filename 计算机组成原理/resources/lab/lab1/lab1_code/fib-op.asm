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
	
	# 循环内部
	# $t4=$t2-1
	sub $t4,$t2,1
	# t4=t4*4
	mul $t4,$t4,4
	# t4=$t4+$sp
	add $t4,$t4,$sp
	# S0=fib[i-1]
	lw $s0,($t4)
	
	# ss1=fib[i-2]
	sub $t4,$t4,4
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
	
	
