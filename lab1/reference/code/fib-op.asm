## Daniel J. Ellard -- 02/27/94
2 ## fib-o.asm-- A program to compute Fibonacci numbers.
3 ## An optimized version of fib-t.asm.
4 ## main--
5 ## Registers used:
6 ## $v0 - syscall parameter and return value.
7 ## $a0 - syscall parameter-- the string to print.
8 .text
9 main:
10 subu $sp, $sp, 32 # Set up main’s stack frame:
11 sw $ra, 28($sp)
12 sw $fp, 24($sp)
13 addu $fp, $sp, 32
14
15 ## Get n from the user, put into $a0.
16 li $v0, 5 # load syscall read_int into $v0.
17 syscall # make the syscall.
18 move $a0, $v0 # move the number read into $a0.
19 jal fib # call fib.
20
21 move $a0, $v0
22 li $v0, 1 # load syscall print_int into $v0.
23 syscall # make the syscall.
24
25 la $a0, newline
26 li $v0, 4
27 syscall # make the syscall.
28
29 li $v0, 10 # 10 is the exit syscall.
30 syscall # do the syscall.
31
32 ## fib-- (hacked-up caller-save method)
33 ## Registers used:
34 ## $a0 - initially n.
5.8. FIB-O.ASM 85
35 ## $t0 - parameter n.
36 ## $t1 - fib (n - 1).
37 ## $t2 - fib (n - 2).
38 .text
39 fib:
40 bgt $a0, 1, fib_recurse # if n < 2, then just return a 1,
41 li $v0, 1 # don’t build a stack frame.
42 jr $ra
43 # otherwise, set things up to handle
44 fib_recurse: # the recursive case:
45 subu $sp, $sp, 32 # frame size = 32, just because...
46 sw $ra, 28($sp) # preserve the Return Address.
47 sw $fp, 24($sp) # preserve the Frame Pointer.
48 addu $fp, $sp, 32 # move Frame Pointer to new base.
49
50 move $t0, $a0 # get n from caller.
51
52 # compute fib (n - 1):
53 sw $t0, 20($sp) # preserve n.
54 sub $a0, $t0, 1 # compute fib (n - 1)
55 jal fib
56 move $t1, $v0 # t1 = fib (n - 1)
57 lw $t0, 20($sp) # restore n.
58
59 # compute fib (n - 2):
60 sw $t1, 16($sp) # preserve $t1.
61 sub $a0, $t0, 2 # compute fib (n - 2)
62 jal fib
63 move $t2, $v0 # t2 = fib (n - 2)
64 lw $t1, 16($sp) # restore $t1.
65
66 add $v0, $t1, $t2 # $v0 = fib (n - 1) + fib (n - 2)
67 lw $ra, 28($sp) # restore Return Address.
68 lw $fp, 24($sp) # restore Frame Pointer.
69 addu $sp, $sp, 32 # restore Stack Pointer.
70 jr $ra # return.
71
72 ## data for fib-o.asm:
73 .data
74 newline: .asciiz "\n"
75
76 ## end of fib-o.asm
