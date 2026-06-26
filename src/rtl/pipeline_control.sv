//============================================================
// File:          pipeline_control.sv
// Author:        Tasos Athanasiadis 
// Date:          11/06/2026
//
// Description:
//   The unit responsible for detecting hazards, stalling the 
//   pipeline, and forwarding data to the previous stages.
//   As well as flushing in case of control flow.
//
// Inputs:
//    rs1_addr_id       : Address of RS1, on Decode Stage  
//    rs2_addr_id       : Address of RS2, on Decode Stage 
//    rs1_addr_ex       : Address of RS1, on Execute Stage 
//    rs2_addr_ex       : Address of RS2, on Execute Stage
//    rd_addr_ex        : Address of RD, on Execute Stage 
//    rd_addr_mem       : Address of RD, on Memory Access Stage
//    rd_addr_wb        : Address of RD, on Write Back Stage
//    branch_en         : Branch enable signal, high if taken
//    reg_write_mem     : Register File write enable, on Memory Stage
//    reg_write_wb      : Register File write enable, on Write Back Stage
//    is_load_ex        : High if instruction currently in EX is a load
//
// Outputs:
//    stall_pc          : Stall the Program Counter  
//    stall_if_id       : Stall the pipeline between stages: IF -> ID 
//    flush_if_id       : Flushes the pipeline from Stage 2 
//    flush_id_ex       : Flushes the pipeline from Stage 3
//    forward_a         : Forward RS1 
//                          0 = No Forwarding 
//                          1 = Forwarding from MEM to EX 
//                          2 = Forwarding from WB to EX
//    forward_b         : Forward RS2
//                          (same rules as forward_a apply)
//
//============================================================

import rv32i_pkg::*;

module pipeline_control
(
  input logic   [4:0]   rs1_addr_id,
  input logic   [4:0]   rs2_addr_id,
  input logic   [4:0]   rs1_addr_ex,
  input logic   [4:0]   rs2_addr_ex,
  input logic   [4:0]   rd_addr_ex,
  input logic   [4:0]   rd_addr_mem,
  input logic   [4:0]   rd_addr_wb,
  input  logic          reg_write_mem,
  input  logic          reg_write_wb,
  input  logic          is_load_ex,
  input  logic          branch_en,


  output logic          stall_pc,
  output logic          stall_if_id,
  output logic          flush_if_id,
  output logic          flush_id_ex,
  output logic  [1:0]   forward_a,
  output logic  [1:0]   forward_b
);

logic mem_hazard_a, wb_hazard_a, mem_hazard_b, wb_hazard_b;

assign mem_hazard_a   = (rs1_addr_ex != 5'd0) && (rs1_addr_ex == rd_addr_mem) && reg_write_mem;   
assign wb_hazard_a    = (rs1_addr_ex != 5'd0) && (rs1_addr_ex == rd_addr_wb) && reg_write_wb;

always_comb begin
  if (mem_hazard_a)       forward_a = FWD_FROM_MEM;
  else if(wb_hazard_a)    forward_a = FWD_FROM_WB;
  else                    forward_a = FWD_NO;
end 

assign mem_hazard_b   = (rs2_addr_ex != 5'd0) && (rs2_addr_ex == rd_addr_mem) && reg_write_mem;
assign wb_hazard_b    = (rs2_addr_ex != 5'd0) && (rs2_addr_ex == rd_addr_wb) && reg_write_wb;

always_comb begin
  if (mem_hazard_b)       forward_b = FWD_FROM_MEM;
  else if(wb_hazard_b)    forward_b = FWD_FROM_WB;
  else                    forward_b = FWD_NO;
end 

logic load_stall;
assign load_stall = is_load_ex && (rd_addr_ex != 5'd0) && ((rs1_addr_id == rd_addr_ex) || (rs2_addr_id == rd_addr_ex));

assign stall_pc     = load_stall;
assign stall_if_id  = load_stall;
assign flush_if_id  = branch_en;
assign flush_id_ex  = branch_en || load_stall;

endmodule
