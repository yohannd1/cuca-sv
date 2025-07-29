`timescale 1ns/1ns

module tb_ram;
  localparam T = 2;

  wire[7:0] bus;

  logic bus_tri_rw;
  logic[7:0] bus_tri_data;
  tri_buf #(.WIDTH(8)) u0(.rw(bus_tri_rw), .data(bus_tri_data), .bus(bus));

  logic clock, n_reset, enable, rw;
  ram uut(.*);

  initial begin
    clock = 0;
    forever #(T/2) clock = ~clock;
  end

  task assert_or_quit(input integer condition, input string message);
    assert (condition) else begin
      $error("%s", message);
      $finish;
    end
  endtask

  task bus_feed(input logic value);
    bus_tri_data = value;
    bus_tri_rw = 1;
  endtask

  task bus_cut();
    bus_tri_rw = 0;
  endtask

  // Test for a single memory write
  task test_write(input integer idx, input integer val);
    bus_feed(idx);
    enable = 1;
    rw = 1;
    @(negedge clock);

    bus_feed(val);
    enable = 1;
    rw = 1;
    @(negedge clock);

    assert_or_quit(uut.memory[idx] === val, "failed test_write");
  endtask

  // Test for a single memory read
  task test_read(input integer idx, input integer val);
    bus_feed(idx);
    enable = 1;
    rw = 0;
    @(negedge clock);

    assert_or_quit(uut.memory[idx] === bus, "failed test_read");
  endtask

  initial begin
    n_reset = 1;
    @(posedge clock);
    @(negedge clock);

    enable = 0;
    rw = 0;
    n_reset = 0;

    test_write(10, 15);
    test_read(10, 15);

    $finish;
  end
endmodule
