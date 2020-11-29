module file_handler #(
  parameter NUM_BITS = 8,
  parameter MAX_FILE_SIZE = 2048
)
(
  input                     clk,
  input                     rst_n,
  (* mark_debug = "true" *) input                     new_data,
  (* mark_debug = "true" *) input      [NUM_BITS-1:0] rx_data,
  (* mark_debug = "true" *) output reg                req,
  input                     ack,
  (* mark_debug = "true" *) output reg [NUM_BITS-1:0] tx_data,
  output reg         [31:0] bcd_counter,
  output reg          [7:0] mask_n
);


localparam [NUM_BITS-1:0] SOT       = 'd2;  // START OF TEXT
localparam [NUM_BITS-1:0] EOT       = 'd3;  // END OF TEXT
localparam                ADDR_BITS = $clog2(MAX_FILE_SIZE);

reg [ADDR_BITS+2:0] file_size; //= 'd0; // size of last file received
reg [ADDR_BITS+2:0] pointer;   //= 'd0;
reg [NUM_BITS-1:0]  data;      //= 'd0;
reg                 we;        //= 1'b0;
wire [NUM_BITS-1:0] rdata;

//localparam STATE_IDLE       = 4'd0;
//localparam STATE_RECEIVING  = 4'd1;
//localparam STATE_STORE_DATA = 4'd2;
//localparam STATE_START_SEND = 4'd3;
//localparam STATE_SEND_SOT   = 4'd4;
//localparam STATE_REQ_SEND   = 4'd5;
//localparam STATE_WAIT_ACK_1 = 4'd6;
//localparam STATE_WAIT_ACK_0 = 4'd7;
//localparam STATE_SEND_EOT   = 4'd8;

typedef enum  { 
  STATE_IDLE,
  STATE_RECEIVING,
  STATE_STORE_DATA,
  STATE_START_SEND,
  STATE_SEND_SOT,
  STATE_REQ_SEND,
  STATE_WAIT_ACK_1,
  STATE_WAIT_ACK_0,
  STATE_SEND_EOT  
} state_t;

(* mark_debug = "true" *) state_t state; // = STATE_IDLE;
reg  inc_bcd[3:0];
reg  dec_bcd[3:0];

xpm_memory_spram # (
// Common module parameters
.MEMORY_SIZE (MAX_FILE_SIZE*NUM_BITS), //positive integer
.MEMORY_PRIMITIVE ("auto"), //string; "auto", "distributed", "block" or "ultra";
.MEMORY_INIT_FILE ("none"), //string; "none" or "<filename>.mem"
.MEMORY_INIT_PARAM ("" ), //string;
.USE_MEM_INIT (1), //integer; 0,1
.WAKEUP_TIME ("disable_sleep"),//string; "disable_sleep" or "use_sleep_pin"
.MESSAGE_CONTROL (0), //integer; 0,1
// Port A module parameters
.WRITE_DATA_WIDTH_A (NUM_BITS), //positive integer
.READ_DATA_WIDTH_A (NUM_BITS), //positive integer
.BYTE_WRITE_WIDTH_A (NUM_BITS), //integer; 8, 9, or WRITE_DATA_WIDTH_A value
.ADDR_WIDTH_A (ADDR_BITS), //positive integer
.READ_RESET_VALUE_A ("0"), //string
.READ_LATENCY_A (1), //non-negative integer
.WRITE_MODE_A ("read_first") //string; "write_first", "read_first", "no_change"
) xpm_memory_spram_inst (
// Common module ports
.sleep (1'b0),
// Port A module ports
.clka (clk),
.rsta (~rst_n),
.ena (1'b1),
.regcea (1'b1),
.wea (we),
.addra (pointer[ADDR_BITS-1:0]),
.dina (data),
.injectsbiterra (1'b0), //do not change
.injectdbiterra (1'b0), //do not change
.douta (rdata),
.sbiterra (), //do not change
.dbiterra () //do not change
);

counter    c1 (.rst_n(rst_n), .clk(clk), .inc(inc_bcd[0]), .dec(dec_bcd[0]),   .count(bcd_counter[3:0]), .inc_o(inc_bcd[1]), .dec_o(dec_bcd[1]));
counter   c10 (.rst_n(rst_n), .clk(clk), .inc(inc_bcd[1]), .dec(dec_bcd[1]),   .count(bcd_counter[7:4]), .inc_o(inc_bcd[2]), .dec_o(dec_bcd[2]));
counter  c100 (.rst_n(rst_n), .clk(clk), .inc(inc_bcd[2]), .dec(dec_bcd[2]),  .count(bcd_counter[11:8]), .inc_o(inc_bcd[3]), .dec_o(dec_bcd[3]));
counter c1000 (.rst_n(rst_n), .clk(clk), .inc(inc_bcd[3]), .dec(dec_bcd[3]), .count(bcd_counter[15:12]), .inc_o(),           .dec_o());

  assign bcd_counter[31:16] = 'd0;
  assign mask_n =  8'b1111_0000;
  
  always @(posedge clk) begin
    if (rst_n == 1'b0) begin
      state <= STATE_IDLE;
      pointer <= 'd0;
      file_size <= 'd0;
      inc_bcd[0] <= 1'b0;
      dec_bcd[0] <= 1'b0;
      we <= 1'b0;
    end else begin
      case (state)
      STATE_RECEIVING : begin
        if ((pointer == MAX_FILE_SIZE) ||
            (new_data && rx_data == EOT)) begin
          state <= STATE_SEND_SOT;
          file_size <= pointer;
          pointer <= 'd0;
        end else begin
          if (new_data) begin
            data <= rx_data;
            we <= 1'b1;
            inc_bcd[0] <= 1'b1;
            state <= STATE_STORE_DATA;
          end
        end
      end
      STATE_STORE_DATA : begin
        pointer <= pointer + 1;
        we <= 1'b0;
        inc_bcd[0] <= 1'b0;
        state <= STATE_RECEIVING;
      end
      STATE_SEND_SOT : begin
        if (~ack) begin
          req <= 1'b1;
          tx_data <= SOT;
          state <= STATE_WAIT_ACK_1;
        end
      end
      STATE_REQ_SEND : begin
        if (pointer < file_size) begin
          req <= 1'b1;
          tx_data <= rdata;
          pointer <= pointer + 1;
          dec_bcd[0] <= 1'b1;
          state <= STATE_WAIT_ACK_1;
        end else begin
          req <= 1'b1;
          tx_data <= EOT;
          state <= STATE_SEND_EOT;
        end
      end
      STATE_WAIT_ACK_1 : begin
        dec_bcd[0] <= 1'b0;
        if (ack) begin
          state <= STATE_WAIT_ACK_0;
          req <= 1'b0;          
        end
      end
      STATE_WAIT_ACK_0 : begin
        if (~ack) begin
          state <= STATE_REQ_SEND;
        end
      end
      STATE_SEND_EOT : begin
        if (ack) begin // wait ack
          req <= 1'b0;
          state <= STATE_IDLE;
        end
      end
      default : begin // STATE_IDLE
        pointer <= 'd0;
        we <= 1'b0;
        if (new_data && rx_data == SOT )
          state <= STATE_RECEIVING;
      end
      endcase
    end // else rst_n
  end // always block


endmodule
