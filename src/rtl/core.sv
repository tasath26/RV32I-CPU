//============================================================
// File:          core.sv
// Author:        Tasos Athanasiadis 
// Date:          11/06/2026
//
// Description:
//    This file is the top module and it 
//    contains the processor's core datapath,
//    and pipeline registers in-between stages.
//============================================================

import rv32i_pkg::*;

module core #(
  parameter HEX_FILE = "simple.hex",
  parameter IMEM_FILE = "placeholder",
  parameter DMEM_FILE = "placeholder"
)(
  input logic clk,
  input logic rst,

  output logic [31:0] d_console_data,
  output logic 	      d_console_valid,
  output logic        d_halt

);

// =========================================
// WIRING  
// =========================================
typedef struct packed {
    logic        reg_write;
    logic        mem_write;
    logic        mem_read;
    logic        alu_src_a;
    logic        alu_src_b;
    logic [1:0]  wb_sel;
    logic        branch;
    logic        jump;
    logic [2:0]  mem_type;
    logic [2:0]  branch_type;
    logic [3:0]  alu_op;
} ctrl_t;

typedef struct packed {
    logic         taken;
    logic [31:0]  target;
} pred_t;

// Pipeline registers 
typedef struct packed {
    logic [31:0]  pc;
    logic [31:0]  instr;
    pred_t        pred;
} if_id_t;

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] imm;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
    ctrl_t       ctrl;
    pred_t       pred;
} id_ex_t;

typedef struct packed {
    logic [31:0] alu_result;
    logic [31:0] store_data;
    logic [31:0] pc;
    logic [4:0]  rd;
    logic        br_taken;
    logic [31:0] br_target;
    ctrl_t       ctrl;
    pred_t       pred;
} ex_mem_t;

typedef struct packed {
    logic [31:0] alu_result;
    logic [31:0] load_data;
    logic [31:0] pc;
    logic [4:0]  rd;
    ctrl_t       ctrl;
} mem_wb_t;

if_id_t  if_id;
id_ex_t  id_ex;
ex_mem_t ex_mem;
mem_wb_t mem_wb;

// IF stage wires 
logic   [31:0]  pc;
logic   [31:0]  pc_next;
logic   [31:0]  instr;

// ID stage wires 
logic   [6:0]   opcode;
logic   [2:0]   funct3;
logic   [6:0]   funct7;
logic   [4:0]   rs1;
logic   [4:0]   rs2;
logic   [4:0]   rd;
logic   [31:0]  imm;
logic   [31:0]  rs1_data;
logic   [31:0]  rs2_data;
ctrl_t          ctrl;

// EX stage wires 
logic   [31:0]  alu_a;
logic   [31:0]  alu_b;
logic   [31:0]  alu_result;
logic           br_taken;
logic   [31:0]  br_target;


// MEM stage wires 
logic   [31:0]  mem_read_data;
logic   [31:0]  mem_write_data;
logic   [3:0]   mem_wen;
logic   [31:0]  load_data;

// WB stage wires 
logic   [31:0]  wb_data;

// Pipeline Control wires
logic           stall_pc;
logic           stall_if_id;
logic           flush_if_id;
logic           flush_id_ex;
logic   [1:0]   forward_a;
logic   [1:0]   forward_b;

// Branch prediction wires
logic   [31:0]  pred_target;
logic           pred_taken;

