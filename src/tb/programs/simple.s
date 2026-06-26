# test.s
addi x1, x0, 5      # x1 = 5
addi x2, x0, 3      # x2 = 3
add  x3, x1, x2     # x3 = 8
sw   x3, 0(x0)      # mem[0] = 8
lw   x4, 0(x0)      # x4 = 8
addi x0, x0, 0
beq  x3, x4, done   # branch if x3 == x4
addi x5, x0, 1      # should be skipped
done:
addi x6, x0, 99     # x6 = 99
