# File:         p2.asm
# Written by:   Larry Merkle, Dec. 4, 2002
# Modified by:  J.P. Mellor, 3 Sep. 2004
#
# This file contains a MIPS assembly language program that uses only the
# instructions introduced in p1.asm plus the following:
#
#   lui rdest, imm	- Loads the immediate imm into the upper halfword
#			  of register rt.  The lower bits of the register
#			  are set to 0.
#   li rdest, imm	- Moves the immediate imm into register rdest.
#			  This pseudoinstruction actually translates into
#			  lui and ori.
#
# It demonstrates the behavior of the lui instruction and the expansion
# of the li instruction
#
# It is intended to help CSSE 232 students familiarize themselves with MIPS
# and SPIM.

	.globl main		# Make MAIN globl so you can refer to
				# it by name in SPIM.

	.text			# Text section of the program
				# (as opposed to data).

main:				# Program starts at main.
        ori	$t2, $0, 40	# Register $t2 gets 40
	lui	$t2, 0x1234	# Upper half of register $t2 gets 0x1234
        ori	$t2, $t2, 40	# Lower half of register $t2 gets 40

	li	$t3, 0x12340028 # Register $t3 gets 0x12340028

	li	$v0, 10		# Prepare to exit
	syscall			#   ... Exit.