// Output
assign d_console_data = mem_write_data;
assign d_console_valid = mem_wen && (alu_result == 32'h40);
assign d_halt 	      = mem_wen && (alu_result == 32'h50);

// =========================================
// STAGE 1: INSTRUCTION FETCH 
// =========================================
always_ff @(posedge clk) begin
  if(rst)               pc <= 32'h00000100;
  else if(!stall_pc)    pc <= pc_next;
end

// next pc mux
always_comb begin
  if(id_ex.ctrl.jump)
    pc_next = alu_result;

  // prediction NT, actually T
  else if(id_ex.ctrl.branch && br_taken && !id_ex.pred.taken)
    pc_next = br_target;

  // prediction T, actually NT
  else if(id_ex.ctrl.branch && !br_taken && id_ex.pred.taken)
    pc_next = id_ex.pc + 32'd4;

  else if(pred_taken)
    pc_next = pred_target;

  else
    pc_next = pc + 32'd4;
end


// Instruction Memory instance
imem #(.IMEM_FILE(IMEM_FILE)) imem_inst(
  .addr         (pc),
  .instr        (instr)
);

// IF -> ID Registers
always_ff @(posedge clk) begin
    if (rst || flush_if_id) begin
        if_id.pc          <= 32'h00000100;
        if_id.instr       <= INSTR_NOP;
        if_id.pred.taken  <= 1'b0;
        if_id.pred.target <= 32'h00000100;
    end else if (!stall_if_id) begin
        if_id.pc          <= pc;
        if_id.instr       <= instr;
        if_id.pred.taken  <= pred_taken;
        if_id.pred.target <= pred_target;
    end
end

// =========================================
// STAGE 2: INSTRUCTION DECODE 
// =========================================

// Decode Unit instance
decode decode_inst (
    .instr               (if_id.instr),
    .opcode              (opcode),
    .funct3              (funct3),
    .funct7              (funct7),
    .rs1                 (rs1),
    .rs2                 (rs2),
    .rd                  (rd)
);

// Control Unit instance
control control_inst (
    .opcode              (opcode),
    .funct3              (funct3),
    .funct7              (funct7),
    .reg_write           (ctrl.reg_write),
    .mem_write           (ctrl.mem_write),
    .mem_read            (ctrl.mem_read),
    .alu_src_a           (ctrl.alu_src_a),
    .alu_src_b           (ctrl.alu_src_b),
    .wb_sel              (ctrl.wb_sel),
    .branch              (ctrl.branch),
    .jump                (ctrl.jump),
    .mem_type            (ctrl.mem_type),
    .branch_type         (ctrl.branch_type),
    .alu_op              (ctrl.alu_op)
);

// Register File instance
register_file rf_inst (
    .clk_i               (clk),
    .write_enable        (mem_wb.ctrl.reg_write),
    .reg_read_address_r1 (rs1),
    .reg_read_address_r2 (rs2),
    .reg_write_address   (mem_wb.rd),
    .reg_write_data      (wb_data),
    .reg_read_data_r1_o  (rs1_data),
    .reg_read_data_r2_o  (rs2_data)
);


// Immediate generator unit instance
immgen immgen_inst (
    .instr               (if_id.instr),
    .imm                 (imm)
);


// ID -> EX Registers
always_ff @(posedge clk) begin
    if (rst || flush_id_ex) begin
        id_ex.pc       <= 32'h00000100;
        id_ex.rs1_data <= 32'b0;
        id_ex.rs2_data <= 32'b0;
        id_ex.imm      <= 32'b0;
        id_ex.rs1      <= 5'b0;
        id_ex.rs2      <= 5'b0;
        id_ex.rd       <= 5'b0;
        id_ex.ctrl     <= '0;
        id_ex.pred     <= '0;
    end else if (!stall_if_id) begin
        id_ex.pc       <= if_id.pc;
        id_ex.rs1_data <= rs1_data;
        id_ex.rs2_data <= rs2_data;
        id_ex.imm      <= imm;
        id_ex.rs1      <= rs1;
        id_ex.rs2      <= rs2;
        id_ex.rd       <= rd;
        id_ex.ctrl     <= ctrl;
        id_ex.pred     <= if_id.pred;
    end
end


// =========================================
// STAGE 3: EXECUTE 
// =========================================

logic [31:0] fwd_a;
logic [31:0] fwd_b;

always_comb begin
  case (forward_a)
    FWD_FROM_MEM: fwd_a = ex_mem.alu_result;
    FWD_FROM_WB:  fwd_a = wb_data;
    default:      fwd_a = id_ex.rs1_data;
  endcase

  case (forward_b)
    FWD_FROM_MEM: fwd_b = ex_mem.alu_result;
    FWD_FROM_WB:  fwd_b = wb_data;
    default:      fwd_b = id_ex.rs2_data;
  endcase
end

assign alu_a = id_ex.ctrl.alu_src_a ? id_ex.pc  : fwd_a;
assign alu_b = id_ex.ctrl.alu_src_b ? id_ex.imm : fwd_b;

// Arithmetic Logic Unit instance
alu alu_inst(
  .alu_op              (id_ex.ctrl.alu_op), 
  .alu_port_a          (alu_a), 
  .alu_port_b          (alu_b), 
  .alu_result          (alu_result)
);

// Branch Unit instance
branch_unit bu_inst(
  .br_control_signal    (id_ex.ctrl.branch),
  .branch_op            (id_ex.ctrl.branch_type),
  .br_port_a            (fwd_a),
  .br_port_b            (fwd_b), 
  .pc                   (id_ex.pc),
  .imm                  (id_ex.imm),
  .br_taken             (br_taken),
  .br_target            (br_target)
);

// EX -> MEM Registers 
always_ff @(posedge clk) begin
    if (rst) begin
        ex_mem.alu_result    <= 32'b0;
        ex_mem.store_data      <= 32'b0;
        ex_mem.pc            <= 32'h00000100;
        ex_mem.rd            <= 5'b0;
        ex_mem.br_taken      <= 1'b0;
        ex_mem.br_target     <= 32'b0;
        ex_mem.ctrl          <= '0;
        ex_mem.pred          <= '0;
    end else begin
        ex_mem.alu_result    <= alu_result;
        ex_mem.store_data    <= fwd_b;
        ex_mem.pc            <= id_ex.pc;
        ex_mem.rd            <= id_ex.rd;
        ex_mem.br_taken      <= br_taken;
        ex_mem.br_target     <= br_target;
        ex_mem.ctrl          <= id_ex.ctrl;
        ex_mem.pred          <= id_ex.pred;
    end
end


// =========================================
// STAGE 4: MEMORY ACCESS 
// =========================================
load_store_unit lsu_inst(
  .mem_type             (ex_mem.ctrl.mem_type),
  .store_data           (ex_mem.store_data),
  .mem_addr             (ex_mem.alu_result),
  .mem_wen              (mem_wen),
  .mem_write_data       (mem_write_data),
  .mem_read_data        (mem_read_data),
  .load_data            (load_data)
);

dmem #(.DMEM_FILE(DMEM_FILE)) dmem_inst(
  .clk                  (clk),
  .mem_write            (ex_mem.ctrl.mem_write),
  .mem_read             (ex_mem.ctrl.mem_read),
  .wen                  (mem_wen),
  .addr                 (ex_mem.alu_result),
  .write_data           (mem_write_data),
  .read_data            (mem_read_data)
);

