`timescale 1ns/1ns

module tb_ram;
  localparam T = 2;

  wire[7:0] bus;

  logic bus_tri_rw;
  logic[7:0] bus_tri_data;
  tri_buf #(.WIDTH(8)) u0(.rw(bus_tri_rw), .data(bus_tri_data), .bus(bus));

  logic clock, n_reset;
  alu_op_t op;
  alu uut(.*);

  task bus_feed(input logic[7:0] value);
    bus_tri_data <= value;
    bus_tri_rw <= 1;
  endtask

  task bus_cut();
    bus_tri_rw <= 0;
  endtask

  // Test for a single memory write
  task test_add(input integer a, b);
    assert (~clock)
    else $fatal(0, "bad start conditions");

    op <= ALU_WRITE_R0;
    bus_feed(a);
    @(negedge clock);

    op <= ALU_WRITE_R1;
    bus_feed(b);
    @(negedge clock);

    op <= ALU_ADD;
    bus_cut();
    @(negedge clock);

    assert (bus === a + b)
    else $fatal(0, "failed test_add");

    bus_cut();
  endtask

  initial begin
    clock = 0;
    forever #(T/2) clock = ~clock;
  end

  initial begin
    // $dumpfile("build/waveform.vcd");
    // $dumpvars(0, tb_alu);

    op <= ALU_NOP;

    n_reset <= 0;
    @(negedge clock);

    bus_feed(10);
    #1 assert (bus === 10)
    else $fatal(0, "bus test 1 failed");

    bus_cut();
    #1 assert (bus === 'z)
    else $fatal(0, "bus test 2 failed");

    @(negedge clock);

    n_reset <= 1;
    @(negedge clock);

    test_add(1, 5);

    $finish;
  end
endmodule
