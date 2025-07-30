`timescale 1ns/1ns

module tb_register;
  localparam T = 2;

  wire[7:0] bus;

  logic bus_tri_rw;
  logic[7:0] bus_tri_data;
  tri_buf #(.WIDTH(8)) u0(.rw(bus_tri_rw), .data(bus_tri_data), .bus(bus));

  logic clock, n_reset, wr_en, rd_en;
  register uut(.*);

  task bus_feed(input logic[7:0] value);
    bus_tri_data <= value;
    bus_tri_rw <= 1;
  endtask

  task bus_cut();
    bus_tri_rw <= 0;
  endtask

  task test_write(input integer val);
    assert (~clock)
    else $fatal(0, "bad start conditions");

    wr_en <= 1;
    bus_feed(val);
    @(negedge clock);

    assert (uut.data === val)
    else $fatal(0, "failed test_write");

    assert (~clock)
    else $fatal(0, "bad end conditions");

    wr_en <= 0;
    bus_cut();
  endtask

  task test_read(input integer val);
    assert (~clock)
    else $fatal(0, "bad start conditions");

    rd_en <= 1;
    bus_cut();
    @(negedge clock);

    assert (val === bus)
    else $fatal(0, "value is not expected");

    assert (~clock)
    else $fatal(0, "bad end conditions");

    rd_en <= 0;
  endtask

  initial begin
    clock = 0;
    forever #(T/2) clock = ~clock;
  end

  initial begin
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, tb_register);

    n_reset <= 0;
    @(negedge clock);

    bus_feed(10);
    #1 assert (bus === 10)
    else $fatal(0, "bus test 1 failed");

    bus_cut();
    #1 assert (bus === 'z)
    else $fatal(0, "bus test 2 failed");

    @(negedge clock);
    assert (uut.data === 0);

    n_reset <= 1;
    rd_en <= 0;
    wr_en <= 0;
    @(negedge clock);
    assert (uut.data === 0);

    test_write(20);

    test_read(20);

    $finish;
  end
endmodule
