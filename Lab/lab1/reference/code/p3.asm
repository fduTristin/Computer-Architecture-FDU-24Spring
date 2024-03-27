# File:         p3.asm
# Written by:   Larry Merkle, Dec. 4, 2002
# Modified by:  J.P. Mellor, 3 Sep. 2004
#
# This file contains a MIPS assembly language program that uses only the
# instructions introduced in p1.asm and p2.asm plus the following:
#
#   la rdest, address   - Loads a computed address -- not the contents of
#                         the location -- into register rdest.  This
#                         pseduoinstruction actually translates into lui
#                         and ori, which were explained in p2.asm.
#   lw rt, address      - Load the 32-bit quantity (word) at address
#                         into register rt.
#   sw rt, address      - Store the word from register rt at address.
#
# It implements the high-level language statement A[12] = h + A[8]; .
#
# It is intended to help CSSE 232 students familiarize themselves with MIPS
# and SPIM.

        .globl main             # Make main, A, and h globl so you can
        .globl A                # refer to them by name in SPIM.
        .globl h


        .data                   # Data section of the program

A:      .word   1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 50
h:      .word   40

        .text                   # Text section of the program
        
main:                           # Program starts at main.
        la      $t0, h          # Register $t0 gets address of h

        la      $t1, A          # Register $t1 gets address of A

        lw      $t2, 0($t0)     # Register $t2 gets h

        lw      $t3, 32($t1)    # Register $t3 gets A[8]

        add     $t3, $t2, $t3   # Register $t3 gets h + A[8]

        sw      $t3, 48($t1)    # A[12] gets h + A[8]

        li      $v0, 10         # Prepare to exit
        syscall                 #   ... Exit.
