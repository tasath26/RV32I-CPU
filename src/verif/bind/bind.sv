module bind_wrapper;

    // ALU Assertions
    bind core alu_assert u_alu_assert_bind (
        .alu_op      (id_ex.ctrl.alu_op),  
        .alu_port_a  (alu_a),
        .alu_port_b  (alu_b),
        .alu_result  (alu_result)
    );

    // Core Assertions & Instruction Coverage
    bind core core_assert u_core_assert_bind (
        .clk    (clk),
        .rst    (rst),
        .pc     (if_id.pc),
        .opcode (opcode),
        .funct3 (funct3),
        .funct7 (funct7),
        .rs1    (rs1),
        .rs2    (rs2),
        .rd     (rd)
    );

    bind core instr_coverage u_instr_coverage_bind (
        .clk    (clk),
        .rst    (rst),
        .valid  (!stall_if_id && !flush_if_id), 
        .opcode (opcode),
        .funct3 (funct3),
        .funct7 (funct7)
    );

    // Memory Interface Assertions
    bind core mem_assert u_mem_assert_bind (
        .clk        (clk),
        .rst        (rst),
        .valid      (ex_mem.ctrl.mem_read || ex_mem.ctrl.mem_write), 
        .mem_read   (ex_mem.ctrl.mem_read),
        .mem_write  (ex_mem.ctrl.mem_write),
        .mem_addr   (ex_mem.alu_result),
        .mem_wdata  (mem_write_data),
        .mem_wmask  (mem_wen),
        .funct3     (ex_mem.ctrl.mem_type),
        .mem_rdata  (mem_read_data),
        .mem_rvalid (ex_mem.ctrl.mem_read) 
    );

    // Pipeline Hazards (Assertions & Coverage)
    bind core pipeline_assert u_pipeline_assert_bind (
        .clk            (clk),
        .rst            (rst),
        .valid_if       (1'b1), 
        .valid_id       (!flush_if_id),
        .valid_ex       (!flush_id_ex),
        .valid_mem      (1'b1),
        .valid_wb       (1'b1),
        .stall_if       (stall_pc),
        .stall_id       (stall_if_id),
        .flush_if_id    (flush_if_id),
        .flush_id_ex    (flush_id_ex),
        .rs1_ex         (id_ex.rs1),
        .rs2_ex         (id_ex.rs2),
        .rd_ex          (id_ex.rd),
        .rd_mem         (ex_mem.rd),
        .rd_wb          (mem_wb.rd),
        .regwrite_ex    (id_ex.ctrl.reg_write),
        .regwrite_mem   (ex_mem.ctrl.reg_write),
        .regwrite_wb    (mem_wb.ctrl.reg_write),
        .memwrite_ex    (id_ex.ctrl.mem_write),
        .forward_a_sel  (forward_a),
        .forward_b_sel  (forward_b),
        .is_load_mem    (ex_mem.ctrl.mem_read),
        .load_use_stall (stall_if_id && id_ex.ctrl.mem_read) 
    );

    bind core hazard_coverage u_hazard_coverage_bind (
        .clk            (clk),
        .rst            (rst),
        .valid_ex       (!flush_id_ex),
        .rs1_ex         (id_ex.rs1),
        .rs2_ex         (id_ex.rs2),
        .rd_mem         (ex_mem.rd),
        .rd_wb          (mem_wb.rd),
        .forward_a_sel  (forward_a),
        .forward_b_sel  (forward_b),
        .load_use_stall (stall_if_id && id_ex.ctrl.mem_read),
        .is_load_mem    (ex_mem.ctrl.mem_read)
    );

endmodule
