import rv32i_pkg::*;

module instr_coverage
(
  input logic        clk,
  input logic        rst,
  input logic        valid,
  input logic [6:0]  opcode,
  input logic [2:0]  funct3,
  input logic [6:0]  funct7
);

  covergroup cg_r_type @(posedge clk iff (!rst && valid && opcode == OPCODE_R_TYPE));
    cp_funct3: coverpoint funct3 {
      bins add_sub = {FUNCT3_ADD_SUB};
      bins sll     = {FUNCT3_SLL};
      bins slt     = {FUNCT3_SLT};
      bins sltu    = {FUNCT3_SLTU};
      bins xor_b   = {FUNCT3_XOR};
      bins srl_sra = {FUNCT3_SRL_SRA};
      bins or_b    = {FUNCT3_OR};
      bins and_b   = {FUNCT3_AND};
    }
    cp_funct7: coverpoint funct7 {
      bins add = {FUNCT7_ADD};
      bins sub = {FUNCT7_SUB};
      bins srl = {FUNCT7_SRL};
      bins sra = {FUNCT7_SRA};
    }
    cx_r_isa: cross cp_funct3, cp_funct7 {
      ignore_bins invalid =
        binsof(cp_funct3) intersect {FUNCT3_SLL, FUNCT3_SLT, FUNCT3_SLTU, FUNCT3_XOR, FUNCT3_OR, FUNCT3_AND}
        && binsof(cp_funct7) intersect {FUNCT7_SUB, FUNCT7_SRA};
    }
  endgroup

  cg_r_type cg_r_type_inst = new();

endmodule