always_ff @(posedge clk) begin
    if (rst) begin
        mem_wb.alu_result <= 32'b0;
        mem_wb.load_data  <= 32'b0;
        mem_wb.pc         <= 32'h00000100;
        mem_wb.rd         <= 5'b0;
        mem_wb.ctrl       <= '0;
    end else begin
        mem_wb.alu_result <= ex_mem.alu_result;
        mem_wb.load_data  <= load_data;
        mem_wb.pc         <= ex_mem.pc;
        mem_wb.rd         <= ex_mem.rd;
        mem_wb.ctrl       <= ex_mem.ctrl;
    end
end

// =========================================
// STAGE 5: WRITE BACK 
// =========================================

always_comb begin
  case(mem_wb.ctrl.wb_sel)
    WB_SEL_ALU:     wb_data = mem_wb.alu_result; 
    WB_SEL_MEM:     wb_data = mem_wb.load_data;
    WB_SEL_PC :     wb_data = mem_wb.pc + 32'd4;
    default:        wb_data = 32'b0;
  endcase
end


// =========================================
// PIPELINE CONTROL 
// =========================================
pipeline_control pipeline_inst(
   .rs1_addr_id            (rs1), 
   .rs2_addr_id            (rs2),
   .rs1_addr_ex            (id_ex.rs1),
   .rs2_addr_ex            (id_ex.rs2),
   .rd_addr_ex             (id_ex.rd),
   .rd_addr_mem            (ex_mem.rd),
   .rd_addr_wb             (mem_wb.rd),
   .reg_write_mem          (ex_mem.ctrl.reg_write),
   .reg_write_wb           (mem_wb.ctrl.reg_write),
   .is_load_ex             (id_ex.ctrl.mem_read),
   .branch_en              (id_ex.ctrl.jump || (id_ex.ctrl.branch && (br_taken != id_ex.pred.taken))),
   .stall_pc               (stall_pc),
   .stall_if_id            (stall_if_id),
   .flush_if_id            (flush_if_id),
   .flush_id_ex            (flush_id_ex),
   .forward_a              (forward_a),
   .forward_b              (forward_b)
);


// =========================================
// BRANCH PREDICTION
// =========================================
branch_pred pred_inst( 
  .clk               (clk),
  .rst               (rst),
  .pc                (pc), 
  .target_pc         (pred_target), 
  .prediction        (pred_taken),
  .update_en         (id_ex.ctrl.branch),
  .update_pc         (id_ex.pc),
  .update_target     (br_target),
  .actual_taken      (br_taken)
);

endmodule
