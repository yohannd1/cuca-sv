module register(
  input logic clock, n_reset, wr_en, rd_en,
  inout wire[BITW-1:0] bus
);
  logic[BITW-1:0] data;

  logic tbuf_rw;
  logic[BITW-1:0] tbuf_out_data;
  tri_buf #(.WIDTH(BITW)) tbuf(.rw(tbuf_rw), .data(tbuf_out_data), .bus(bus));

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      data <= 0;
      tbuf_rw <= 0;
      tbuf_out_data <= 0;
    end else begin
      case ({wr_en, rd_en})
        2'b00: begin
          // Do nothing
          tbuf_rw <= 0;
        end
        2'b01: begin
          // Read from register - write into bus
          tbuf_rw <= 1;
          tbuf_out_data <= data;
        end
        2'b10: begin
          // Write into register - read from bus
          tbuf_rw <= 0;
          data <= bus;
        end
        2'b11: begin
          // Invalid operation... do nothing
          tbuf_rw <= 0;
        end
      endcase
    end
  end
endmodule;
