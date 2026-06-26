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

module dmem #(
    parameter DMEM_FILE = "simple.hex"
)(
    input  logic        clk,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic  [3:0] wen,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    localparam DMEM_BASE = 32'h00008000;
    
    logic [31:0] mem [0:255]; 

    logic [31:0] byte_offset;
    assign byte_offset = addr - DMEM_BASE;

    logic [11:0] word_addr; 
    assign word_addr = byte_offset[13:2];

    // For coremark 
    logic [31:0] hw_cycle_counter;
    initial hw_cycle_counter = 32'b0;   
 
    always @(posedge clk) begin
		hw_cycle_counter <= hw_cycle_counter + 1;
    end


    always @(posedge clk) begin
      if (mem_write) begin
        for (int i = 0; i < 4; i++) begin
          if (wen[i]) begin
            mem[word_addr][8*i +: 8] <= write_data[8*i +: 8];
          end
        end
      end
    end

  always_comb begin 
	  read_data = 32'b0;
	  if(mem_read) begin
	    if(addr == 32'h00000060) read_data = hw_cycle_counter;
 	    else	read_data = mem[word_addr];
	  end
  end


  initial begin
    $readmemh(DMEM_FILE, mem);
  end

endmodule
