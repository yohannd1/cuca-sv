`timescale 1ns/1ns

module tb_cuca1;
  logic clock;
  logic n_reset;
  wire[BITW-1:0] bus;

  cuca1 uut(.clock(clock), .n_reset(n_reset), .ext_bus(bus));
  ram memory(.clock(clock), .bus(bus));

  initial begin
    #5;
    $finish;
  end
endmodule
