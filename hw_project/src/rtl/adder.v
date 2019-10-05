`timescale 1ns / 1ps

module mpadder(
    input  wire         clk,
    input  wire         resetn,
    input  wire         start,
    input  wire         subtract,
    input  wire [513:0] in_a,
    input  wire [513:0] in_b,
    output reg  [514:0] result,
    output wire         done
    );

    always @(posedge(clk))
        result = in_a + in_b;
    
    assign done = 1'b1;

endmodule