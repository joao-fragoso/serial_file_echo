`timescale 1ps/1ps

/** An interface for creating clock signal
*/
interface clk_if #(
    /** PERIOD clk Frequency */
    parameter CLK_FREQ = 100_000_000
  )
  (
    /** clock output signal */
    output reg clk
  );

  localparam PERIOD = (64'd1_000_000_000_000 / CLK_FREQ);
  
  /** clock state signal */
  logic clock_enabled;
  /** main process of clock 
  * Clock is running if clock_enable is 1
  * use start() and stop() task for control clock
  */
  always begin
    clk = 0;
    wait(clock_enabled)
    while(clock_enabled) begin
      #(PERIOD/2);
      clk=1;
      #(PERIOD/2);
      clk=0;
    end
  end
  /** start clock after a half-period time */
  task start();
    clock_enabled = 1;
  endtask
  /** stops clock at end of clock cycle(next failing edge) */ 
  task stop();
    clock_enabled = 0;
  endtask

  task wait_cycles(input int n);
    repeat(n)
      @(posedge clk) #1;
  endtask
  
endinterface //clk_if
