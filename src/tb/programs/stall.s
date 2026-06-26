addi x5, x0, 42   # x5 = 42
sw   x5, 0(x0)    # mem[0] = 42
lw   x1, 0(x0)    # x1 = 42  — triggers load-use stall
add  x2, x1, x1   # x2 = 84  — needs x1
halt: beq x0, x0, halt
