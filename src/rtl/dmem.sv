//============================================================
// File:          dmem.sv
// Author:        Tasos Athanasiadis 
// Date:          7/06/2026
//
// Description:
//    The Data memory of the CPU core. 
//    The Data memory is 4KB
//
// Inputs:
//    clk         : clock signal 
//    mem_write   : write enable signal
//    mem_read    : read enable signal
//    addr        : memory address 
//    write_data  : Data to write onto memory 
//
// Outputs:
//    read_data   : Data read from memory
//============================================================

import rv32i_pkg::*;

module dmem (
    input  logic        clk,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic  [3:0] wen,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);
    logic [7:0] mem [0:1023]; // 4KB

always_comb begin
  read_data = 32'b0;
  if (mem_read)
    read_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
end

always_ff @(posedge clk) begin
  if (mem_write) begin
    if (wen[0]) mem[addr]   <= write_data[7:0];
    if (wen[1]) mem[addr+1] <= write_data[15:8];
    if (wen[2]) mem[addr+2] <= write_data[23:16];
    if (wen[3]) mem[addr+3] <= write_data[31:24];
  end
end

endmodule
