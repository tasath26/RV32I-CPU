addi x1, x0, 1
jal  x5, func       # x5 = return addr, jump to func
addi x1, x0, 99     # should be skipped
end: beq x0, x0, end

func:
addi x2, x0, 42
jalr x6, x5, 0      # return to caller
