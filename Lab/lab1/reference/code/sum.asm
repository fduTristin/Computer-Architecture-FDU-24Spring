.data
	arr:  .space 32		#未初始化
	res:  .asciiz "The result is: "
				
	

.text			# Text section of the program
				# (as opposed to data).

sumn:
	#返回地址压栈
	subu	   $sp,$sp,32
	sw       $ra,32($sp)

	#sum=0
	or        $t3,$0,$0
	#index = 0
	or       $t0,$0,$0

branch:
	#branch if index != N
	bne    $t0,$a1,loop

	# else exit
	or         $v0,$0,$t3
	lw         $ra,32($sp)
	addu     $sp,$sp,32
	jr          $ra


loop:
	#计算偏移量
	mul       $t1,$t0,4
	add       $t1,$t1,$a0

	#取值
	lw          $t2,($t1)

	#累加
	add        $t3,$t3,$t2

	#index+1
	add        $t0,$t0,1

	j   branch

main:				# Program starts at main.
	#数组赋初值

	#array[0]
	or          $t0,$0,$0
	ori         $t1,$0,9
	sw          $t1,arr($t0)


	#array[1]
	addu      $t0,$t0,4
	ori         $t1,$0,7
	sw          $t1,arr($t0)

	#array[2]
	addu      $t0,$t0,4
	ori         $t1,$0,15
	sw          $t1,arr($t0)

	#array[3]
	addu      $t0,$t0,4
	ori         $t1,$0,19
	sw          $t1,arr($t0)

	#array[4]
	addu      $t0,$t0,4
	ori         $t1,$0,20
	sw          $t1,arr($t0)

	#array[5]
	addu      $t0,$t0,4
	ori         $t1,$0,30
	sw          $t1,arr($t0)
	
	#array[6]
	addu      $t0,$t0,4
	ori         $t1,$0,11
	sw          $t1,arr($t0)

	#array[7]
	addu      $t0,$t0,4
	ori         $t1,$0,18
	sw          $t1,arr($t0)

	#N=8
	ori         $t2,$0,8

	#传参
	la          $a0,arr
	or         $a1,$0,$t2

	#调用sumn
	jal         sumn

	#存储返回值
	or         $s0,$0,$v0

	#打印结果
	li          $v0,4
	la         $a0,res
	syscall
	
	li          $v0,1
	or        $a0,$0,$s0
	syscall

	#返回
	li          $v0,10
	syscall

