module ram(
  input logic clock, n_reset, enable, rw,
  input logic[BITW-1:0] bus
);
  localparam SIZE = 256;
  logic[BITW-1:0] memory[SIZE];

  typedef enum {
    STATE_IDLE,
    STATE_READ_RESULT,
    STATE_MAX
  } state_t;
  logic[STATE_MAX-1:0] state;

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      state = STATE_IDLE;
      for (int i = 0; i < SIZE; i++)
        memory[i] = '0;
    end else case (state)
      STATE_IDLE: begin end, // TODO
      STATE_READ_RESULT: begin end, // TODO
      // TODO: memory writes
    endcase
  end
endmodule
