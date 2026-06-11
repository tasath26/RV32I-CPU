`timescale 1ns/1ps

`ifndef HEX_FILE
    `define HEX_FILE "src/tb/testfiles/simple.hex"
`endif

module tb;
    logic clk, rst;

    // instantiate your top level
    core #(.HEX_FILE(`HEX_FILE)) dut (
        .clk (clk),
        .rst (rst)
    );

    // clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period = 100MHz

    // reset then run
    initial begin
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        // run for enough cycles
        repeat(20) @(posedge clk);
        $finish;
    end

    // dump waveforms
    initial begin
        $dumpfile("src/sim/tb.vcd");
        $dumpvars(0, tb);
    end

    // monitor register file each cycle
    always @(posedge clk) begin
        $display("cycle=%0t pc=%h x1=%d x2=%d x3=%d x4=%d x5=%d x6=%d, x7=%d, x8=%d, x9=%d, x10=%d, x11=%d  , x12=%d, x13=%d, x14=%d, x15=%d, x16=%d, x17=%d, x18=%d, x19=%d, x20=%d",
            $time,
            dut.pc,
            dut.rf_inst.register[1],
            dut.rf_inst.register[2],
            dut.rf_inst.register[3],
            dut.rf_inst.register[4],
            dut.rf_inst.register[5],
            dut.rf_inst.register[6],
            dut.rf_inst.register[7],
            dut.rf_inst.register[8],
            dut.rf_inst.register[9],
            dut.rf_inst.register[10],
            dut.rf_inst.register[11],
            dut.rf_inst.register[12],
            dut.rf_inst.register[13],
            dut.rf_inst.register[14],
            dut.rf_inst.register[15],
            dut.rf_inst.register[16],
            dut.rf_inst.register[17],
            dut.rf_inst.register[18],
            dut.rf_inst.register[19],
            dut.rf_inst.register[20]
        );
    end

endmodule
