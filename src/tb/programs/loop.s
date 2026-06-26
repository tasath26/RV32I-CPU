    li x5, 0      
    li x6, 100    

loop_start:
    addi x5, x5, 1   # i++
    blt x5, x6, loop_start  # If x5 < x6, branch to loop_start

    nop
