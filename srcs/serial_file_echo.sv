module sef #(
    parameter CLK_FREQ = 100_000_000, /**< Clock frequency */
    parameter BAUD_RATE = 115_200, /**< Serial baud rate */
    parameter PARITY = 0,
    parameter NUM_BITS = 8,
    parameter STOP_BITS = 1,
    parameter MAX_FILE_SIZE = 2048
)
(
  input clk,
  input rst_n,
  input rx,
  output tx,
  output [7:0] an,
  output [7:0] seg
);

wire [NUM_BITS-1:0] rx_data;
wire rx_new_data;
wire [NUM_BITS-1:0] tx_data;
wire tx_req;
wire tx_ack;
wire [31:0] value2display;
wire [7:0] mask_n_display;
reg [0:3] sync_rst_n = 'h0;

always @(posedge clk)
  sync_rst_n <= {sync_rst_n[1:3], rst_n};

serial_receiver
#(
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE),
  .PARITY(PARITY),
  .NUM_BITS(NUM_BITS),
  .STOP_BITS(STOP_BITS)
)
serial_receiver_i
(
  .clk(clk),
  .rst_n(sync_rst_n[0]),
  .rx(rx),
  .data(rx_data),
  .new_data(rx_new_data)
);

file_handler
#(
  .NUM_BITS(NUM_BITS),
  .MAX_FILE_SIZE(MAX_FILE_SIZE)
)
file_handler_i
(
  .clk(clk),
  .rst_n(sync_rst_n[0]),
  .new_data(rx_new_data),
  .rx_data(rx_data),
  .req(tx_req),
  .ack(tx_ack),
  .tx_data(tx_data),
  .bcd_counter(value2display),
  .mask_n(mask_n_display)
);

serial_transmitter
#(
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE),
  .PARITY(PARITY),
  .NUM_BITS(NUM_BITS),
  .STOP_BITS(STOP_BITS)
)
serial_transmitter_i
(
  .clk(clk),
  .rst_n(sync_rst_n[0]),
  .tx(tx),
  .req(tx_req),
  .data(tx_data),
  .ack(tx_ack)
);

seven_seg
#(
  .CLK_FREQ(CLK_FREQ)
)
seven_seg_i
(
  .clk(clk),
  .value(value2display),
  .point(8'b0000_0000),
  .mask_n(mask_n_display),
  .anode(an),
  .segment(seg)
);

  
endmodule

