`timescale 1ns/1ns

module tb_ram;
  import cfg::word_t;
  localparam T = 2;

  wire word_t bus;

  logic bus_tri_rw;
  word_t bus_tri_data;
  tri_buf #(.WIDTH(8)) u0(.rw(bus_tri_rw), .data(bus_tri_data), .bus(bus));

  logic clock, n_reset, enable, rw;
  ram uut(
    .clk_in(clock), .n_rst_in(n_reset), .enable(enable),
    .rw(rw), .bus(bus)
  );

  task bus_feed(input word_t value);
    bus_tri_data <= value;
    bus_tri_rw <= 1;
  endtask

  task bus_cut();
    bus_tri_rw <= 0;
  endtask

  // Test for a single memory read
  task test_read(input integer addr);
    assert (~clock && uut.state === ram_pkg::STATE_IDLE)
    else $error("bad start conditions");

    // issue read
    {enable, rw} <= 2'b10;
    @(posedge clock);

    // send address
    bus_feed(addr);
    @(posedge clock);

    bus_cut();
    @(negedge clock);

    assert (uut.address === addr)
    else $error("address not properly fed");

    // get value
    assert (uut.memory[addr] === bus)
    else $error("value is not expected");

    @(negedge clock);
    assert (uut.state === ram_pkg::STATE_IDLE && ~clock)
    else $error("bad end conditions");

    {enable, rw} <= 2'b00;
  endtask

  // Test for a single memory write
  task test_write(input integer addr, input integer val);
    assert (~clock && uut.state === ram_pkg::STATE_IDLE)
    else $error("bad start conditions");

    // issue write
    {enable, rw} <= 2'b11;
    @(posedge clock);

    // send address
    bus_feed(addr);
    @(posedge clock);

    // send value
    bus_feed(val);
    @(posedge clock);

    bus_cut();
    @(negedge clock);

    assert (uut.memory[addr] === val)
    else $error("failed test_write");

    assert (uut.state === ram_pkg::STATE_IDLE && ~clock)
    else $error("bad end conditions");

    {enable, rw} <= 2'b00;
  endtask

  initial begin
    clock = 0;
    forever #(T/2) clock = ~clock;
  end

  initial begin
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, tb_ram);

    n_reset <= 1'b0;
    #1;

    bus_feed(10);
    #1 assert (bus === 10) else $fatal(1, "bus test 1 failed");

    bus_cut();
    #1 assert (bus === 'z) else $fatal(1, "bus test 2 failed");

    @(negedge clock);

    {enable, rw} <= 2'b00;
    n_reset <= 1'b1;
    @(negedge clock);

    test_read(10);
    test_write(10, 15);
    test_read(10);

    $finish;
  end
endmodule
