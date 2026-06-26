`timescale 1ns/1ps

`ifndef IMEM_FILE
    `define IMEM_FILE "add.imem.dat"
`endif
`ifndef DMEM_FILE
    `define DMEM_FILE "add.dmem.dat"
`endif
`ifndef TEST_NAME
    `define TEST_NAME "unknown"
`endif
`ifndef SIM_CYCLES
    `define SIM_CYCLES 100000
`endif

module tb;
    logic clk, rst;
    int cycle_count;

    core #(
        .IMEM_FILE (`IMEM_FILE),
        .DMEM_FILE (`DMEM_FILE)
    ) dut (
        .clk (clk),
        .rst (rst)
    );

    // clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // reset
    initial begin
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;
    end

    // timeout
    initial begin
        repeat(`SIM_CYCLES) @(posedge clk);
        $display("TIMEOUT: %s", `TEST_NAME);
        $finish;
    end

    always @(posedge clk) cycle_count++;
    
initial begin
        $dumpfile("src/sim/tb.vcd");
        $dumpvars(0, tb);
    end

    always @(posedge clk) begin 
	if(dut.ex_mem.pc >= 32'h00000100 &&
	  dut.ex_mem.pc <= 32'h000001ff) begin
	    $display("[Cycle %0d] pc=0x%08x instr=0x%08x rd=%0d wb=0x%08x",
                   cycle_count,
			dut.ex_mem.pc,
			dut.if_id.instr,
			dut.mem_wb.rd,
			dut.wb_data);
	end
    end


    // UART/console capture: putchar writes one byte to 0x40
string console_buf = "";
always @(posedge clk) begin
    if (dut.ex_mem.ctrl.mem_write && 
        dut.ex_mem.alu_result == 32'h00000040) begin
        
        byte c = dut.ex_mem.store_data[7:0];
        
        if (c == 8'h0A) begin  // newline -> flush line
            $display("[UART] %s", console_buf);
            console_buf = "";
        end else begin
            console_buf = {console_buf, c};
        end
    end
end

// flush any trailing partial line at $finish
final begin
    if (console_buf.len() > 0)
        $display("[UART] %s", console_buf);
end

    // watch halt address 0x50
    always @(posedge clk) begin
    if (dut.ex_mem.ctrl.mem_write && 
        dut.ex_mem.alu_result == 32'h00000050) begin        
            
            if (dut.ex_mem.store_data == 32'h0)
                $display("PASS: %s", `TEST_NAME);
            else
                $display("FAIL: %s — test case %0d", 
                    `TEST_NAME, dut.ex_mem.store_data >> 1);
            $finish;
        end
    end

endmodule
