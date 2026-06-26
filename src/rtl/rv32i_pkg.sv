package rv32i_pkg;

  // General RISC-V Opcodes
  localparam OPCODE_R_TYPE  = 7'b0110011;
  localparam OPCODE_I_TYPE  = 7'b0010011;
  localparam OPCODE_LOAD    = 7'b0000011;
  localparam OPCODE_STORE   = 7'b0100011;
  localparam OPCODE_BRANCH  = 7'b1100011;
  localparam OPCODE_JAL     = 7'b1101111;
  localparam OPCODE_JALR    = 7'b1100111;
  localparam OPCODE_LUI     = 7'b0110111;
  localparam OPCODE_AUIPC   = 7'b0010111;

  // R-Type and I-Type funct3
  localparam FUNCT3_ADD_SUB = 3'b000;
  localparam FUNCT3_SLL     = 3'b001;
  localparam FUNCT3_SLT     = 3'b010;
  localparam FUNCT3_SLTU    = 3'b011;
  localparam FUNCT3_XOR     = 3'b100;
  localparam FUNCT3_SRL_SRA = 3'b101;
  localparam FUNCT3_OR      = 3'b110;
  localparam FUNCT3_AND     = 3'b111;
  localparam FUNCT3_ADDI    = 3'b000; 

  // R-Type and I-Type funct7
  localparam FUNCT7_ADD = 7'b0000000;
  localparam FUNCT7_SUB = 7'b0100000;
  localparam FUNCT7_SRL = 7'b0000000;
  localparam FUNCT7_SRA = 7'b0100000;

  // Load Instruction funct3
  localparam FUNCT3_LB  = 3'b000;
  localparam FUNCT3_LH  = 3'b001;
  localparam FUNCT3_LW  = 3'b010;
  localparam FUNCT3_LBU = 3'b100;
  localparam FUNCT3_LHU = 3'b101;

  // Store Instruction funct3
  localparam FUNCT3_SB = 3'b000;
  localparam FUNCT3_SH = 3'b001;
  localparam FUNCT3_SW = 3'b010;

  // Branch Instruction funct3 
  localparam FUNCT3_BEQ  = 3'b000;
  localparam FUNCT3_BNE  = 3'b001;
  localparam FUNCT3_BLT  = 3'b100;
  localparam FUNCT3_BGE  = 3'b101;
  localparam FUNCT3_BLTU = 3'b110;
  localparam FUNCT3_BGEU = 3'b111;

  // Load/Store Types
  localparam MEM_LOAD_B  = 3'b000;
  localparam MEM_LOAD_H  = 3'b001;
  localparam MEM_LOAD_W  = 3'b010;
  localparam MEM_LOAD_BU = 3'b011;
  localparam MEM_LOAD_HU = 3'b100;
  localparam MEM_STORE_B = 3'b101;
  localparam MEM_STORE_H = 3'b110;
  localparam MEM_STORE_W = 3'b111;

  // Branch Types
  localparam BRANCH_BEQ  = 3'b000;
  localparam BRANCH_BNE  = 3'b001;
  localparam BRANCH_BLT  = 3'b010;
  localparam BRANCH_BGE  = 3'b011;
  localparam BRANCH_BLTU = 3'b100;
  localparam BRANCH_BGEU = 3'b101;

  // ALU Opcodes
  localparam ALU_ADD   = 4'b0000;
  localparam ALU_SUB   = 4'b0001;
  localparam ALU_XOR   = 4'b0010;
  localparam ALU_OR    = 4'b0011;
  localparam ALU_AND   = 4'b0100;
  localparam ALU_SLL   = 4'b0101;
  localparam ALU_SRL   = 4'b0110;
  localparam ALU_SRA   = 4'b0111;
  localparam ALU_SLT   = 4'b1000;
  localparam ALU_SLTU  = 4'b1001;
  localparam ALU_LUI   = 4'b1010;
  localparam ALU_INV   = 4'b1111; // Invalid

  //Nop mapped to addi x0, x0, 0
  localparam INSTR_NOP = 32'b00000000000000000000000000010011;
 
  // alu_src_a aliases 
  localparam ALU_SRC_RS1 = 1'b0;
  localparam ALU_SRC_PC  = 1'b1;

  // alu_src_b aliases
  localparam ALU_SRC_RS2 = 1'b0;
  localparam ALU_SRC_IMM = 1'b1;

  // wb_sel aliases
  localparam WB_SEL_ALU = 2'b00;
  localparam WB_SEL_MEM = 2'b01;
  localparam WB_SEL_PC  = 2'b10;

  // Forwarding to EX Stage
  localparam FWD_NO     = 2'b00;
  localparam FWD_FROM_MEM = 2'b01;
  localparam FWD_FROM_WB  = 2'b10;

endpackage
