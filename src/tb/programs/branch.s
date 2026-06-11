addi x1, x0, 5         # PC = 0
addi x2, x0, 5         # PC = 4
addi x3, x0, 3         # PC = 8

beq  x1, x2, beq_ok    # PC = C     should take
addi x10, x0, 1        # PC = 10
beq_ok:
bne  x1, x3, bne_ok    # PC = 14    should take
addi x10, x0, 2        # PC = 18
bne_ok:
blt  x3, x1, blt_ok    # PC = 1C    should take (3 < 5)
addi x10, x0, 3        # PC = 20
blt_ok:
bge  x1, x3, bge_ok    # PC = 24    should take (5 >= 3)
addi x10, x0, 4        # PC = 28    should skip
bge_ok:
addi x20, x0, 99       # PC = 2C    x20 = 99
loop: beq x0, x0, loop # PC = 30
