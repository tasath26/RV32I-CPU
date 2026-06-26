import rv32i_pkg::*;

module mem_assert
(
  input  logic        clk,
  input  logic        rst,
  input  logic        valid,        
  input  logic        mem_read,
  input  logic        mem_write,
  input  logic [31:0] mem_addr,
  input  logic [31:0] mem_wdata,
  input  logic [3:0]  mem_wmask,    
  input  logic [2:0]  funct3,
  input  logic [31:0] mem_rdata,
  input  logic        mem_rvalid    
);

  localparam logic [31:0] MMIO_CONSOLE_ADDR  = 32'h0000_0040;
  localparam logic [31:0] MMIO_HALT_ADDR     = 32'h0000_0050;
  localparam logic [31:0] MMIO_CYCLECNT_ADDR = 32'h0000_0060;

  always_comb begin
    if (!rst && valid && (mem_read || mem_write)) begin
      V_MEM_ADDR_KNOWN: assert (!$isunknown(mem_addr));
      V_MEM_RW_MUTEX:   assert (!(mem_read && mem_write));

      unique case (funct3)
        FUNCT3_LB, FUNCT3_LBU, FUNCT3_SB: ; 
        FUNCT3_LH, FUNCT3_LHU, FUNCT3_SH: V_MEM_ALIGN_HALF: assert (mem_addr[0] == 1'b0);
        FUNCT3_LW, FUNCT3_SW:             V_MEM_ALIGN_WORD: assert (mem_addr[1:0] == 2'b00);
        default: V_MEM_FUNCT3_LEGAL: assert (0);
      endcase
    end

    if (!rst && valid && mem_write) begin
      V_MEM_WDATA_KNOWN: assert (!$isunknown(mem_wdata));
      unique case (funct3)
        FUNCT3_SB: V_MEM_WMASK_BYTE: assert (mem_wmask == (4'b0001 << mem_addr[1:0]));
        FUNCT3_SH: V_MEM_WMASK_HALF: assert (mem_wmask == (mem_addr[1] ? 4'b1100 : 4'b0011));
        FUNCT3_SW: V_MEM_WMASK_WORD: assert (mem_wmask == 4'b1111);
        default: ;
      endcase
    end
  end

  V_MEM_RVALID_FOLLOWS_REQ: assert property (
    @(posedge clk) disable iff (rst)
    mem_rvalid |-> $past(valid && mem_read)
  );

  logic halted;
  always_ff @(posedge clk) begin
    if (rst) halted <= 1'b0;
    else if (valid && mem_write && mem_addr == MMIO_HALT_ADDR) halted <= 1'b1;
  end

  V_MEM_NO_REQ_AFTER_HALT: assert property (
    @(posedge clk) disable iff (rst)
    halted |-> !(mem_read || mem_write)
  );

  logic [31:0] last_cyclecnt;
  logic        have_last_cyclecnt;
  always_ff @(posedge clk) begin
    if (rst) have_last_cyclecnt <= 1'b0;
    else if (valid && mem_read && mem_addr == MMIO_CYCLECNT_ADDR && mem_rvalid) begin
      if (have_last_cyclecnt)
        V_MEM_CYCLECNT_MONOTONIC: assert (mem_rdata >= last_cyclecnt);
      last_cyclecnt      <= mem_rdata;
      have_last_cyclecnt <= 1'b1;
    end
  end

endmodule
