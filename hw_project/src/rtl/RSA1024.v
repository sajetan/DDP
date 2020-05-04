`timescale 1ns / 1ps

module RSA1024(
input clk,resetn,start,
input [1023:0] Cipher,
input [511:0] dp,
input [511:0] dq,
input [511:0] p,
input [511:0] q,
input [511:0] R2p,
input [511:0] Rp,
input [511:0] R2q,
input [511:0] Rq,
output [1023:0] result,
output done
    );


wire [511:0] result_exp_p,result_exp_q;
wire done_exp_p,done_exp_q;

//Instantiating Exponentiation  module (P)
exp expnentiation_P ( .clk    (clk    ),
.resetn (resetn ),
.start  (start  ),
.Cipher (Cipher),
.E   (dp  ),
.m   (p  ),
.R2   (R2p  ),
.R   (Rp  ),
.result (result_exp_p ),
.done   (done_exp_p   ));

//Instantiating Exponentiation module (q)
exp expnentiation( .clk    (clk    ),
.resetn (resetn ),
.start  (start  ),
.Cipher (Cipher),
.E   (dq  ),
.m   (q  ),
.R2   (R2q  ),
.R   (Rq  ),
.result (result_exp_q ),
.done   (done_exp_q   ));  

  

assign done = done_exp_p && done_exp_q;
assign result = {result_exp_p,result_exp_q}; 
endmodule
