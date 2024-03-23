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
        li $v0,4
        la $a0,hint1
        syscall

        # get input
        li $v0,5
        syscall
        or	$t0, $0, $v0	# Register $t0 gets the 1st value

      # get the second number
        # print hint2
        li $v0,4
        la $a0,hint2
        syscall

        # get input
        li $v0,5
        syscall
        or	$t1, $0, $v0	# Register $t1 gets the 2nd value
        
        # add $t0,$t1
        add $t2,$t0,$t1

		# print result
        li $v0,4
        la $a0,result
        syscall

        # print 1st number
        li $v0,1
        or $a0, $0, $t0
        syscall

        li $v0,4
        la $a0,space
        syscall

        li $v0,4
        la $a0,char_and
        syscall

        # print 2nd number
        li $v0,1
        or $a0, $0, $t1
        syscall

        li $v0,4
        la $a0,is
        syscall

        # print result
        li $v0,1
        or $a0, $0, $t2
        syscall

        li $v0,4
        la $a0,newline
        syscall

      # branch  
        li $v0,4
        la $a0,another
        syscall

        li $v0,5
        syscall
        
        beq $v0,$zero,main

        li $v0,10
        syscall

