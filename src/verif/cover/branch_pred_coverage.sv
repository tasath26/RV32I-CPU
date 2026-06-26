module branch_pred_coverage
(
  input logic        clk,
  input logic        rst,
  input logic        branch_resolve_valid,
  input logic [1:0]  bht_counter,
  input logic        predict_taken,
  input logic        actual_taken,
  input logic        btb_valid,
  input logic        btb_hit,
  input logic        mispredict
);

  covergroup cg_branch_pred @(posedge clk iff (!rst && branch_resolve_valid));
    cp_counter: coverpoint bht_counter {
      bins strong_nt = {2'd0};
      bins weak_nt   = {2'd1};
      bins weak_t    = {2'd2};
      bins strong_t  = {2'd3};
    }

    cp_outcome: coverpoint {predict_taken, actual_taken} {
      bins correct_taken    = {2'b11};
      bins correct_nottaken = {2'b00};
      bins mispred_taken    = {2'b01}; // predicted NT, actually taken
      bins mispred_nottaken = {2'b10}; // predicted T, actually not taken
    }
    cp_mispredict: coverpoint mispredict;

    cx_counter_transition: cross cp_counter, cp_outcome;
  endgroup

  cg_branch_pred cg_branch_pred_inst = new();

endmodule
