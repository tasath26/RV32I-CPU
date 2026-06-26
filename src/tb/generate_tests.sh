#!/bin/bash

tests=("simple" "alu" "branch" "loadstore" "lui_auipc" "jump" "stall" "forwarding" "loop" "nested_loop")

echo -e "\n\n"
echo "        Generating Tests"
echo "================================="
total=${#tests[@]}
for i in "${!tests[@]}"; do
    test=${tests[$i]}
    current=$((i + 1))
    riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 programs/${test}.s -o ${test}.o
    riscv64-linux-gnu-objcopy -O binary ${test}.o ${test}.bin
    python3 tohex.py ${test}.bin testfiles/${test}.hex
    echo "Generated Test [$current/$total]: ${test}.hex"
done
echo "================================="

rm -rf *.o *.bin
echo "              Done"
echo -e "\n\n"

