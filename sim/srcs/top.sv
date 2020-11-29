`timescale 1ps/1ps
module top;
  import uvm_pkg::*;
  import project_pkg::*;

  
  wire clk;
  wire  rst_n;
  
  // interfaces instances
  clk_if #(.CLK_FREQ(project_pkg::CLK_FREQ)) _clk(.clk(clk));
  reset_if _rst(.clk(clk), .rst(rst_n));
  sfe_if #(.BAUD_RATE(project_pkg::BAUD_RATE), .PARITY(project_pkg::PARITY), .NUM_BITS(project_pkg::NUM_BITS), .STOP_BITS(project_pkg::STOP_BITS))
    _serial(.clk(clk), .rst_n(rst_n));


  sef 
  #(
    .CLK_FREQ(project_pkg::CLK_FREQ),
    .BAUD_RATE(project_pkg::BAUD_RATE),
    .PARITY(project_pkg::PARITY),
    .NUM_BITS(project_pkg::NUM_BITS),
    .STOP_BITS(project_pkg::STOP_BITS),
    .MAX_FILE_SIZE(project_pkg::MAX_FILE_SIZE)
  )
  dut
  (
    .clk(clk),
    .rst_n(rst_n),
    .rx(_serial.rx),
    .tx(_serial.tx),
    .an(_serial.an),
    .seg(_serial.seg)
  );

  //seting up and run test
  initial begin
    _rst.set_active_low();
    uvm_config_db #(virtual reset_if)::set(null, "uvm_test_top", "reset_vif", _rst);
    uvm_config_db #(virtual clk_if #(.CLK_FREQ(project_pkg::CLK_FREQ)))::set(null, "uvm_test_top", "clk_vif", _clk);
    uvm_config_db #(virtual sfe_if #(.BAUD_RATE(project_pkg::BAUD_RATE), .PARITY(project_pkg::PARITY), .NUM_BITS(project_pkg::NUM_BITS), .STOP_BITS(project_pkg::STOP_BITS)))::set(null, "uvm_test_top", "serial_vif", _serial);
    run_test("serial_test");
  end

endmodule : top