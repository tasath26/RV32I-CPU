import rv32i_pkg::*;

module alu_assert (
    input logic [3:0]  alu_op,
    input logic [31:0] alu_port_a,
    input logic [31:0] alu_port_b,
    input logic [31:0] alu_result
);

always_comb begin
  case (alu_op)
    ALU_ADD:  V_ALU_ADD_OK:     assert (alu_result == alu_port_a + alu_port_b);
    ALU_SUB:  V_ALU_SUB_OK:     assert (alu_result == alu_port_a - alu_port_b);
    ALU_AND:  V_ALU_AND_OK:     assert (alu_result == alu_port_a & alu_port_b);
    ALU_OR:   V_ALU_OR_OK:      assert (alu_result == alu_port_a | alu_port_b);
    ALU_XOR:  V_ALU_XOR_OK:     assert (alu_result == alu_port_a ^ alu_port_b);
    ALU_SLL:  V_ALU_SLL_OK:     assert (alu_result == alu_port_a << alu_port_b[4:0]);
    ALU_SRL:  V_ALU_SRL_OK:     assert (alu_result == alu_port_a >> alu_port_b[4:0]);
    ALU_SRA:  V_ALU_SRA_OK:     assert (alu_result == $signed(alu_port_a) >>> alu_port_b[4:0]);
    ALU_SLT:  V_ALU_SLT_OK:     assert (alu_result == (($signed(alu_port_a) < $signed(alu_port_b)) ? 32'b1 : 32'b0));
    ALU_SLTU: V_ALU_SLTU_OK:    assert (alu_result == ((alu_port_a < alu_port_b) ? 32'b1 : 32'b0));
    ALU_LUI:  V_ALU_LUI_OK:     assert (alu_result == alu_port_b);
    default:  V_ALU_DEFAULT_OK: assert (alu_result == 32'b0);
  endcase
end


endmodule
