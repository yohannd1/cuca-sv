#!/usr/bin/env bash

set -e

run() {
  printf >&2 "%s\n" "$*"
  "$@"
}

sources=(src/tri_buf.sv src/ram.sv)
testbench=src/tb_tri_buf.sv

run mkdir -p build
run iverilog -g2012 "${sources[@]}" "$testbench" -o build/out.com
run ./build/out.com
# run gtkwave waveform.vcd
