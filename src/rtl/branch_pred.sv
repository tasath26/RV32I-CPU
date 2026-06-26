//============================================================
// File:          branch_pred.sv
// Author:        Tasos Athanasiadis 
// Date:          12/06/2026
//
// Description:
//    This file implements everything needed for branch prediction.
//    The Global (2-bit saturated) Counter for determining whether 
//    to predict branch taken or not taken.
//    As well as the Branch Target Buffer to tell us where to 
//    jump to if we predict a branch to be taken
//
//
//============================================================

import rv32i_pkg::*;

module branch_pred(
  input   logic           clk,
  input   logic           rst,
  
  // IF stage 
  input   logic   [31:0]  pc,
  output  logic   [31:0]  target_pc,
  output  logic           prediction,

  // EX stage
  input   logic           update_en,
  input   logic   [31:0]  update_pc,
  input   logic   [31:0]  update_target,
  input   logic           actual_taken
);

// Global 2-bit Counter
logic [1:0] counter;

localparam BR_STRONGLY_NT = 2'b00;
localparam BR_WEAKLY_NT   = 2'b01;
localparam BR_WEAKLY_T    = 2'b10;
localparam BR_STRONGLY_T  = 2'b11; 

 
// Branch Target Buffer
localparam BTB_ENTRIES      = 16;
localparam BTB_INDEX_WIDTH  = 4;   
localparam BTB_TAG_WIDTH    = 32 - BTB_INDEX_WIDTH - 2; 

logic                     btb_valid   [0:BTB_ENTRIES-1];
logic [BTB_TAG_WIDTH-1:0] btb_tags    [0:BTB_ENTRIES-1];
logic              [31:0] btb_target  [0:BTB_ENTRIES-1];
 
logic   [BTB_INDEX_WIDTH-1:0]   read_index;
logic   [BTB_INDEX_WIDTH-1:0]   write_index;
logic     [BTB_TAG_WIDTH-1:0]   read_tag;
logic     [BTB_TAG_WIDTH-1:0]   write_tag;

assign  read_index  = pc[BTB_INDEX_WIDTH+1:2];    // First 8 bits
assign  read_tag    = pc[31:BTB_INDEX_WIDTH+2];   // Middle 22 bits
assign  write_index = update_pc[BTB_INDEX_WIDTH+1:2];
assign  write_tag   = update_pc[31:BTB_INDEX_WIDTH+2];

always_comb begin 
  if (btb_valid[read_index] && (btb_tags[read_index] == read_tag) && (counter[1] === 1'b1)) begin
    prediction = 1'b1;
    target_pc  = btb_target[read_index];
  end else begin
    prediction = 1'b0;
    target_pc  = 32'b0;
  end
end

// Update Counter and BTB
always @(posedge clk) begin
  if(rst)  counter <= BR_STRONGLY_NT;
  else if (update_en) begin
    case (counter)
      BR_STRONGLY_NT: counter <=  actual_taken  ? BR_WEAKLY_NT  : BR_STRONGLY_NT;
      BR_WEAKLY_NT:   counter <=  actual_taken  ? BR_WEAKLY_T   : BR_STRONGLY_NT;
      BR_WEAKLY_T:    counter <=  actual_taken  ? BR_STRONGLY_T : BR_WEAKLY_NT;
      BR_STRONGLY_T:  counter <=  actual_taken  ? BR_STRONGLY_T : BR_WEAKLY_T;
    endcase
  
    btb_valid[write_index]    <= 1'b1;
    btb_tags[write_index]     <= write_tag;
    btb_target[write_index]   <= update_target;

  end
end

initial begin
  for (int i = 0; i < BTB_ENTRIES; i++) begin
    btb_valid[i]     = 1'b0;
    btb_tags[i]      = '0;
    btb_target[i]    = 32'b0;
  end
end

endmodule
