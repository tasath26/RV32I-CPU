lui   x1, 1         # x1 = 0x00001000
auipc x2, 0         # x2 = PC (address of this instruction)
addi  x3, x1, 1     # x3 = 0x00001001
lui   x4, 0xABCDE   # x4 = 0xABCDE000

addi x20, x0, 99
loop: beq x0, x0, loop
