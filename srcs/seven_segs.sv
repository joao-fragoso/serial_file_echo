module seven_seg #(
  parameter CLK_FREQ = 100_000_000 /**< Clock frequency */
)
(
  input             clk,
  input      [31:0] value,
  input       [7:0] point,
  input       [7:0] mask_n,
  output reg  [7:0] anode,
  output reg  [7:0] segment = 'h00
);

localparam NUM_CYCLES_1_MS = CLK_FREQ / 1_000;
localparam CNT_SIZE = $clog2(NUM_CYCLES_1_MS);

reg [CNT_SIZE-1:0] sample_delay = 'd0;
reg shift_display;
reg [3:0] value2display;
reg [7:0] _anode = 'hFE;

assign anode = _anode | mask_n;

always @(posedge clk)
  sample_delay <= sample_delay + 1;

assign shift_display = &(sample_delay); // 1 with all ones

always @(posedge clk) begin
  if (shift_display) begin
    _anode <= {_anode[6:0], _anode[7]};  // rotate left
  end
end

always_comb 
begin
  (* full_case *)
  casez (_anode)
    8'b0???_???? : begin
      value2display = value[31:28];
      segment[0] = point[7];
    end
    8'b?0??_???? : begin
      value2display = value[27:24];
      segment[0] = point[6];
    end
    8'b??0?_???? : begin
      value2display = value[23:20];
      segment[0] = point[5];
    end
    8'b???0_???? : begin
      value2display = value[19:16];
      segment[0] = point[4];
    end
    8'b????_0??? : begin
      value2display = value[15:12];
      segment[0] = point[3];
    end
    8'b????_?0?? : begin
      value2display = value[11:8];
      segment[0] = point[2];
    end
    8'b????_??0? : begin
      value2display = value[7:4];
      segment[0] = point[1];
    end
    8'b????_???0 : begin
      value2display = value[3:0];
      segment[0] = point[0];
    end
  endcase
end


always_comb begin : hex2seg
  case (value2display)
       4'hF : segment[7:1] = 7'b0111000;
       4'hE : segment[7:1] = 7'b0110000;
       4'hd : segment[7:1] = 7'b1000010;
       4'hC : segment[7:1] = 7'b0110001;
       4'hb : segment[7:1] = 7'b1100000;
       4'hA : segment[7:1] = 7'b0001000;
       4'h9 : segment[7:1] = 7'b0000100;
       4'h8 : segment[7:1] = 7'b0000000;
       4'h7 : segment[7:1] = 7'b0001111;
       4'h6 : segment[7:1] = 7'b0100000;
       4'h5 : segment[7:1] = 7'b0100100;
       4'h4 : segment[7:1] = 7'b1001100;
       4'h3 : segment[7:1] = 7'b0000110;
       4'h2 : segment[7:1] = 7'b0010010;
       4'h1 : segment[7:1] = 7'b1001111;
    default : segment[7:1] = 7'b0000001;
  endcase

end : hex2seg

endmodule : seven_seg
