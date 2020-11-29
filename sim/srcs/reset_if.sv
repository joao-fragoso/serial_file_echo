`timescale 1ps/1ps
interface reset_if
( input clk,
  output reg rst
);

  bit active_value = 1'b0;
/*
  function new();
    rst = active_value;
  endfunction

  function new(input bit _active_value=1'b0);
    active_value = _active_value;
    rst = _active_value;
  endfunction
*/
  function void set_active_low();
    active_value = 1'b0;
  endfunction

  function void set_active_high();
    active_value = 1'b0;
  endfunction

  task assert_reset();
    @(posedge clk) #1;
    rst = active_value;
  endtask

  task dassert_reset();
    @(posedge clk) #1;
    rst = ~active_value;
  endtask

endinterface //reset_i
