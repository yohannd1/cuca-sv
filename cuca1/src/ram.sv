localparam BITW = 8;

typedef enum {
  STATE_IDLE,
  STATE_READ,
  STATE_WRITE,
  STATE_MAX
} state_t;

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
  logic[$clog2(STATE_MAX)-1:0] state;

  logic bus_tri_rw;
  logic[7:0] bus_tri_data;
  tri_buf #(.WIDTH(BITW)) u0(.rw(bus_tri_rw), .data(bus_tri_data), .bus(bus));

  task automatic bus_feed(input logic[BITW-1:0] value);
    bus_tri_data <= value;
    bus_tri_rw <= 1;
  endtask

  task automatic bus_cut();
    bus_tri_rw <= 0;
  endtask

  always_ff @(posedge clock) begin
    if (~n_reset) begin
      bus_tri_rw <= 0;
      state <= STATE_IDLE;
      for (int i = 0; i < SIZE; i++)
        memory[i] <= '0;
    end else begin
      case (state)
        STATE_IDLE: begin
          bus_cut();

          if (enable) begin
            address <= bus;
            state <= (~rw) ? STATE_READ : STATE_WRITE;
          end
        end

        STATE_READ: begin
          bus_cut();

          if (enable) begin
            bus_tri_rw <= 1;
            bus_tri_data <= memory[address];
          end
          state <= STATE_IDLE;
        end

        STATE_WRITE: begin
          bus_cut();

          // at this point we have the address but we need to wait for another
          // enable with the data
          if (enable && rw) begin
            memory[address] <= bus;
            state <= STATE_IDLE;
          end
        end
      endcase
    end
  end
endmodule
