//============================================================
// File:          branch_unit.sv
// Author:        Tasos Athanasiadis 
// Date:          1/06/2026
//
// Description:
//    The Comparison unit. Evaluates the logical expressions 
//    to determine whether a branch is taken or not. 
//
// Inputs:
//   br_control_signal  : The branch signal from the control unit 
//                        signifies that we have a branch instr.
//   branch_op          : Which type of branch we have. 
//                        defined in rv32i_pkg
//   br_port_a          : Branch Operand 1
//   br_port_b          : Branch Operand 2
//
// Outputs:
//   br_enable_o        : Sends branch enable signal to change 
//                        the control flow of the program
//============================================================


import rv32i_pkg::*;

module branch_unit
(
  input logic         br_control_signal,
  input logic [2:0]   branch_op,
  input logic [31:0]  br_port_a,
  input logic [31:0]  br_port_b,
  input logic [31:0]  pc,
  input logic [31:0]  imm,
 
  output logic br_taken,
  output logic [31:0] br_target
);

logic result;

always_comb begin 
  result = 0;

  case (branch_op)
    BRANCH_BEQ:  result =  br_port_a == br_port_b;
    BRANCH_BNE:  result =  br_port_a != br_port_b;
    BRANCH_BLTU: result =  br_port_a < br_port_b;
    BRANCH_BGEU: result =  br_port_a >= br_port_b;
    BRANCH_BLT:  result = $signed(br_port_a) <  $signed(br_port_b);
    BRANCH_BGE:  result = $signed(br_port_a) >= $signed(br_port_b); 
   default :     result = 1'b0; 
  endcase

end

assign br_taken = br_control_signal & result;
assign br_target = pc + imm;

endmodule
