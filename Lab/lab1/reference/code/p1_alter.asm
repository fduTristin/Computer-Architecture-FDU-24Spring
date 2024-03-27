.data
	str1:		.asciiz "Please enter 1st number: "	
	str2:		.asciiz "Please enter 2nd number: "	
	res:		.asciiz "The result of "
	charand:		.asciiz " & "
	is:		.asciiz " is: "
	ques:		.asciiz "Do you want to try another(0—continue/1—exit): "
	newline:	.asciiz "\n"


.text			
.globl main

main :				# Program starts at main.
	# print str1
	la     $a0,str1
	li	$v0,4
	syscall
	
	# get num1
	li 	$v0,5
	syscall
	or 	$t0, $0, $v0		# save num1 to $t0

	# print str2
	la     $a0,str2
	li	$v0,4
	syscall
	
	# get num2
	li 	$v0,5
	syscall
	or 	$t1, $0, $v0		# save num2 to $t1

	# add two numbers
	add	$t2, $t0, $t1	# Register $t2 gets num1+num2

	# print res
	la     $a0,res
	li	$v0,4
	syscall

	# print num1
	or     $a0,$0,$t0
	li	$v0,1
	syscall

	# print charand
	la     $a0,charand
	li	$v0,4
	syscall

	# print num2
	or     $a0,$0,$t1
	li	$v0,1
	syscall

	# print is
	la     $a0,is
	li	$v0,4
	syscall

	# print sum
	or     $a0,$0,$t2
	li	$v0,1
	syscall

	la     $a0,newline
	li	$v0,4
	syscall

	# branch
	
	# print ques
	la     $a0,ques
	li	$v0,4
	syscall

	# get ans
	li 	$v0,5
	syscall

	# loop if 0
	beq $v0,$zero,main


	ori	$v0, $0, 10	# Prepare to exit
	syscall			#   ... Exit.

