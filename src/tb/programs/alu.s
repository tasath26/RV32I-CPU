addi x1, x0, 10     # x1 = 10
addi x2, x0, 3      # x2 = 3
add  x3, x1, x2     # x3 = 13
sub  x4, x1, x2     # x4 = 7
and  x5, x1, x2     # x5 = 2
or   x6, x1, x2     # x6 = 11
xor  x7, x1, x2     # x7 = 9
sll  x8, x1, x2     # x8 = 80  (10 << 3)
srl  x9, x1, x2     # x9 = 1   (10 >> 3)
slt  x10, x2, x1    # x10 = 1  (3 < 10)
slt  x11, x1, x2    # x11 = 0  (10 < 3)
loop: beq x0, x0, loop
