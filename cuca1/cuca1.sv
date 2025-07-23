localparam BITW = 8;

module cuca1(
  input logic clock, n_reset,
  output logic[BITW-1:0] ext_bus
);
  localparam BITW = 8;

  // TODO: add an ALU

  typedef enum {
    PIN_ACC_EN,
    PIN_ACC_RW,
    PIN_PC_EN,
    PIN_PC_RW,
    PIN_IR_EN,
    PIN_IR_RW,
    PIN_MEM_EN,
    PIN_MEM_RW,
    PIN_END,
    CMD_MAX
  } microprogram_pin_t;

  typedef enum {
    STATE_FETCH,
    STATE_DECODE,
    STATE_EXECUTE
  } state_t;

  logic[BITW-1:0] bus;
  logic mi[CMD_MAX];

  register acc( .clock(clock), .enable(mi[PIN_ACC_EN]), .rw(mi[PIN_ACC_RW]) );
  register pc( .clock(clock), .enable(mi[PIN_PC_EN]), .rw(mi[PIN_PC_RW]) );
  register ir( .clock(clock), .enable(mi[PIN_IR_EN]), .rw(mi[PIN_IR_RW]) );
  assign ext_bus = bus;

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      for (int i = 0; i < CMD_MAX; i++)
        mi[i] = 1'b0;
      bus = '0;
    end else begin
      bus = '0;
    end
  end
endmodule
