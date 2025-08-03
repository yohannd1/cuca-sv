#!/usr/bin/env bash

set -ue
progname=$(basename "$0")

showHelp() {
  cat >&2 <<EOF
Usage: $progname { test <NAME> | synth }
EOF
  exit 2
}

run() {
  printf >&2 "%s\n" "$*"
  "$@"
}

[ $# -gt 0 ] || showHelp

declare -A tbs
tbs[ram]="src/tb_ram.sv"
tbs[tri_buf]="src/tb_tri_buf.sv"
tbs[register]="src/tb_register.sv"
tbs[alu]="src/tb_alu.sv"
tbs[cuca1]="src/tb_cuca1.sv"

sources=(src/tri_buf.sv src/ram.sv src/register.sv src/alu.sv src/cuca1.sv)

if [ ! -d build ]; then
  printf >&2 "build dir not found - creating it...\n"
  mkdir build
fi

case "$1" in
  test)
    [ $# = 2 ] || showHelp
    testbench=${tbs[$2]}
    run iverilog -g2012 "${sources[@]}" "$testbench" -o build/out.com
    run ./build/out.com
    ;;
  synth)
    [ $# = 1 ] || showHelp
    run sv2v -w build/all.v "${sources[@]}"
    run yosys -p '
      read_verilog build/all.v;
      # show -format dot -prefix build/alu alu;
    '
    ;;
  *) showHelp ;;
esac
