import rv32i_pkg::*;

module branch_pred_assert
(
  input logic        clk,
  input logic        rst,

  // BHT
  input logic [1:0]  bht_counter,        
  input logic        predict_taken,
  input logic        bht_update_en,
  input logic        actual_taken,       
  input logic [1:0]  bht_counter_next,

  // BTB
  input logic        btb_valid,
  input logic        btb_hit,
  input logic [31:0] btb_target,
  input logic        btb_update_en,

  // resolution
  input logic        branch_resolve_valid,  
  input logic [31:0]  branch_actual_target,
  input logic        mispredict,
  input logic [31:0] redirect_pc
);

  always_comb begin
    if (!rst) begin
      V_BP_COUNTER_KNOWN: assert (!$isunknown(bht_counter));
      V_BP_PREDICT_MATCHES_COUNTER: assert (predict_taken == (bht_counter >= 2'd2));
      V_BP_BTB_HIT_NEEDS_VALID: assert (!btb_hit || btb_valid);
      V_BP_BTB_TARGET_KNOWN: assert (!btb_hit || !$isunknown(btb_target));
      V_BP_BTB_TARGET_ALIGNED: assert (!btb_hit || btb_target[1:0] == 2'b00);

      V_BP_BHT_UPDATE_NEEDS_RESOLVE: assert (!bht_update_en || branch_resolve_valid);
      V_BP_BTB_UPDATE_NEEDS_RESOLVE: assert (!btb_update_en || branch_resolve_valid);

      V_BP_MISPREDICT_NEEDS_RESOLVE: assert (!mispredict || branch_resolve_valid);
    end
  end

  V_BP_COUNTER_NO_OVERSATURATE: assert property (
    @(posedge clk) disable iff (rst)
    (bht_update_en && actual_taken && bht_counter == 2'd3) |-> (bht_counter_next == 2'd3)
  );
  V_BP_COUNTER_NO_UNDERSATURATE: assert property (
    @(posedge clk) disable iff (rst)
    (bht_update_en && !actual_taken && bht_counter == 2'd0) |-> (bht_counter_next == 2'd0)
  );
  V_BP_COUNTER_STEP: assert property (
    @(posedge clk) disable iff (rst)
    bht_update_en |-> (bht_counter_next == bht_counter + (actual_taken ? 1 : -1)) or
                       (bht_counter == 2'd3 && actual_taken) or
                       (bht_counter == 2'd0 && !actual_taken)
  );

  V_BP_REDIRECT_CORRECT: assert property (
    @(posedge clk) disable iff (rst)
    mispredict |-> (redirect_pc == branch_actual_target)
  );

endmodule
