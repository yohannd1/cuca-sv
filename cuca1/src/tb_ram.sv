`timescale 1ns/1ns

module tb_ram;
  localparam T = 2;

  logic clock, n_reset, enable, rw;
  logic[7:0] bus;
  ram uut(.*);

  initial begin
    clock = 0;
    forever #(T/2) clock = ~clock;
  end

  // task assert_equals #(type T) (input T expected, got);
  //   if (lhs != rhs) begin
  //     $error("expected %s, got %s", expected, got);
  //     $finish;
  //   end
  // endtask

  initial begin
    n_reset = 1;
    @(posedge clock);
    @(negedge clock);

    enable = 0;
    rw = 0;
    n_reset = 0;

    // 1. Single cell memory write & read
    // mem[10] = 15
    bus = 10;
    enable = 1;
    rw = 1;
    @(negedge clock);
    bus = 15;
    enable = 1;
    rw = 1;
    @(negedge clock);

    assert (uut.memory[10] == 15) else $error("FUCK");

    $finish;
  end
endmodule
