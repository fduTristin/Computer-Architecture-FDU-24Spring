.data
	number1: .word 5
	number2: .word 10
.text
main:
	lw $t0,number1($zero)
	lw $t1,number2($zero)
	
	add $t2,$t1,$t0
	
	li $v0,1
	move $a0,$t2
	syscall