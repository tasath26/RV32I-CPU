//============================================================
// File:          core.sv
// Author:        Tasos Athanasiadis 
// Date:          7/06/2026
//
// Description:
//    This file is the top module and it 
//    contains the processor's core datapath.
//============================================================


module core #(
  parameter HEX_FILE = "simple.hex"
)(
  input logic clk,
  input logic rst
);

// =============== WIRING =================

logic   [31:0]  pc;
logic   [31:0]  pc_next;
logic   [31:0]  instr;

logic   [6:0]   opcode;
logic   [2:0]   funct3;
logic   [6:0]   funct7;
logic   [4:0]   rs1;
logic   [4:0]   rs2;
logic   [4:0]   rd;

logic           reg_write; 
logic           mem_write; 
logic           mem_read;
logic           alu_src_a;
logic           alu_src_b;
logic   [1:0]   wb_sel;
logic           branch; 
logic           jump;
logic   [2:0]   mem_type;
logic   [2:0]   branch_type;
logic   [3:0]   alu_op;

logic   [31:0]  imm;
logic   [31:0]  rs1_data;
logic   [31:0]  rs2_data;
logic   [31:0]  alu_a;
logic   [31:0]  alu_b;
logic   [31:0]  alu_result;
logic   [31:0]  mem_read_data;
logic   [31:0]  mem_write_data;
logic   [31:0]  load_data;
logic   [31:0]  wb_data;
logic   [3:0]   mem_wen;

logic           br_taken;
logic   [31:0]  br_target;


// ================= PC ===================
always_ff @(posedge clk) begin 
  if(rst) pc <= 32'b0;
  else    pc <= pc_next;
end

always_comb begin 
  if(jump)          pc_next = alu_result;
  else if(br_taken) pc_next = br_target;
  else              pc_next = pc + 32'd4;
end


// ================ ALU ===================

assign alu_a = alu_src_a ? pc   : rs1_data;
assign alu_b = alu_src_b ? imm  : rs2_data;


// ================= WB ===================
always_comb begin
  case(wb_sel)
    2'b00:    wb_data = alu_result; 
    2'b01:    wb_data = load_data;
    2'b10:    wb_data = pc + 32'd4;
    default:  wb_data = 32'b0;
  endcase
end


// =========== INSTANTIATIONS =============
imem #(.HEX_FILE(HEX_FILE)) imem_inst(
  .addr         (pc),
  .instr        (instr)
);

decode decode_inst(  
  .instr        (instr),
  .opcode       (opcode),
  .funct3       (funct3),
  .funct7       (funct7),
  .rs1          (rs1),
  .rs2          (rs2),
  .rd           (rd)
);

control control_inst(
  .opcode       (opcode),
  .funct3       (funct3),
  .funct7       (funct7),
  .reg_write    (reg_write), 
  .mem_write    (mem_write),
  .mem_read     (mem_read),
  .alu_src_a    (alu_src_a),
  .alu_src_b    (alu_src_b), 
  .wb_sel       (wb_sel),
  .branch       (branch),
  .jump         (jump),
  .mem_type     (mem_type),
  .branch_type  (branch_type),
  .alu_op       (alu_op)
);

immgen immgen_inst(
  .instr        (instr),
  .imm          (imm)
);

register_file rf_inst(
  .clk_i                (clk),
  .write_enable         (reg_write),
  .reg_read_address_r1  (rs1),
  .reg_read_address_r2  (rs2),
  .reg_write_address    (rd),
  .reg_write_data       (wb_data),
  .reg_read_data_r1_o   (rs1_data),
  .reg_read_data_r2_o   (rs2_data) 
);

alu alu_inst(
  .alu_op       (alu_op), 
  .alu_port_a   (alu_a), 
  .alu_port_b   (alu_b), 
  .alu_result   (alu_result)
);

branch_unit bu_inst(
  .br_control_signal    (branch),
  .branch_op            (branch_type),
  .br_port_a            (rs1_data),
  .br_port_b            (rs2_data), 
  .pc                   (pc),
  .imm                  (imm),
  .br_taken             (br_taken),
  .br_target            (br_target)
);

load_store_unit lsu_inst(
  .mem_type             (mem_type),
  .store_data           (rs2_data),
  .mem_addr             (alu_result),
  .mem_wen              (mem_wen),
  .mem_write_data       (mem_write_data),
  .mem_read_data        (mem_read_data),
  .load_data            (load_data)
);

dmem dmem_inst(
  .clk                  (clk),
  .mem_write            (mem_write),
  .mem_read             (mem_read),
  .wen                  (mem_wen),
  .addr                 (alu_result),
  .write_data           (mem_write_data),
  .read_data            (mem_read_data)
);

endmodule
