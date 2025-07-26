#!/usr/bin/env bash

set -e

run() {
  printf >&2 "%s\n" "$*"
  "$@"
}

sources=()
testbench="src/tb_ram.sv"

run mkdir -p build
run iverilog -g2012 "${sources[@]}" "$testbench" -o build/out.com
run ./build/out.com
# run gtkwave waveform.vcd
