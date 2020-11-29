`timescale 1ps/1ps
interface sfe_if 
#(
    parameter BAUD_RATE = 115_200, /**< Serial baud rate */
    parameter PARITY = 0,
    parameter NUM_BITS = 8,
    parameter STOP_BITS = 1
)
(
  input clk,
  input rst_n
);
  import uvm_pkg::*;

  localparam BIT_TIME = (64'd1_000_000_000_000 / BAUD_RATE );
  logic rx;
  logic tx;
  logic [7:0] an;
  logic [7:0] seg;

task init();
  rx = 1'b1;
endtask

task write_data(logic [NUM_BITS-1:0] data);
  automatic int i=0;
  automatic bit parity_even_bit = 1'b0;
//  `uvm_info("serial_interface", $sformatf("Sending data %x", data), UVM_MEDIUM);
//  `uvm_info("serial_interface","Start bit", UVM_MEDIUM);
  rx = 1'b0; // start bit
  #BIT_TIME;
  for (i=0; i<NUM_BITS; i++) begin
//    `uvm_info("serial_interface", $sformatf("Sending bit %d %x",i, data[i]), UVM_MEDIUM);
    rx = data[i];
    parity_even_bit = parity_even_bit ^ data[i];
    #BIT_TIME;
  end
  if (PARITY != 0) begin
    case (PARITY)
      4 : rx = 1'b0; // space
      3 : rx = 1'b1; // mark
      2 : rx = parity_even_bit; //even
      1 : rx = ~parity_even_bit; // odd
      default : rx = 1'b1; //stop bit
    endcase
    #BIT_TIME;
  end
//  `uvm_info("serial_interface","Stop bit", UVM_MEDIUM);
  rx = 1'b1;
  for (i=0; i<STOP_BITS; i++)
    #BIT_TIME;
//  `uvm_info("serial_interface", "Done data RX", UVM_MEDIUM);
endtask

endinterface

