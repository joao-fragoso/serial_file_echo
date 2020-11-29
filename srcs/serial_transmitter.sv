/** A serial transmitter module
**/

module serial_transmitter
 #(
    parameter CLK_FREQ = 100_000_000, /**< Clock frequency */
    parameter BAUD_RATE = 115_200, /**< Serial baud rate */
    parameter PARITY = 0,
    parameter NUM_BITS = 8,
    parameter STOP_BITS = 1
  )
  (
    input                clk,
    input                rst_n,
    output reg           tx,
    input                req,
    input [NUM_BITS-1:0] data,
    output reg            ack
  );

  /** NUM_CYCLES clock number of cycles of each bit in serial port */
  localparam NUM_CYCLES = (CLK_FREQ / BAUD_RATE) - 1;
  /** CNT_SIZE number of bits needed in a counter to compute a bit delay */
  localparam CNT_SIZE = $clog2(NUM_CYCLES);

  /** counter of bit time */
  reg [CNT_SIZE-1:0] counter_delay; // = 0;
  /** counter of received bits */
  reg [3:0] counter_bits; // = 'd1;
  reg [NUM_BITS-1:0] sample_data;
//  reg busy = 1'b0;
  reg parity_even_bit; // = 1'b0;
  
  localparam STATE_IDLE       = 3'd0;
  localparam STATE_START_BIT  = 3'd1;
  localparam STATE_DATA_BITS  = 3'd2;
  localparam STATE_PARITY     = 3'd4;
  localparam STATE_STOP_BITS  = 3'd5;

  reg [2:0] state; // = STATE_IDLE;

  always @(posedge clk) begin
    if (rst_n == 1'b0) begin
      state <= STATE_IDLE;
      counter_bits <= 'd1;
      counter_delay <= 'd0;
      sample_data <= 'd0;
      tx <= 1'b1;
      ack <= 1'b0;
      parity_even_bit <= 1'b0;
//      busy = 1'b0;
    end else begin
      case (state)
        STATE_START_BIT : begin
          if (counter_delay == NUM_CYCLES) begin
            state <= STATE_DATA_BITS;
            tx <= sample_data[0];
            parity_even_bit <= parity_even_bit ^ sample_data[0];
            sample_data <= {1'b0,sample_data[NUM_BITS-1:1]};
            counter_delay <= 'd0;
          end else begin
            counter_delay <= counter_delay + 1;
          end
        end
        STATE_DATA_BITS : begin
          if (counter_delay == NUM_CYCLES) begin
            tx <= sample_data[0];
            parity_even_bit <= parity_even_bit ^ sample_data[0];
            sample_data <= {1'b0,sample_data[NUM_BITS-1:1]};
            counter_delay <= 'd0;
            if (counter_bits == NUM_BITS) begin
              ack <= 1'b0;
              state <= STATE_PARITY;
              case (PARITY)
                4 : tx <= 1'b0; // SPACE
                3 : tx <= 1'b1; // MARK
                2 : tx <= parity_even_bit; // EVEN
                1 : tx <= ~parity_even_bit; // ODD
                default : tx <= 1'b1; // NONE - stop bit 1
              endcase
              counter_bits <= 'd1;
            end else begin
              counter_bits <= counter_bits + 1;
            end
          end else begin
            counter_delay <= counter_delay + 1;            
          end
        end
        STATE_PARITY : begin
          if (PARITY == 0) begin
            tx <= 1'b1; //stop bit
            state <= STATE_STOP_BITS;
          end
          else begin
            // wait delay for parity bit
            if (counter_delay == NUM_CYCLES) begin
              tx <= 1'b1; //stop bit
              state <= STATE_STOP_BITS;
              counter_delay <= 'd0;
            end else begin
              counter_delay <= counter_delay + 1;
            end
          end
        end
        STATE_STOP_BITS : begin
          if (counter_delay == NUM_CYCLES) begin
            counter_delay <= 'd0;
            if (counter_bits == STOP_BITS) begin
              state <= STATE_IDLE;
              counter_bits <= 'd1;
            end else begin
              counter_bits <= counter_bits + 1;
            end
          end else begin
            counter_delay <= counter_delay + 1;
          end
        end
        default : 
          begin /** IDLE State */
            counter_bits <= 'd1;
            counter_delay <= 'd0;
            tx <= 1'b1;
            ack <= 1'b0;
            if (req == 1'b1) begin /** req to send data */
              state <= STATE_START_BIT;
              tx <= 1'b0;
              ack <= 1'b1;
              sample_data <= data; /** store data */
            end
        end
      endcase
    end
  end

endmodule
