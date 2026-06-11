//============================================================
// File:          decode.sv
// Author:        Tasos Athanasiadis 
// Date:          6/06/2026
//
// Description:
//   This module sits at the beginning of the Instruction 
//   decode phase and splits the instruction into the 
//   necessary parts.
//
// Inputs:
//    instr       : The fetched instruction
//
// Outputs:
//    opcode      : The instructions opcode
//    funct3      : The instructions funct3  (if any)
//    funct7      : The instructions funct7  (if any)
//    rs1         : The 1st source register  (if any) 
//    rs2         : The 2nd source register  (if any)
//    rd          : The destination register (if any)
//============================================================


module decode 
(
    input  logic [31:0] instr,

    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd
);
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

endmodule
