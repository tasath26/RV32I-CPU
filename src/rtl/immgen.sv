//============================================================
// File:          immgen.sv
// Author:        Tasos Athanasiadis 
// Date:          6/06/2026
//
// Description:
//   This sign extends the immediate value from instructions
//
// Inputs:
//    instr     : The current instruction 
// Outputs:
//    immediate : The immediate extracted from the instruction
//============================================================
import rv32i_pkg::*;

module immgen
(
  input  logic   [31:0] instr,
  output logic   [31:0] imm
);

logic [6:0] opcode;
assign opcode = instr[6:0];

always_comb begin
  imm = 32'b0;

  case (opcode)
    
    // Immediate on bits [31:20]
    OPCODE_LOAD,
    OPCODE_JALR: begin 
    	imm = {{20{instr[31]}}, instr[31:20]};
    end

    OPCODE_I_TYPE: begin
      if (instr[14:12] == 3'b001 || instr[14:12] == 3'b101) begin
          // SLLI, SRLI, SRAI
          imm = {27'b0, instr[24:20]};   
        end
        else begin
          imm = {{20{instr[31]}}, instr[31:20]};
        end
    end

    // Immediate on bits [31:20] + [11:7]
    OPCODE_STORE: begin
      imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    end

    OPCODE_BRANCH: begin
      imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    end

    OPCODE_LUI,
    OPCODE_AUIPC: begin
      imm = {instr[31:12], 12'b0};
    end

    OPCODE_JAL: begin
      imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    end

    default : imm = 32'b0; 
  endcase

end


endmodule
