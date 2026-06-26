//============================================================
// File:          alu.sv
// Author:        Tasos Athanasiadis 
// Date:          1/06/2026
//
// Description:
//    The Arithmetic Logic Unit. Performs all the 
//    arithmetic and logic instructions.
//
// Inputs:
//   alu_op         : The custom ALU Opcode defined in rv32i_pkg
//   alu_port_a     : ALU Operand 1
//   alu_port_b     : ALU Operand 2
//
// Outputs:
//   alu_result     : The result of the expression
//============================================================

import rv32i_pkg::*;

module alu
(
  input logic [3:0] alu_op,
  input logic [31:0] alu_port_a,
  input logic [31:0] alu_port_b,
  output logic [31:0] alu_result
);
 
always_comb begin
    case (alu_op)
        ALU_ADD: alu_result = alu_port_a + alu_port_b;
        ALU_SUB: alu_result = alu_port_a - alu_port_b;
        ALU_AND: alu_result = alu_port_a & alu_port_b;
        ALU_OR:  alu_result = alu_port_a | alu_port_b;
        ALU_XOR: alu_result = alu_port_a ^ alu_port_b;
        ALU_SLL: alu_result = alu_port_a << alu_port_b[4:0];
        ALU_SRL: alu_result = alu_port_a >> alu_port_b[4:0];
        ALU_SRA: alu_result = $signed(alu_port_a) >>> alu_port_b[4:0];
        ALU_SLT: alu_result = ($signed(alu_port_a) < $signed(alu_port_b)) ? 32'd1 : 32'd0;
        ALU_SLTU:alu_result = ($unsigned(alu_port_a) < $unsigned(alu_port_b)) ? 32'd1 : 32'd0;
        ALU_LUI: alu_result = alu_port_b;
        default: alu_result = 32'd0;
    endcase
    
end

endmodule
