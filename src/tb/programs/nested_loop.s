    li x5, 0          # outer = 0
    li x6, 5          # outer limit

outer_loop:
    li x7, 0          # inner = 0
    li x8, 10         # inner limit

inner_loop:
    addi x7, x7, 1    # inner++

    blt x7, x8, inner_loop

    addi x5, x5, 1    # outer++

    blt x5, x6, outer_loop

done:
    nop
