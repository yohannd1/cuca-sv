package ram_pkg;
  typedef enum {
    STATE_IDLE,
    STATE_READING_ADDR,
    STATE_READING_OUT,
    STATE_WRITING_ADDR,
    STATE_WRITING_IN,
    STATE_MAX
  } _ram_state_t;

  localparam BITW = 8;
endpackage

// Random Access Memory (RAM) module.
//
// READING
// 1. Wait for enable=1, rw=0
// 2. Wait for enable=1: address <- bus
// 3. Wait for enable=1: bus <- mem[address]
//
// WRITING
// 1. Wait for enable=1, rw=1
// 2. Wait for enable=1: address <- bus
// 3. Wait for enable=1: mem[address] <- bus
module ram(
  input logic clock, n_reset, enable, rw,
  inout wire[ram_pkg::BITW-1:0] bus
);
  import ram_pkg::*;
  import ram_pkg::STATE_READING_OUT;
  localparam RAM_SIZE = 256;

  logic[BITW-1:0] memory[RAM_SIZE];
  logic[BITW-1:0] address, data;
  logic[$clog2(STATE_MAX)-1:0] state;

  wire tbuf_rw;

  // Bus I/O logic (the bus is written to only when reading data from a memory address)
  tri_buf #(.WIDTH(BITW)) buf_out(
    .rw(tbuf_rw),
    .data((address < RAM_SIZE) ? memory[address] : 8'bX),
    .bus(bus)
  );

  assign tbuf_rw = (state == STATE_READING_OUT);

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      state <= STATE_IDLE;
      for (int i = 0; i < RAM_SIZE; i++)
        memory[i] <= 'b0;
    end else case(state)
      STATE_IDLE: if (enable) begin
        state <= rw ? STATE_WRITING_ADDR : STATE_READING_ADDR;
      end
      STATE_READING_ADDR: if (enable) begin
        address <= bus;
        state <= STATE_READING_OUT;
      end
      STATE_READING_OUT: state <= STATE_IDLE;
      STATE_WRITING_ADDR: if (enable) begin
        address <= bus;
        state <= STATE_WRITING_IN;
      end
      STATE_WRITING_IN: if (enable) begin
        memory[address] <= bus;
        state <= STATE_IDLE;
      end
    endcase
  end
endmodule
