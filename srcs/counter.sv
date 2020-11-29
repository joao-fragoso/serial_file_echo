module counter #(
    parameter MODULE = 10,
    parameter WIDTH = 4
  )
  (
    input rst_n,
    input clk,
    input inc,
    input dec,
    output reg [WIDTH-1:0] count,
    output reg inc_o,
    output reg dec_o
  );

  always @(posedge clk) begin
    if (~rst_n) begin
      count <= 'd0;
    end else begin
      if (inc) begin
        if (count == (MODULE-1)) begin
          count <= 'd0;
        end else begin
          count <= count + 1;
        end
      end else if (dec) begin
        if (count == 'd0) begin
          count <= MODULE-1;
        end else begin
          count <= count - 1;
        end
      end
    end
  end

  assign inc_o = (inc && (count==(MODULE-1))) ? 1'b1 : 1'b0;
  assign dec_o = (dec && (count=='d0)) ? 1'b1 : 1'b0;
  
endmodule // counter