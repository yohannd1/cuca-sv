`timescale 1ns/1ns

module tb_cuca1;
  logic clk, n_rst;
  wire cfg::word_t mem_bus;

  cuca1 uut(.clk_in(clk), .n_rst_in(n_rst), .ext_bus(mem_bus));
  ram memory(.clk_in(clk), .bus(mem_bus));

  initial begin
    #5;

    $finish;
  end
endmodule
