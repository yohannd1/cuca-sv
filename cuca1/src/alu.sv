package alu_pkg;
  typedef enum {
    ALU_NOP,
    ALU_ADD,
    ALU_INC,
    ALU_SUB,
    ALU_READ_R0,
    ALU_READ_R1,
    ALU_WRITE_R0,
    ALU_WRITE_R1,
    ALU_MAX
  } _alu_op_enum_t;

  typedef logic[$clog2(ALU_MAX)-1:0] alu_op_t;
endpackage

// Arithmetic-Logic Unit (ALU)
//
// Comprised of two registers for storing operands: ula(0) and ula(1).
//
// Valid operations:
//   ALU_NOP: do nothing
//   ALU_ADD: bus <- ula(0) + ula(1)
//   ALU_INC: bus <- ula(1) + 1
//   ALU_SUB: bus <- ula(0) - ula(1)
//   ALU_READ_R0: bus <- ula(0)
//   ALU_READ_R1: bus <- ula(1)
//   ALU_WRITE_R0: ula(0) <- bus
//   ALU_WRITE_R1: ula(1) <- bus
module alu(
  input logic clock, n_reset,
  input alu_pkg::alu_op_t op,
  inout wire cfg::word_t bus
);
  import alu_pkg::*;

  cfg::word_t reg0, reg1;

  typedef enum {
    STATE_IDLE,
    STATE_OP,
    STATE_MAX
  } _state_enum_t;

  logic[$clog2(STATE_MAX)-1:0] state;

  logic tbuf_rw;
  cfg::word_t tbuf_data;
  tri_buf #(.WIDTH(cfg::WORD_SIZE)) tbuf(
    .rw(tbuf_rw),
    .data(tbuf_data),
    .bus(bus)
  );

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      state <= STATE_IDLE;
      reg0 <= 0;
      reg1 <= 0;
    end else case (state)
      STATE_IDLE: begin
        state <= (op == ALU_NOP) ? STATE_IDLE : STATE_OP;
      end
      STATE_OP: begin
        state <= STATE_IDLE;

        case (op)
          ALU_WRITE_R0: reg0 <= bus;
          ALU_WRITE_R1: reg1 <= bus;
        endcase
      end
    endcase
  end

  // bus I/O logic
  always_comb begin
    case (op)
      ALU_ADD: begin
        tbuf_data = reg0 + reg1;
        tbuf_rw = 1;
      end
      ALU_INC: begin
        tbuf_data = reg1 + 1;
        tbuf_rw = 1;
      end
      ALU_SUB: begin
        tbuf_data = reg0 - reg1;
        tbuf_rw = 1;
      end
      ALU_READ_R0: begin
        tbuf_data = reg0;
        tbuf_rw = 1;
      end
      ALU_READ_R1: begin
        tbuf_data = reg1;
        tbuf_rw = 1;
      end
      ALU_WRITE_R0: begin
        tbuf_rw = 0;
      end
      ALU_WRITE_R1: begin
        tbuf_rw = 0;
      end
      default: begin
        tbuf_rw = 0;
        tbuf_data = 'bX;
      end
    endcase
  end
endmodule
