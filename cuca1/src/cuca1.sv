module cuca1(
  input logic clock, n_reset,
  output wire[BITW-1:0] ext_bus
);
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
  } enum_microprogram_pin;

  typedef logic[$clog2(PIN_MAX)-1:0] mcprog_line_t;

  localparam mcprog_line_t nothing = 'b0;

  localparam MCPROG_SIZE = 128;
  typedef logic[$clog2(MCPROG_SIZE)-1:0] mcprog_ptr_t;
  mcprog_line_t mcprog_mem[MCPROG_SIZE];

  wire[BITW-1:0] bus;

  alu_op_t alu_op;
  alu alu_(.clock(clock), .n_reset(n_reset), .op(alu_op), .bus(bus));

  mcprog_ptr_t mcprog_pc;
  mcprog_line_t mcprog_cur;
  assign mcprog_cur = mcprog_mem[mcprog_pc];

  register acc(.clock(clock), .rd_en(mcprog_cur[PIN_ACC_RD]), .wr_en(mcprog_cur[PIN_ACC_WR]));
  register pc(.clock(clock), .rd_en(mcprog_cur[PIN_PC_RD]), .wr_en(mcprog_cur[PIN_PC_WR]));
  register ir(.clock(clock), .rd_en(mcprog_cur[PIN_IR_RD]), .wr_en(mcprog_cur[PIN_IR_WR]));

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      mcprog_pc <= 0;

      mcprog_mem[0] = nothing;
      mcprog_mem[0][PIN_PC_RD] = 1'b1;
      mcprog_mem[0][PIN_MEM_RD] = 1'b1;
      mcprog_mem[1] = nothing;
      mcprog_mem[1][PIN_END] = 1'b1;
    end else begin
      if (mcprog_cur[PIN_END])
        mcprog_pc <= 0;
      else
        mcprog_pc <= mcprog_pc + 1;
    end
  end

  assign ext_bus = bus;
endmodule
