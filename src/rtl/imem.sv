//============================================================
// File:          imem.sv
// Author:        Tasos Athanasiadis 
// Date:          6/06/2026
//
// Description:
//    The Instruction memory of the CPU core. 
//    Its contents are going to be read from a file.
//    The instruction memory is 4KB
//
// Inputs:
//    addr      : The memory address of the next instruction 
//
// Outputs:
//    instr     : The instruction
//============================================================

module imem #(
    parameter IMEM_FILE = "simple.hex"
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);
    logic [31:0] mem [0:255]; 

    initial $readmemh(IMEM_FILE, mem);

    assign instr = mem[addr[31:2]]; 

endmodule
