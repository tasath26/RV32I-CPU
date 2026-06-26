RTL_DIR  = src/rtl
TB_DIR   = src/tb
SIM_DIR  = src/sim
TEST_DIR = /home/csdp1440/riscv/code/compliance_tests

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
           $(RTL_DIR)/pipeline_control.sv \
           $(RTL_DIR)/branch_pred.sv \
           $(RTL_DIR)/core.sv

TB_SRCS = $(TB_DIR)/tb.sv

TEST ?= add

COMPLIANCE_TESTS = add addi and andi auipc beq bge bgeu blt bltu bne \
                   j jal jalr lb lbu lh lhu lui lw or ori sb sh \
                   sll slli slt slti sra srai srl srli \
                   sub sw xor xori

sim:
	vcs -full64 -sverilog \
		+define+IMEM_FILE=\"$(TEST_DIR)/$(TEST).imem.dat\" \
		+define+DMEM_FILE=\"$(TEST_DIR)/$(TEST).dmem.dat\" \
		+define+TEST_NAME=\"$(TEST)\" \
		$(TB_SRCS) $(RTL_SRCS) \
		-o $(SIM_DIR)/simv

run: sim
	$(SIM_DIR)/simv

wave: run
	dve -vpd $(SIM_DIR)/tb.vcd &

compliance:
	@pass=0; fail=0; timeout=0; \
	fail_list=""; timeout_list=""; \
	for t in $(COMPLIANCE_TESTS); do \
		vcs -full64 -sverilog \
			+define+IMEM_FILE=\"$(TEST_DIR)/$$t.imem.dat\" \
			+define+DMEM_FILE=\"$(TEST_DIR)/$$t.dmem.dat\" \
			+define+TEST_NAME=\"$$t\" \
			$(TB_SRCS) $(RTL_SRCS) \
			-o $(SIM_DIR)/simv 2>/dev/null; \
		result=$$($(SIM_DIR)/simv 2>/dev/null); \
		echo "$$t : $$result"; \
		if echo "$$result" | grep -q "^PASS"; then \
			pass=$$((pass + 1)); \
		elif echo "$$result" | grep -q "^TIMEOUT"; then \
			timeout=$$((timeout + 1)); \
			timeout_list="$$timeout_list $$t"; \
		else \
			fail=$$((fail + 1)); \
			fail_list="$$fail_list $$t"; \
		fi; \
	done; \
	echo ""; \
	echo "================================"; \
	echo "|     COMPLIANCE RESULTS       |"; \
	echo "================================"; \
	printf "  PASS:    %-3d                \n" $$pass; \
	printf "  FAIL:    %-3d                \n" $$fail; \
	printf "  TIMEOUT: %-3d                \n" $$timeout; \
	echo "================================"; \
	echo " FAILED TESTS:   $$fail_list"; \
	echo " TIMEOUT TESTS:  $$timeout_list"; \
	echo "================================"

clean:
	rm -f $(SIM_DIR)/simv $(SIM_DIR)/tb.vcd
	rm -rf csrc simv.daidir

.PHONY: sim run wave compliance clean

