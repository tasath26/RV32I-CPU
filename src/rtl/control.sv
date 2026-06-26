//============================================================
// File:          control.sv
// Author:        Tasos Athanasiadis 
// Date:          1/06/2026
//
// Description:
//    The control unit for the core, Decodes the instruction 
//    and propagates the corresponding control signals. 
//
// Inputs:
//    opcode            : The instruction's opcode
//    funct3            : Instruction's funct3 segment if any.
//    funct7            : Instruction's funct7 segment 
//                          (only used by R and I types)
// Outputs:
//    reg_write         : Enable Writing to Register File 
//    mem_write         : Enable Writing to DMEM 
//    mem_read          : Enable Reading from DMEM
//    alu_src_a         : ALU Source for first operand 
//                         0 = rs1 
//                         1 = PC (for instructions: JAL, and AUIPC)
//    alu_src_b         : ALU Source for second operand 
//                         0 = rs2 
//                         1 = Immediate 
//    wb_sel            : Write-back Select 
//                         0 = ALU 
//                         1 = DMEM 
//                         2 = Control Change
//    branch            : Branch instruction enable
//    jump              : Jump Instruction enable
//    mem_type          : The specific Load/Store operation based on opcode
//    branch_type       : The specific Branch operation based on opcode
//    alu_op            : Specific ALU operation based on opcode
//============================================================

import rv32i_pkg::*;

module control 
(
  input logic [6:0]   opcode,
  input logic [2:0]   funct3, 
  input logic [6:0]   funct7,

  output logic        reg_write,  
  output logic        mem_write,  
  output logic        mem_read,  
  output logic        alu_src_a,    
  output logic        alu_src_b,    
  output logic [1:0]  wb_sel,     
  output logic        branch,     
  output logic        jump,       
  
  output logic [2:0]  mem_type,    
  output logic [2:0]  branch_type, 

  output logic [3:0] alu_op 
);

localparam ENABLE = 1;

always_comb begin
  reg_write   = 0;
  mem_write   = 0;
  mem_read    = 0;
  alu_src_a   = 0;
  alu_src_b   = 0;
  wb_sel      = 0;
  branch      = 0;
  jump        = 0;
  alu_op      = 0;
  mem_type    = 0;
  branch_type = 0;

  case (opcode) 

    // R-Type Instructions
    OPCODE_R_TYPE: begin
      reg_write = ENABLE;
      alu_src_a = ALU_SRC_RS1;
      alu_src_b = ALU_SRC_RS2;
      wb_sel    = WB_SEL_ALU;

      case (funct3) 
        FUNCT3_ADD_SUB: begin
            case (funct7)
              FUNCT7_ADD: alu_op = ALU_ADD;
              FUNCT7_SUB: alu_op = ALU_SUB;
              default :   alu_op = ALU_INV;
            endcase 
         end

         FUNCT3_SRL_SRA: begin
            case (funct7)
              FUNCT7_SRL: alu_op = ALU_SRL;
              FUNCT7_SRA: alu_op = ALU_SRA;
              default :   alu_op = ALU_INV; 
            endcase 
         end

         FUNCT3_XOR:  alu_op = ALU_XOR;  
         FUNCT3_OR:   alu_op = ALU_OR;
         FUNCT3_AND:  alu_op = ALU_AND;
         FUNCT3_SLL:  alu_op = ALU_SLL;
         FUNCT3_SLT:  alu_op = ALU_SLT;
         FUNCT3_SLTU: alu_op = ALU_SLTU;
         default :    alu_op = ALU_INV; 
      endcase
    end



    // I-Type Instructions
    OPCODE_I_TYPE: begin
      reg_write = ENABLE;
      alu_src_b   = ALU_SRC_IMM;
      wb_sel    = WB_SEL_ALU;

      case (funct3)
         FUNCT3_SRL_SRA: begin
            case (funct7)
              FUNCT7_SRL: alu_op = ALU_SRL;
              FUNCT7_SRA: alu_op = ALU_SRA;
              default :   alu_op = ALU_INV; 
            endcase 
         end

         FUNCT3_ADDI: alu_op = ALU_ADD;
         FUNCT3_XOR:  alu_op = ALU_XOR;  
         FUNCT3_OR:   alu_op = ALU_OR;
         FUNCT3_AND:  alu_op = ALU_AND;
         FUNCT3_SLL:  alu_op = ALU_SLL;
         FUNCT3_SLT:  alu_op = ALU_SLT;
         FUNCT3_SLTU: alu_op = ALU_SLTU;
         default :    alu_op = ALU_INV; 
      endcase
    end



    // Load Instructions 
    OPCODE_LOAD: begin
      reg_write = ENABLE;
      mem_read  = ENABLE;
      alu_src_b   = ALU_SRC_IMM;
      wb_sel    = WB_SEL_MEM;
      alu_op    = ALU_ADD;
      
      case (funct3)
        FUNCT3_LB:  mem_type = MEM_LOAD_B;
        FUNCT3_LH:  mem_type = MEM_LOAD_H; 
        FUNCT3_LW:  mem_type = MEM_LOAD_W;
        FUNCT3_LBU: mem_type = MEM_LOAD_BU;
        FUNCT3_LHU: mem_type = MEM_LOAD_HU;
        default :   mem_type = MEM_LOAD_W; 
      endcase

    end


    // Store Instructions 
    OPCODE_STORE: begin
      mem_write = ENABLE;
      alu_src_b   = ALU_SRC_IMM;
      alu_op    = ALU_ADD;

      case (funct3)
        FUNCT3_SB: mem_type = MEM_STORE_B;
        FUNCT3_SH: mem_type = MEM_STORE_H;
        FUNCT3_SW: mem_type = MEM_STORE_W;
        default :  mem_type = MEM_STORE_W; 
      endcase
    end
    
    OPCODE_BRANCH: begin
      branch  = ENABLE;
      alu_src_b = ALU_SRC_RS2;
      
      case (funct3)
        FUNCT3_BEQ:  branch_type = BRANCH_BEQ;
        FUNCT3_BNE:  branch_type = BRANCH_BNE;
        FUNCT3_BLT:  branch_type = BRANCH_BLT;
        FUNCT3_BGE:  branch_type = BRANCH_BGE;
        FUNCT3_BLTU: branch_type = BRANCH_BLTU;
        FUNCT3_BGEU: branch_type = BRANCH_BGEU;
        default :    branch_type = BRANCH_BEQ; 
      endcase
    end


    // JAL
    OPCODE_JAL: begin
      jump      = ENABLE;
      reg_write = ENABLE;
      alu_src_a = ALU_SRC_PC;
      alu_src_b = ALU_SRC_IMM;
      wb_sel    = WB_SEL_PC;
    end



    // JALR
    OPCODE_JALR: begin
      jump      = ENABLE;
      reg_write = ENABLE;
      alu_src_b = ALU_SRC_IMM;
      wb_sel    = WB_SEL_PC;
    end



    // Load Upper Immediate
    OPCODE_LUI: begin
      reg_write = ENABLE;
      alu_src_b = ALU_SRC_IMM;
      wb_sel    = WB_SEL_ALU;
      alu_op    = ALU_LUI;  
    end


    // Add upper immediate to PC 
    OPCODE_AUIPC: begin
      reg_write = ENABLE;
      alu_src_a = ALU_SRC_PC;
      alu_src_b = ALU_SRC_IMM;
      wb_sel    = WB_SEL_ALU;
      alu_op    = ALU_ADD;
    end


    default : alu_op = ALU_INV; 
  endcase
end

endmodule
