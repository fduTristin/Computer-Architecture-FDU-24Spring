# File:         p1.asm
# Written by:   Larry Merkle, Dec. 4, 2002
# Modified by:  J.P. Mellor, 3 Sep. 2004
# Modified by:  J.P. Mellor, 2 Dec. 2008
#
# This file contains a MIPS assembly language program that uses only the 
# following instructions:
#
#   ori rt, rs, imm	- Puts the bitwise OR of register rs and the
#			  zero-extended immediate into register rt
#   add rd, rs, rt	- Puts the sum of registers rs and rt into register rd.
#   syscall		- Register $v0 contains the number of the system
#			  call provided by SPIM (when $v0 contains 10,
#			  this is an exit statement).
#
# It calculates 40 + 17.
#
# It is intended to help CSSE 232 students familiarize themselves with MIPS
# and SPIM.
				
	.globl main		# Make main globl so you can refer to
				# it by name in SPIM.

	.text			# Text section of the program
				# (as opposed to data).

main:				# Program starts at main.
        ori	$t2, $0, 40	# Register $t2 gets 40
	ori	$t3, $0, 17	# Register $t3 gets 17
	add	$t3, $t2, $t3	# Register $t3 gets 40 + 17

	ori	$0, $0, 40	# Register $0 appears to get 40 ...
	ori	$t4, $0, 0	# ... but it really doesn't

	ori	$v0, $0, 10	# Prepare to exit
	syscall			#   ... Exit.

