`timescale 1ns/1ns

module tb_tri_buf;
  localparam WIDTH = 8;
  typedef logic[WIDTH-1:0] data_t;

  module test_single;
    logic rw;
    wire[WIDTH-1:0] bus;
    logic[WIDTH-1:0] data;
    tri_buf #(.WIDTH(WIDTH)) uut(.*);

    task test();
      rw = 0;
      #1;
      assert (bus === 'z);

      data = 5;
      rw = 1;
      #1;
      assert (bus == 5);

      rw = 0;
      data = 6;
      #1;
      assert (bus === 'z);

      rw = 1;
      #1;
      assert (bus == 6);
    endtask
  endmodule

  module test_multiple;
    wire[WIDTH-1:0] bus;
    logic[WIDTH-1:0] data_0, data_1;
    logic rw_0, rw_1;

    tri_buf #(.WIDTH(WIDTH)) u0(.bus(bus), .rw(rw_0), .data(data_0));
    tri_buf #(.WIDTH(WIDTH)) u1(.bus(bus), .rw(rw_1), .data(data_1));

    task test();
      data_0 = 15;
      data_1 = 20;

      rw_0 = 0;
      rw_1 = 0;
      #1;
      assert (bus === 'z);

      rw_0 = 1;
      rw_1 = 0;
      #1;
      assert (bus === 15);

      rw_0 = 0;
      rw_1 = 1;
      #1;
      assert (bus === 20);

      rw_0 = 1;
      rw_1 = 1;
      #1;
      assert ($countbits(bus, 'x) > 0);
    endtask
  endmodule

  initial begin
    test_single.test();
    test_multiple.test();
    $finish;
  end
endmodule
