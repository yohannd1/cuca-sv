// General-purpose register.
module register(
  input logic clock, n_reset, wr_en, rd_en,
  inout wire cfg::word_t bus
);
  cfg::word_t data;

  logic tbuf_rw;
  tri_buf #(.WIDTH(cfg::WORD_SIZE)) tbuf(.rw(tbuf_rw), .data(data), .bus(bus));

  typedef enum {
    STATE_IDLE,
    STATE_WRITING_IN,
    STATE_READING_OUT,
    STATE_MAX
  } _state_enum_t;
  logic[$clog2(STATE_MAX)-1:0] state;

  logic should_read, should_write;
  assign should_read = ({wr_en, rd_en} == 2'b01); assign should_write = ({wr_en, rd_en} == 2'b10);

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      state <= STATE_IDLE;
      data <= 0;
    end else begin
      case (state)
        STATE_IDLE: begin
          if (should_read)
            state <= STATE_READING_OUT;
          else if (should_write)
            state <= STATE_WRITING_IN;
        end
        STATE_READING_OUT: begin
          state <= STATE_IDLE;
        end
        STATE_WRITING_IN: begin
          data <= bus;
          state <= STATE_IDLE;
        end
      endcase
    end
  end

  // only write data to the bus when in the read state
  assign tbuf_rw = (state == STATE_READING_OUT);
endmodule
