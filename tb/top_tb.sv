`include "src/top.sv"
`timescale 1ns/1ps         // Set tick to 1ns. Set sim resolution to 1ps.

/**
 * Note:
 *  The TB below is only an example of a testbench written in SV.
 *  Adapt this for your lab assignments as you see fit.
 *  An example clk signal has been added to show what a signal decl and usage looks like.
 *     You are welcome to delete the clk signal if it's not needed.
 *     For instance, purely combinational circuits do not need clks.
 *     So for labs without sequential elements, you can remove them.
 */

module top_tb;

logic clk_tb;
logic bt1_tb;
logic led_r_tb;
logic slow_clk_tb;

/** declare module(s) below */
top dut                    // declare an inst of top called "dut" (device under test)
(
    .clk(clk_tb),
    .bt1(bt1_tb),
    .led_r(led_r_tb)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk_tb = ~clk_tb;

initial begin
    $dumpfile("build/top.vcd"); // intermediate file for waveform generation
    $dumpvars(0, top_tb);       // capture all signals under top_tb
end

initial begin
    clk_tb = 1;
    slow_clk_tb = 1;
    bt1_tb = 1;

    #(CLK_PERIOD*5);

    bt1_tb = 0;
    #(CLK_PERIOD*5);

    bt1_tb = 1;
    #(CLK_PERIOD*5);

    bt1_tb = 0;
    #(CLK_PERIOD*5);

    bt1_tb = 1;
    #(CLK_PERIOD*5);




    $finish;            // end simulation, otherwise it runs indefinitely
end

endmodule
