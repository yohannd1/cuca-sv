`timescale 1ns/1ns

module tb_alu;
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

  task test_add(input integer a, b);
    assert (~clock)
    else $error("bad start conditions");

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
    else $error("failed test_add");

    bus_cut();
  endtask

  task test_sub(input integer a, b);
    assert (~clock)
    else $error("bad start conditions");

    op <= ALU_WRITE_R0;
    bus_feed(a);
    @(negedge clock);

    op <= ALU_WRITE_R1;
    bus_feed(b);
    @(negedge clock);

    op <= ALU_SUB;
    bus_cut();
    @(negedge clock);

    assert (bus === a - b)
    else $error("failed test_sub");

    bus_cut();
  endtask

  task test_inc(input integer a);
    assert (~clock)
    else $error("bad start conditions");

    op <= ALU_WRITE_R1;
    bus_feed(a);
    @(negedge clock);

    op <= ALU_INC;
    bus_cut();
    @(negedge clock);

    assert (bus === a + 1)
    else $error("failed test_inc");

    bus_cut();
  endtask

  task test_rw();
    assert (~clock)
    else $error("bad start conditions");

    op <= ALU_WRITE_R0;
    bus_feed(15);
    @(negedge clock);

    op <= ALU_READ_R0;
    bus_cut();
    @(negedge clock);

    assert (bus === 15)
    else $error("failed test_rw (reg 0)");

    op <= ALU_WRITE_R1;
    bus_feed(15);
    @(negedge clock);

    op <= ALU_READ_R1;
    bus_cut();
    @(negedge clock);

    assert (bus === 15)
    else $error("failed test_rw (reg 1)");

    bus_cut();
  endtask

  initial begin
    clock = 0;
    forever #(T/2) clock = ~clock;
  end

  initial begin
    $dumpfile("build/waveform.vcd");
    $dumpvars(0, tb_alu);

    op <= ALU_NOP;

    n_reset <= 0;
    @(negedge clock);

    bus_feed(10);
    #1 assert (bus === 10)
    else $error("bus test 1 failed");

    bus_cut();
    #1 assert (bus === 'z)
    else $error("bus test 2 failed");

    @(negedge clock);

    n_reset <= 1;
    test_add(1, 5);
    test_sub(5, 3);
    test_inc(1);
    test_rw();

    $finish;
  end
endmodule
