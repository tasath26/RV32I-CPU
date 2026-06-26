//============================================================
// File:          load_store_unit.sv
// Author:        Tasos Athanasiadis 
// Date:          10/06/2026
//
// Description:
//   The unit responsible for performing memory operations  
//   such as Loads and Stores.
//
// Inputs:
//    mem_type          : The specific Load/Store operation to 
//                         perform based on opcode.
//    mem_addr          : The memory address to perform the 
//                         load/store operation on.
//    store_data        : Store data coming from RS2
//    mem_read_data     : Load data coming from DMEM
//
// Outputs:
//    mem_w_en          : The write enable mask for DMEM
//    mem_write_data    : Store data to be written to DMEM 
//    load_data         : Load data to be written to register file
//============================================================

import rv32i_pkg::*;

module load_store_unit 
(
  input logic [2:0]   mem_type,
  input logic [31:0]  mem_addr, 

  // Store 
  output logic [3:0]  mem_wen,
  input logic [31:0]  store_data,      
  output logic [31:0] mem_write_data,  

  // Load
  input logic [31:0]  mem_read_data,   
  output logic [31:0] load_data       
);

  always_comb begin 
    load_data = 32'b0;
    
    case (mem_type)
      MEM_LOAD_B: begin
        case(mem_addr[1:0])
          2'b00: load_data = {{24{mem_read_data[7]}},  mem_read_data[7:0]};
          2'b01: load_data = {{24{mem_read_data[15]}}, mem_read_data[15:8]};
          2'b10: load_data = {{24{mem_read_data[23]}}, mem_read_data[23:16]};
          2'b11: load_data = {{24{mem_read_data[31]}}, mem_read_data[31:24]};
        endcase
      end  
      
      MEM_LOAD_H: begin
        case (mem_addr[1])
          1'b0: load_data = {{16{mem_read_data[15]}}, mem_read_data[15:0]};
          1'b1: load_data = {{16{mem_read_data[31]}}, mem_read_data[31:16]};
        endcase
      end  
      
      MEM_LOAD_BU: begin
        case(mem_addr[1:0])
          2'b00: load_data = {24'b0, mem_read_data[7:0]};
          2'b01: load_data = {24'b0, mem_read_data[15:8]};
          2'b10: load_data = {24'b0, mem_read_data[23:16]};
          2'b11: load_data = {24'b0, mem_read_data[31:24]};
        endcase
      end

      MEM_LOAD_HU: begin
        case (mem_addr[1])
          1'b0: load_data = {16'b0, mem_read_data[15:0]};
          1'b1: load_data = {16'b0, mem_read_data[31:16]};
        endcase
      end
      
      MEM_LOAD_W: begin
        load_data = mem_read_data;
      end

      default: load_data = 32'b0;
    endcase
  end

  always_comb begin 
    mem_write_data = 32'b0;
    mem_wen        = 4'b0000;

    case (mem_type)
      MEM_STORE_B: begin
        mem_write_data = {4{store_data[7:0]}};
        case (mem_addr[1:0])
          2'b00: mem_wen = 4'b0001; 
          2'b01: mem_wen = 4'b0010;
          2'b10: mem_wen = 4'b0100; 
          2'b11: mem_wen = 4'b1000;
        endcase
      end

      MEM_STORE_H: begin
        mem_write_data = {2{store_data[15:0]}};
        case (mem_addr[1])
          1'b0: mem_wen = 4'b0011;
          1'b1: mem_wen = 4'b1100; 
        endcase
      end

      MEM_STORE_W: begin
        mem_write_data = store_data;
        mem_wen        = 4'b1111;
      end
      
      default: begin
        mem_write_data = 32'b0;
        mem_wen        = 4'b0000;
      end
    endcase
  end

endmodule
