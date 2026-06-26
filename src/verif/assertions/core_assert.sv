import rv32i_pkg::*;

module core_assert
(
  input logic        clk,
  input logic        rst,
  input logic [31:0] pc,
  input logic [6:0]  opcode,
  input logic [2:0]  funct3,
  input logic [6:0]  funct7,
  input logic [4:0]  rs1, 
  input logic [4:0]  rs2,
  input logic [4:0]  rd
);

always_comb begin

  // PC assertions
  V_CORE_PC_KNOWN:    assert (!$isunknown(pc));
  V_CORE_PC_ALIGNED:  assert (pc[1:0] == 2'b00); 

  // Opcode assertions
  V_CORE_OPCODE_KNOWN: assert (!$isunknown(opcode));

  V_CORE_OPCODE: assert (
    opcode inside {
      OPCODE_R_TYPE,
      OPCODE_I_TYPE,
      OPCODE_JAL,
      OPCODE_LUI,
      OPCODE_LOAD,
      OPCODE_JALR,
      OPCODE_STORE,
      OPCODE_AUIPC,
      OPCODE_BRANCH,
      7'b0           // For flushes
    }
  );

  // funct3 assertions

  V_CORE_FUNCT3_KNOWN: assert (!$isunknown(funct3));

  case(opcode)

    OPCODE_R_TYPE,
    OPCODE_I_TYPE: V_CORE_FUNCT3_R_I: assert (
      funct3 inside{
        FUNCT3_ADD_SUB,
        FUNCT3_SLL,    
        FUNCT3_SLT,   
        FUNCT3_SLTU,   
        FUNCT3_XOR,    
        FUNCT3_SRL_SRA,
        FUNCT3_OR,       
        FUNCT3_AND 
      }
    );


    OPCODE_LOAD:  V_CORE_FUNCT3_LOAD: assert (
      funct3 inside{
        FUNCT3_LB, 
        FUNCT3_LH,  
        FUNCT3_LW,  
        FUNCT3_LBU, 
        FUNCT3_LHU 
      }
    );

    OPCODE_STORE: V_CORE_FUNCT3_STORE: assert (
      funct3 inside{
        FUNCT3_SB,
        FUNCT3_SH,
        FUNCT3_SW
      }
    );

    OPCODE_BRANCH: V_CORE_FUNCT3_BRANCH: assert (
      funct3 inside{
        FUNCT3_BEQ,  
        FUNCT3_BNE,  
        FUNCT3_BLT,  
        FUNCT3_BGE,  
        FUNCT3_BLTU, 
        FUNCT3_BGEU 
      }
    );

    OPCODE_AUIPC,
    OPCODE_LUI,
    OPCODE_JALR,
    7'b0,
    OPCODE_JAL: ;

    default: assert(0);

  endcase

  // funct7 assertions

  V_CORE_FUNCT7_KNOWN: assert (!$isunknown(funct7));
  
  case (opcode)

    OPCODE_R_TYPE: V_CORE_FUNCT7_R: assert (
      funct7 inside{
        FUNCT7_ADD,       
        FUNCT7_SUB, 
        FUNCT7_SRL, 
        FUNCT7_SRA 
      }
    );

    OPCODE_I_TYPE,
    OPCODE_JAL,
    OPCODE_LUI,
    OPCODE_LOAD,
    OPCODE_JALR,
    OPCODE_STORE,
    OPCODE_AUIPC,
    7'b0,
    OPCODE_BRANCH: ;
 
    default : assert(0); 
  
  endcase

  // Register address assertions
  V_CORE_RS1_ADDRESS: assert (!$isunknown(rs1)); 
  V_CORE_RS2_ADDRESS: assert (!$isunknown(rs2));
  V_CORE_RD_ADDRESS : assert (!$isunknown(rd));

end

endmodule
