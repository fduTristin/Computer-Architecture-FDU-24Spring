## Daniel J. Ellard -- 02/27/94
## fib-o.asm-- A program to compute Fibonacci numbers.
## An optimized version of fib-t.asm.
## main--
## Registers used:
## $v0 - syscall parameter and return value.
## $a0 - syscall parameter-- the string to print.
        .text
main:
    subu $sp, $sp, 32 # Set up main’s stack frame:
    sw $ra, 28($sp)
    sw $fp, 24($sp)
    addu $fp, $sp, 32

    ## Get n from the user, put into $a0.
    li $v0, 5 # load syscall read_int into $v0.
    syscall # make the syscall.
    move $a0, $v0 # move the number read into $a0.
    jal fib # call fib.

    move $a0, $v0
    li $v0, 1 # load syscall print_int into $v0.
    syscall # make the syscall.

    la $a0, newline
    li $v0, 4
    syscall # make the syscall.

    li $v0, 10 # 10 is the exit syscall.
    syscall # do the syscall.

    ## fib-- (hacked-up caller-save method)
    ## Registers used:
    ## $a0 - initially n.

    ## $t0 - parameter n.
    ## $t1 - fib (n - 1).
    ## $t2 - fib (n - 2).
        .text
fib:
    bgt $a0, 1, fib_recurse # if n < 2, then just return a 1,
    li $v0, 1 # don’t build a stack frame.
    li $v1, 1
    jr $ra
    # otherwise, set things up to handle
fib_recurse: # the recursive case:
    subu $sp, $sp, 32 # frame size = 32, just because...
    sw $ra, 28($sp) # preserve the Return Address.
    sw $fp, 24($sp) # preserve the Frame Pointer.
    addu $fp, $sp, 32 # move Frame Pointer to new base.

    # compute fib (n - 1):
    sub $a0, $a0, 1 # compute fib (n - 1)
    jal fib

    add $v0, $v0, $v1 # $v0 = fib (n - 1) + fib (n - 2)
    sub $v1, $v0, $v1 # $v1 = fib (n - 1)
    lw $ra, 28($sp) # restore Return Address.
    lw $fp, 24($sp) # restore Frame Pointer.
    addu $sp, $sp, 32 # restore Stack Pointer.
    jr $ra # return.

## data for fib-o.asm:
.data
    newline: .asciiz "\n"

## end of fib-o.asm
