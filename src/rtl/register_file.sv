//============================================================
// File:          register_file.sv
// Author:        Tasos Athanasiadis 
// Date:          6/06/2026
//
// Description:
//    The core's register file for storing data 
//
// Inputs:
//    clk_i                 : Clock Signal
//    write_enable          : The write enable signal for the RF 
//    reg_read_address_r1   : Address of r1 (0 - 31)
//    reg_read_address_r2   : Address of r2 (0 - 31)
//    reg_write_address     : Address of register to write back
//    reg_write_data        : Data of register to write back
//
// Outputs:
//    reg_read_data_r1_o    : The data of register R1
//    reg_read_data_r2_o    : The data of register R2
//============================================================


import rv32i_pkg::*;

module register_file 
(  
  input logic         clk_i,
  
  input logic         write_enable,
  input logic  [4:0]  reg_read_address_r1,
  input logic  [4:0]  reg_read_address_r2,
  input logic  [4:0]  reg_write_address,
  input logic  [31:0] reg_write_data,

  output logic [31:0] reg_read_data_r1_o,
  output logic [31:0] reg_read_data_r2_o

);

// All RISC-V General purpose registers 
logic [31:0] register [31:0];   

always_comb begin
  reg_read_data_r1_o = (reg_read_address_r1 == '0) ? '0 : register[reg_read_address_r1];
  reg_read_data_r2_o = (reg_read_address_r2 == '0) ? '0 : register[reg_read_address_r2];  
end
 
// Write Back to RF
always_ff @(negedge clk_i) begin 
  if (write_enable == 1 && reg_write_address != 0) begin
    register[reg_write_address] <= reg_write_data; 
  end 
end

endmodule
