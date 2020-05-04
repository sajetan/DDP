`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 08/22/2018 10:43:00 AM
// Design Name:
// Module Name: tb_mpadder
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_warmup2_mpadder();

    // Define internal regs and wires
    reg          clk;
    reg          reset;
    reg          instart;
    reg  [513:0] inA;
    reg  [513:0] inB;
    wire [514:0] outC;
    wire         outdone;

    warmup2_mpadder_answer dut(
        clk,
        reset,
        instart,
        inA,
        inB,
        outC,
        outdone);

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    initial begin

        reset <= 1'b1;
        inA   <= 514'h0;
        inB   <= 514'h0;

        #`RESET_TIME

        reset <= 1'b0;

        #`CLK_PERIOD;


        inA     <= 514'h2b18d6f6c5638662685a263c655a8b01988598ac7402c67456aa1dcaf67a06aa8b247a4740916104c8993f6e8a726a0bbf6fa4f8c463ac4cffc962ca924872887;
        inB     <= 514'h2265f756805dae91b4090d2f1ce7eb23aedea6273b5f3799fecdf2aff3e9bd1f1baca8ce4935605379aebe0a1a7a800f5bf5c1b236766765bf51e4f0d9290a798;
        instart <= 1'b1;
        #`CLK_PERIOD;
        instart <= 1'b0;

    end

endmodule
