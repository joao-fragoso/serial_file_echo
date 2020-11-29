package project_pkg;

  parameter CLK_FREQ = 100_000_000;
  parameter BAUD_RATE = 115_200;
  parameter NUM_BITS = 8;
  parameter PARITY = 0;
  parameter STOP_BITS = 1;
  parameter MAX_FILE_SIZE = 2048;
  parameter SOT = 'd2;
  parameter EOT = 'd3;

  import uvm_pkg::*;

  `include "uvm_macros.svh"
  `include "file_seq_item.svh"
  `include "file_comparator.svh"
  `include "serial_driver.svh"
  `include "file_sequence.svh"
  `include "file_sequencer.svh"
  `include "tx_monitor.svh"
  `include "file_scoreboard.svh"
  `include "project_env.svh"
  `include "serial_test.svh"

endpackage