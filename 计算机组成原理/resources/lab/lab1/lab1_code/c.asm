# #include <stdio.h>
# int sumn(int *arr, int n)
# {
# int sum = 0;
# for (int idx = 0; idx < n; idx++)
# sum += arr[idx];
# return sum;
# }
# int main()
# {
# int arrs[] = {9, 7, 15, 19, 20, 30, 11, 18};
# int N = 8;
# int result = sumn(arrs, N);
# printf("The result is: %d", result);
# return 0;
# }

.data 
	myArrays:	.space 32
	result:		.asciiz "The result is: "
.text
main:
	# ���鸳��ֵ
	# $t0:index,ÿ�μ�4������Ѱַ
	or $t0,$0,$0
    ori $t1,$0,9
    sw  $t1,myArrays($t0)
    
    addi $t0,$t0,4
    ori $t1,$0,7
    sw  $t1,myArrays($t0)
    
    addi $t0,$t0,4
    ori $t1,$0,15
    sw  $t1,myArrays($t0)
	
	addi $t0,$t0,4
    ori $t1,$0,19
    sw  $t1,myArrays($t0)    
    
	addi $t0,$t0,4
    ori $t1,$0,20
    sw  $t1,myArrays($t0)
    
    addi $t0,$t0,4
    ori $t1,$0,30
    sw  $t1,myArrays($t0)
    
    addi $t0,$t0,4
    ori $t1,$0,11
    sw  $t1,myArrays($t0)
    
    addi $t0,$t0,4
    ori $t1,$0,18
    sw  $t1,myArrays($t0)
    
    # N=8
    ori $t2,$0,8
    
    # ������������������$a0,$a1��
    la $a0,myArrays
    or $a1,$0,$t2
    # ���ú���sumn
    jal sumn
    
    # �洢����ֵ
    or $s0,$0,$v0
    
    # ��ӡresult
    li $v0,4
    la $a0,result
    syscall
    
    # ��ӡ������
    li $v0,1
    or $a0,$0,$s0
   	syscall
    
    #end
     li $v0,10
     syscall
    
sumn:
	# ��ջ
	subu $sp,$sp,32
	sw $ra, 28($sp) 
	sw $fp, 24($sp) 
	addu $fp, $sp, 32 

	# sum=0
	or $t0,$0,$0
	# index
	or $t1,$0,$0
	j loop
loop:
	# index>=N ���˳�
	slt $t2,$t1,$a1   	
	beq $t2,0,exit
	
	# ����ƫ��ֵ
	mul $t3,$t1,4
	add $s0,$a0,$t3
	# ��������ȡֵ
	lw 	$t4,($s0)
	# �ۼ�
	add $t0,$t0,$t4
	
	# index++
	addi $t1,$t1,1
	
	j loop
	 
exit:
    or $v0,$0,$t0
    # return 
 	lw $ra, 28($sp) # restore Return Address.
	lw $fp, 24($sp) # restore Frame Pointer.
	addu $sp, $sp, 32 # restore Stack Pointer.
	jr $ra
    
    
    
