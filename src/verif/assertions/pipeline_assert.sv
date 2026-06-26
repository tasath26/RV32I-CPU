import rv32i_pkg::*;

module pipeline_assert
(
  input logic        clk,
  input logic        rst,

  input logic        valid_if, valid_id, valid_ex, valid_mem, valid_wb,
  input logic        stall_if, stall_id,
  input logic        flush_id, flush_ex,

  input logic [4:0]  rs1_ex, rs2_ex, rd_ex, rd_mem, rd_wb,
  input logic        regwrite_ex, regwrite_mem, regwrite_wb,
  input logic        memwrite_ex,
  input logic [1:0]  forward_a_sel, forward_b_sel,  

  input logic        is_load_mem,                   
  input logic        load_use_stall                 
);

  localparam logic [1:0] FWD_NONE = 2'b00;
  localparam logic [1:0] FWD_MEM  = 2'b01;
  localparam logic [1:0] FWD_WB   = 2'b10;

  always_comb begin
    if (!rst) begin
      V_PIPE_VALID_KNOWN: assert (!$isunknown({valid_if, valid_id, valid_ex, valid_mem, valid_wb}));

      V_PIPE_STALL_FLUSH_MUTEX_ID: assert (!(stall_id && flush_id));

      V_PIPE_BUBBLE_EX_INERT: assert (valid_ex || (!regwrite_ex && !memwrite_ex));

      if (rs1_ex != 5'd0 && rs1_ex == rd_mem && regwrite_mem)
        V_PIPE_FWD_A_MEM: assert (forward_a_sel == FWD_MEM);
      if (rs2_ex != 5'd0 && rs2_ex == rd_mem && regwrite_mem)
        V_PIPE_FWD_B_MEM: assert (forward_b_sel == FWD_MEM);

      if (rs1_ex != 5'd0 && rs1_ex == rd_wb && regwrite_wb && !(rs1_ex == rd_mem && regwrite_mem))
        V_PIPE_FWD_A_WB: assert (forward_a_sel == FWD_WB);
      if (rs2_ex != 5'd0 && rs2_ex == rd_wb && regwrite_wb && !(rs2_ex == rd_mem && regwrite_mem))
        V_PIPE_FWD_B_WB: assert (forward_b_sel == FWD_WB);

      // never forward for x0
      V_PIPE_NO_FWD_X0_A: assert (!(rs1_ex == 5'd0 && forward_a_sel != FWD_NONE));
      V_PIPE_NO_FWD_X0_B: assert (!(rs2_ex == 5'd0 && forward_b_sel != FWD_NONE));
    end
  end

  V_PIPE_LOAD_USE_STALL: assert property (
    @(posedge clk) disable iff (rst)
    (is_load_mem && valid_id && ((rs1_ex == rd_mem) || (rs2_ex == rd_mem)) && rd_mem != 5'd0)
      |-> load_use_stall
  );

  V_PIPE_LOAD_USE_STALL_ONE_CYCLE: assert property (
    @(posedge clk) disable iff (rst)
    load_use_stall |=> !load_use_stall
  );

endmodule
