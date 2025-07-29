localparam BITW = 8;

// Random Access Memory (RAM) module.
//
// Perform actions when `enable` is set:
//
// 1. read mode (rw=0) - reads an address from `bus`; on the next cycle,
// drives into `bus` the value at that address.
//
// 2. write mode (rw=1) - reads an address from `bus`; on the next
// cycle, reads a value from `bus` and puts said value on the address.
module ram(
  input logic clock, n_reset, enable, rw,
  inout wire[BITW-1:0] bus
);
  localparam SIZE = 256;

  logic[BITW-1:0] memory[SIZE];
  logic[BITW-1:0] address, data;

  typedef enum {
    STATE_IDLE,
    STATE_READ,
    STATE_WRITE,
    STATE_MAX
  } state_t;
  logic[STATE_MAX-1:0] state;

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      state <= STATE_IDLE;
      for (int i = 0; i < SIZE; i++)
        memory[i] <= '0;
    end else case (state)
      0: begin state <= STATE_IDLE; end
      // STATE_IDLE: begin
      //   if (enable) begin
      //     address <= bus;
      //     state <= (~rw) ? STATE_READ : STATE_WRITE;
      //   end
      // end,
      // STATE_READ: begin
      //   if (enable)
      //     bus <= mem[address];
      //   state <= STATE_IDLE;
      // end,
      // STATE_WRITE: begin
      //   // at this point we have the address but we need to wait for another
      //   // enable with the data
      //   if (enable) begin
      //     if (rw) begin
      //       memory[address] <= bus;
      //     end
      //     state <= STATE_IDLE;
      //   end
      // end
    endcase
  end
endmodule
