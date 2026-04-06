`timescale 1ns/1ns
`include "project.v"
module tb_digital_clock;

reg clk;
reg reset;

wire [6:0] seg;
wire [5:0] an;

// Instantiate your top module
finaldisplay uut (
    .clk(clk),
    .reset(reset),
    .seg(seg),
    .an(an)
);

// Clock generation (10ns period → 100 MHz)
always #5 clk = ~clk;

initial begin
    // Initialize
    $dumpfile("finaldisplay.vcd");
    $dumpvars(0, tb_digital_clock);


    $monitor("Time=%0t clk=%b reset=%b seg=%7b an=%6b",
              $time, clk, reset, seg, an);
    clk = 0;
    reset = 1;

    // Apply reset
    #20;
    reset = 0;

    // Run simulation
      // run for some time
    #5000;
    $finish;
end

endmodule