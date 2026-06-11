
## RV32I-CPU

## Description
A RV32I CPU, Design, Implementation and verification. 


## Specification

This project implements an RV32I RISC-V Processor.
It supports basic integer, memory, and control flow instructions and will be
eventually extended to support a 5-stage pipeline and branch prediction techniques.


![Block Diagram](./screenshots/block_diagram.png)

#### Supported Instruction Set

The RISC-V RV32I Instructions excluding ecall and ebreak.

#### Datapath / Architectural Blocks
``` 
- Register File
- ALU
- Control Unit
- Branch Evaluation Unit
- Memory Operation Unit
- Immediate Generator
- Instruction Memory
- Data Memory
- Program Counter (PC) + Next PC Logic
- Pipeline Control Unit
``` 

---

Tests:
```
    - simple:       Tests basic instructions.
    - alu:          Tests all alu operations.
    - branch:       Tests branch operations. 
    - jump:         Tests changes in control flow.
    - loadstore:    Tests memory operations. 
    - lui_auipc:    Tests lui and auipc instructions.
``` 

---

## Requirements
riscv toolchain
icarus 
GTKWave

## Usage 
```bash
make tests 
make run TEST=<testfile> (without the .hex suffix) 

```

## Link and Material

- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- [RISC-V Instruction Reference](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf)
- [RISC-V Instruction Guide](https://lhtin.github.io/01world/app/riscv-isa/?xlen=32)
- [CS-225 Pipeline Lecture](https://www.csd.uoc.gr/~hy225/21a/09b_noDep.pdf)
- [Icarus Verilog](https://github.com/steveicarus/iverilog)
- [GTKWave](https://github.com/gtkwave/gtkwave)

