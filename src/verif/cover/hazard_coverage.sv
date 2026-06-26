module hazard_coverage
(
  input logic        clk,
  input logic        rst,
  input logic        valid_ex,
  input logic [4:0]  rs1_ex, rs2_ex, rd_mem, rd_wb,
  input logic [1:0]  forward_a_sel, forward_b_sel,  
  input logic        load_use_stall,
  input logic        is_load_mem
);

  covergroup cg_hazard @(posedge clk iff (!rst && valid_ex));
    cp_fwd_a: coverpoint forward_a_sel {
      bins none = {2'b00};
      bins mem  = {2'b01};
      bins wb   = {2'b10};
    }
    cp_fwd_b: coverpoint forward_b_sel {
      bins none = {2'b00};
      bins mem  = {2'b01};
      bins wb   = {2'b10};
    }
    cp_rs1_x0: coverpoint (rs1_ex == 5'd0);
    cp_rs2_x0: coverpoint (rs2_ex == 5'd0);
    cp_load_use: coverpoint load_use_stall;
    cp_is_load: coverpoint is_load_mem;

    cx_dual_hazard: cross cp_fwd_a, cp_fwd_b {
      ignore_bins either_none = binsof(cp_fwd_a) intersect {2'b00} || binsof(cp_fwd_b) intersect {2'b00};
    }

    cx_x0_no_fwd: cross cp_rs1_x0, cp_fwd_a;
  endgroup

  cg_hazard cg_hazard_inst = new();

endmodule
