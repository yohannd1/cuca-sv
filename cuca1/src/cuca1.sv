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

  typedef enum {
    STATE_FETCH,
    STATE_DECODE,
    STATE_EXECUTE,
    STATE_MAX
  } enum_state;

  typedef logic[$clog2(PIN_MAX)-1:0] mcprog_line_t;
  typedef logic[$clog2(STATE_MAX)-1:0] state_t;

  // Constants
  localparam mcprog_line_t nothing = 'b0;

  wire[BITW-1:0] bus;

  alu_op_t alu_op;
  alu alu_(.clock(clock), .n_reset(n_reset), .op(alu_op), .bus(bus));

  register acc(.clock(clock), .rd_en(current[PIN_ACC_RD]), .wr_en(current[PIN_ACC_WR]));
  register pc(.clock(clock), .rd_en(current[PIN_PC_RD]), .wr_en(current[PIN_PC_WR]));
  register ir(.clock(clock), .rd_en(current[PIN_IR_RD]), .wr_en(current[PIN_IR_WR]));

  state_t state;
  mcprog_line_t current;

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      current <= nothing;
      state <= STATE_FETCH;
    end else begin
      case (state)
        STATE_FETCH: begin
          // TODO
        end
        STATE_DECODE: begin
          // TODO
        end
        STATE_EXECUTE: begin
          // TODO
        end
      endcase
    end
  end

  assign ext_bus = bus;
endmodule
