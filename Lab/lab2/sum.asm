main:
    # 初始化寄存器
    addi $t0, $zero, 1          # $t0 存储当前要累加的数值
    addi $t1, $zero, 0          # $t1 用于累加和的结果

loop:
    # 将当前数值累加到结果中
    add $t1, $t1, $t0

    # 增加当前数值
    addi $t0, $t0, 1

    # 检查是否已经计算到10
    slti $t2, $t0, 11       # 11是计算到10
    bne $t2, $zero, loop       # 如果当前数值小于11，则继续循环

    # 存储结果
    sw $t1, 48($zero)
