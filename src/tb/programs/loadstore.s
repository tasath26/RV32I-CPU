addi x1, x0, 42
addi x2, x0, 100    # base address

sw   x1, 0(x2)      # mem[100] = 42
lw   x3, 0(x2)      # x3 = 42

addi x4, x0, 0x7F   # x4 = 127
sw   x4, 4(x2)      # mem[104] = 127
lb   x5, 4(x2)      # x5 = 127 (sign extended)

addi x6, x0, -1     # x6 = 0xFFFFFFFF
sw   x6, 8(x2)      # mem[108] = 0xFFFFFFFF
lb   x7, 8(x2)      # x7 = -1  (sign extended)
lbu  x8, 8(x2)      # x8 = 255 (zero extended)

addi x20, x0, 99    # x20 = 99, all loads/stores worked
loop: beq x0, x0, loop
