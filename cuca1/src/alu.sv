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
} _alu_op_t;

typedef logic[$clog2(ALU_MAX)-1:0] alu_op_t;

// Arithmetic Logic Unit (ALU)
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
  input alu_op_t op,
  inout wire[BITW-1:0] bus
);
  logic[BITW-1:0] reg0, reg1;

  logic bus_tri_rw;
  logic[BITW-1:0] bus_tri_data;
  logic bus_tri_rw_actual;
  tri_buf #(.WIDTH(BITW)) buf_out(
    .rw(clock ? bus_tri_rw : 1'b0), // only output data on single clock cycles (FIXME: this might actually not be ideal...)
    .data(bus_tri_data),
    .bus(bus)
  );

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      reg0 <= 0;
      reg1 <= 0;
      bus_tri_rw <= 0;
    end else case (op)
      ALU_NOP: begin
        bus_tri_rw <= 0;
      end
      ALU_ADD: begin
        bus_tri_data <= reg0 + reg1;
        bus_tri_rw <= 1;
      end
      ALU_INC: begin
        bus_tri_data <= reg1 + 1;
        bus_tri_rw <= 1;
      end
      ALU_SUB: begin
        bus_tri_data <= reg0 - reg1;
        bus_tri_rw <= 1;
      end
      ALU_READ_R0: begin
        bus_tri_data <= reg0;
        bus_tri_rw <= 1;
      end
      ALU_READ_R1: begin
        bus_tri_data <= reg1;
        bus_tri_rw <= 1;
      end
      ALU_WRITE_R0: begin
        bus_tri_rw <= 0;
        reg0 <= bus;
      end
      ALU_WRITE_R1: begin
        bus_tri_rw <= 0;
        reg1 <= bus;
      end
    endcase
  end
endmodule
