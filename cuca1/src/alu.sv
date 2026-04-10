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

// An Arithmetic-Logic Unit (ALU) with the capability of operating basic
// addition and subtraction commands.
//
// Comprised of two registers for storing operands: alu(0) and alu(1).
//
// Valid operations:
//   ALU_NOP: do nothing
//   ALU_ADD: bus <- alu(0) + alu(1)
//   ALU_INC: bus <- alu(1) + 1
//   ALU_SUB: bus <- alu(0) - alu(1)
//   ALU_READ_R0: bus <- alu(0)
//   ALU_READ_R1: bus <- alu(1)
//   ALU_WRITE_R0: alu(0) <- bus
//   ALU_WRITE_R1: alu(1) <- bus
//
// All operations take one cycle to take effect. Bus operations are "sticky"
// and should be immediately followed by another operation (not even ALU_NOP).
module alu(
  input logic clock, n_reset,
  input alu_pkg::alu_op_t op,
  inout wire cfg::word_t bus
);
  import alu_pkg::*;

  cfg::word_t reg0, reg1;

  logic tbuf_rw;
  cfg::word_t tbuf_data;
  tri_buf #(.WIDTH(cfg::WORD_SIZE)) tbuf(
    .rw(tbuf_rw),
    .data(tbuf_data),
    .bus(bus)
  );

  alu_op_t cur_op;

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      cur_op <= ALU_NOP;
      reg0 <= 'b0;
      reg1 <= 'b0;
    end else begin
      cur_op <= op;

      // register transfers
      case (op)
        ALU_WRITE_R0: reg0 <= bus;
        ALU_WRITE_R1: reg1 <= bus;
        default: begin end
      endcase
    end
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
      default: begin
        tbuf_rw = 0;
        tbuf_data = 'b0;
      end
    endcase
  end
endmodule
