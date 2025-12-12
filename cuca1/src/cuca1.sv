package cuca1_pkg;
endpackage

module cuca1(
  input logic clk_in, n_rst_in,
  inout wire cfg::word_t ext_bus
);
  import alu_pkg::*;

  typedef enum {
    PIN_ACC_RD,
    PIN_ACC_WR,
    PIN_PC_RD,
    PIN_PC_WR,
    PIN_IR_RD,
    PIN_IR_WR,
    PIN_MEM_RD,
    PIN_MEM_WR,
    PIN_ALU_ADD,
    PIN_ALU_INC,
    PIN_ALU_SUB,
    PIN_ALU_READ_R0,
    PIN_ALU_READ_R1,
    PIN_ALU_WRITE_R0,
    PIN_ALU_WRITE_R1,
    PIN_END,
    PIN_MAX
  } _mcprog_pin_t;

  typedef logic[PIN_MAX-1:0] mcprog_line_t;

  localparam mcprog_line_t NOTHING = 'b0;

  localparam MCPROG_SIZE = 128;
  typedef logic[$clog2(MCPROG_SIZE)-1:0] mcprog_ptr_t;
  mcprog_line_t mcprog_mem[MCPROG_SIZE];

  wire cfg::word_t bus;

  alu_op_t alu_op;
  alu alu_u0(
    .clock(clk_in),
    .n_reset(n_rst_in),
    .op(alu_op),
    .bus(bus)
  );

  mcprog_ptr_t mcprog_pc;
  mcprog_line_t mcprog_cur;
  assign mcprog_cur = mcprog_mem[mcprog_pc];

  register reg_acc(
    .clock(clk_in),
    .rd_en(mcprog_cur[PIN_ACC_RD]),
    .wr_en(mcprog_cur[PIN_ACC_WR])
  );

  register reg_pc(
    .clock(clk_in),
    .rd_en(mcprog_cur[PIN_PC_RD]),
    .wr_en(mcprog_cur[PIN_PC_WR])
  );

  register reg_ir(
    .clock(clk_in),
    .rd_en(mcprog_cur[PIN_IR_RD]),
    .wr_en(mcprog_cur[PIN_IR_WR])
  );

  initial begin: microprogram_init
    mcprog_mem[0] <=
      (1 << PIN_PC_RD) |
      (1 << PIN_MEM_RD);

    mcprog_mem[1] <= PIN_END;
  end

  always_ff @(posedge clk_in) begin
    if (~n_rst_in) begin
      mcprog_pc <= 0;
    end else begin
      mcprog_pc <= mcprog_cur[PIN_END] ? 0 : mcprog_pc + 1;
    end
  end

  assign ext_bus = bus;
endmodule
