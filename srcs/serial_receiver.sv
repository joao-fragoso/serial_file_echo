/** A serial receiver module
**/

module serial_receiver
 #(
    parameter CLK_FREQ = 100_000_000, /**< Clock frequency */
    parameter BAUD_RATE = 115_200, /**< Serial baud rate */
    parameter PARITY = 0,
    parameter NUM_BITS = 8,
    parameter STOP_BITS = 1
  )
  (
    input                     clk,
    input                     rst_n,
    input                     rx,
    output reg [NUM_BITS-1:0] data,
    output reg                new_data
  );

  /** NUM_CYCLES clock number of cycles of each bit in serial port */
  localparam NUM_CYCLES = (CLK_FREQ / BAUD_RATE) - 1;
  /** HALF_CYCLES clock number of cycles of a half bit time */
  localparam HALF_CYCLES = (CLK_FREQ / (2*BAUD_RATE)) - 1;
  /** CNT_SIZE number of bits needed in a counter to compute a bit delay */
  localparam CNT_SIZE = $clog2(NUM_CYCLES);

  /** counter of bit time */
  reg [CNT_SIZE-1:0] counter_delay; // = 0;
  /** counter of received bits */
  reg [3:0] counter_bits; // = 'd1;
  reg [NUM_BITS-1:0] rdata;
  /** signal to synchronize RX on clk and avoid metasbility propagation*/
  reg [0:1] sync_rx;// = 'b0;

  localparam STATE_IDLE       = 3'd0;
  localparam STATE_START_BIT  = 3'd1;
  localparam STATE_DATA_BITS  = 3'd2;
  localparam STATE_PARITY     = 3'd4;
  localparam STATE_STOP_BITS  = 3'd5;

  reg [2:0] state;// = STATE_IDLE;

  /** synchronize rx */
  always @(posedge clk) begin
    sync_rx <= {sync_rx[1],rx};
  end

  always @(posedge clk) begin
    if (rst_n == 1'b0) begin
      state <= STATE_IDLE;
      counter_bits <= 'd0;
      counter_delay <= 'd0;
      rdata <= 'd0;
    end else begin
      case (state)
        STATE_START_BIT : begin
          if (counter_delay == HALF_CYCLES) begin
            state <= STATE_DATA_BITS;
            counter_delay <= 'd0;
          end else begin
            counter_delay <= counter_delay + 1;
          end
        end
        STATE_DATA_BITS : begin
          if (counter_delay == NUM_CYCLES) begin
            if (counter_bits == NUM_BITS) begin
              state <= STATE_PARITY;
            end else begin
              rdata <= {sync_rx[0], rdata[NUM_BITS-1:1]}; 
              counter_delay <= 'd0;
              counter_bits <= counter_bits + 1;              
            end
          end else begin
            counter_delay <= counter_delay + 1;
          end
        end
        STATE_PARITY : begin
          counter_bits <= 'd0;
          if (PARITY == 0) begin
            data <= rdata;
            new_data <= 1'b1;
            state <= STATE_STOP_BITS;
          end
          else begin
            if (counter_delay == NUM_CYCLES) begin
              counter_delay <= 'd0;
              data <= rdata;
              new_data <= 1'b1;
              state <= STATE_STOP_BITS;
            end else begin
              counter_delay <= counter_delay + 1;
            end
          end
        end
        STATE_STOP_BITS : begin
          new_data <= 1'b0;
          if (counter_delay == NUM_CYCLES) begin
            counter_delay <= 'd0;
            if (counter_bits == STOP_BITS-1) begin
              state <= STATE_IDLE;
            end else begin
              counter_bits <= counter_bits + 1;
            end
          end else begin
            counter_delay <= counter_delay + 1;
          end
        end
        default : 
          begin /** IDLE State */
            counter_bits <= 'd0;
            counter_delay <= 'd0;
            rdata <= 'd0;
            if (sync_rx[0] == 1'b0) begin /** start bit received */
              state <= STATE_START_BIT;            
            end
        end
      endcase
    end
  end

endmodule

