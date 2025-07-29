module tri_buf #(parameter WIDTH) (
  input logic rw,
  input logic[WIDTH-1:0] data,
  inout wire[WIDTH-1:0] bus
);
  assign bus = rw ? data : 'bZ;
endmodule
