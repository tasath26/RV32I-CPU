`timescale 1ns / 1ps

module tb;

    logic clk;
    logic rst;

    // Outputs from the Core
    logic [31:0] d_console_data;
    logic        d_console_valid;
    logic        d_halt;

    always begin
        #5 clk = ~clk;
    end

    core #(
        .HEX_FILE   ("simple.hex"),
        .IMEM_FILE  ("placeholder"), // Replace with your actual firmware mem file if available
        .DMEM_FILE  ("placeholder")
    ) dut (
        .clk             (clk),
        .rst             (rst),
        .d_console_data  (d_console_data),
        .d_console_valid (d_console_valid),
        .d_halt          (d_halt)
    );

    initial begin
        clk = 0;
        rst = 1;

        repeat (5) @(posedge clk);
        
        @(negedge clk);
        rst = 0;
        $display("[TB INFO] Reset deasserted. Core is running...");

        fork
            begin : timeout_watchdog
                #50000; 
                $display("[TB ERROR] Simulation timed out without reaching HALT!");
                $finish;
            end
            
            begin : monitor_halt
                forever begin
                    @(posedge clk);
                    if (d_console_valid) begin
                        $display("[CONSOLE OUT] Character received: %h (%c)", d_console_data, d_console_data);
                    end
                    
                    if (d_halt) begin
                        $display("[TB SUCCESS] Core asserted d_halt flag. Program complete!");
                        disable timeout_watchdog;
                        $finish;
                    end
                end
            end
        join
    end

    initial begin
        $dumpfile("sim_output.vcd");
        $dumpvars(0, tb_core);
    end

endmodule
