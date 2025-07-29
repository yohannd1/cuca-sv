#!/usr/bin/env bash

set -ue
progname=$(basename "$0")

showHelp() {
  cat >&2 <<EOF
Usage: $progname <TB_NAME>
EOF
  exit 2
}

run() {
  printf >&2 "%s\n" "$*"
  "$@"
}

[ $# != 1 ] && showHelp || true

declare -A tbs
tbs[ram]="src/tb_ram.sv"
tbs[tri_buf]="src/tb_tri_buf.sv"

sources=(src/tri_buf.sv src/ram.sv)
testbench=${tbs[$1]}

run mkdir -p build
run iverilog -g2012 "${sources[@]}" "$testbench" -o build/out.com
run ./build/out.com
# run gtkwave waveform.vcd
