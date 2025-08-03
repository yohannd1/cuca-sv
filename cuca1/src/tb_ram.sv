`timescale 1ns/1ns

module tb_ram;
  localparam T = 2;

  wire[7:0] bus;

  logic bus_tri_rw;
  logic[7:0] bus_tri_data;
  tri_buf #(.WIDTH(8)) u0(.rw(bus_tri_rw), .data(bus_tri_data), .bus(bus));

  logic clock, n_reset, enable, rw;
  ram uut(.*);

  task bus_feed(input logic[7:0] value);
    bus_tri_data <= value;
    bus_tri_rw <= 1;
  endtask

  task bus_cut();
    bus_tri_rw <= 0;
  endtask

  // Test for a single memory write
  task test_write(input integer idx, input integer val);
    assert (~clock && uut.state === STATE_IDLE)
    else $error("bad start conditions");

    enable <= 1;
    rw <= 1;
    bus_feed(idx);
    @(negedge clock);

    bus_feed(val);
    @(negedge clock);

    assert (uut.memory[idx] === val)
    else $error("failed test_write");

    assert (uut.state === STATE_IDLE && ~clock)
    else $error("bad end conditions");

    bus_cut();
    enable <= 0;
    rw <= 0;
  endtask

  // Test for a single memory read
  task test_read(input integer idx);
    assert (~clock && uut.state === STATE_IDLE)
    else $error("bad start conditions");

    bus_feed(idx);
    enable <= 1;
    rw <= 0;
    @(negedge clock);

    bus_cut();
    @(negedge clock);

    assert (uut.memory[idx] === bus)
    else $error("value is not expected");

    assert (uut.state === STATE_IDLE && ~clock)
    else $error("bad end conditions");
  endtask

  initial begin
    clock = 0;
    forever #(T/2) clock = ~clock;
  end

  initial begin
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, tb_ram);

    n_reset <= 0;
    @(negedge clock);

    bus_feed(10);
    #1 assert (bus === 10)
    else $error("bus test 1 failed");

    bus_cut();
    #1 assert (bus === 'z)
    else $error("bus test 2 failed");

    @(negedge clock);

    enable <= 0;
    rw <= 0;
    n_reset <= 1;
    @(negedge clock);

    test_read(10);
    test_write(10, 15);
    test_read(10);

    $finish;
  end
endmodule
