RTL_DIR  = src/rtl
TB_DIR   = src/tb
SIM_DIR  = src/sim

TEST     ?= simple
TEST_DIR ?= $(TB_DIR)/testfiles

# Sources
RTL_SRCS = $(RTL_DIR)/rv32i_pkg.sv \
           $(RTL_DIR)/alu.sv \
           $(RTL_DIR)/branch_unit.sv \
           $(RTL_DIR)/control.sv \
           $(RTL_DIR)/decode.sv \
           $(RTL_DIR)/dmem.sv \
           $(RTL_DIR)/imem.sv \
           $(RTL_DIR)/immgen.sv \
           $(RTL_DIR)/load_store_unit.sv \
           $(RTL_DIR)/register_file.sv \
           $(RTL_DIR)/core.sv

TB_SRCS  = $(TB_DIR)/tb.sv

SIM_OUT  = $(SIM_DIR)/sim
VCD_OUT  = $(SIM_DIR)/tb.vcd

# Default target
all: sim

sim: $(RTL_SRCS) $(TB_SRCS)
	iverilog -g2012 -o $(SIM_OUT) \
	    -DHEX_FILE=\"$(TEST_DIR)/$(TEST).hex\" \
	    $(TB_SRCS) $(RTL_SRCS)

# Run simulation
run: sim
	vvp $(SIM_OUT)

# Open waveform
wave: $(VCD_OUT)
	gtkwave $(VCD_OUT)

tests:
	mkdir -p $(TEST_DIR)
	chmod +x $(TB_DIR)/generate_tests.sh
	cd $(TB_DIR) && bash generate_tests.sh

# Clean
clean:
	rm -f $(SIM_OUT) $(VCD_OUT)

.PHONY: all run wave tests clean
