package ram_pkg;
  typedef enum {
    STATE_IDLE,
    STATE_READING_ADDR,
    STATE_READING_OUT,
    STATE_WRITING_ADDR,
    STATE_WRITING_IN,
    STATE_MAX
  } _state_t;

  typedef logic[$clog2(STATE_MAX)-1:0] state_t;
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
  input logic clk_in, n_rst_in, enable, rw,
  inout wire cfg::word_t bus
);
  import cfg::word_t;
  import ram_pkg::*;

  localparam RAM_SIZE = 256;

  ram_pkg::state_t state;

  word_t memory[RAM_SIZE];
  word_t address, data;

  wire tbuf_rw;
  assign tbuf_rw = (state == STATE_READING_OUT);

  // Bus I/O logic (the bus is written to only when reading data from a memory address)
  tri_buf #(.WIDTH(cfg::WORD_SIZE)) buf_out(
    .rw(tbuf_rw),
    .data((address < RAM_SIZE) ? memory[address] : 8'bX),
    .bus(bus)
  );

  always_ff @(posedge clk_in) begin
    if (~n_rst_in) begin
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
