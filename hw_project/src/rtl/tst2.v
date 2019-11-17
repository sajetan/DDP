`timescale 1ns / 1ps

module ADD128(
input wire [128:0] in_a,in_b,
input wire carry_in,
output [128:0] SUM,
output carry_out
);

assign {carry_out,SUM[128:0]} = in_a + in_b + carry_in;

endmodule 


module Smux(
input wire[128:0] a,b,
input wire sel,
output wire [128:0] C 
);

assign C = sel? b:a; 
endmodule

module Cmux(
input wire a,b,
input wire sel,
output wire  C 
);

assign C = sel? b:a; 
endmodule

 
module CLA
(
  input  wire           clk,
    input  wire         rstn,
    input  wire         start,
    input  wire         subtract,
    input  wire [513:0] A,
    input  wire [513:0] B,
    output wire [514:0] result, 
    output wire         done
);
    // mux selction for B or ~B
    
wire [513:0] muxB;
assign muxB = (subtract == 0) ? B : ~B ;


wire [513:0] SUM1,SUM2;
wire carryA1,carryA2,carryA3,carryA4,carryB2,carryB3,carryB4,carryC1,carryC2,carryC3;
ADD128 A1 (in_a[128:0],in_b[128:0],subtract,SUM1[128:0],carryA1);
ADD128 A2 (in_a[257:129],in_b[257:129],1'b0,SUM1[257:129],carryA2);
ADD128 A3 (in_a[386:258],in_b[386:258],1'b0,SUM1[386:258],carryA3);
ADD128 A4 (in_a[513:387],in_b[513:387],1'b0,SUM1[513:387],carryA4);
ADD128 B2 (in_a[257:129],in_b[257:129],1'b1,SUM2[257:129],carryB2);
ADD128 B3 (in_a[386:258],in_b[386:258],1'b1,SUM2[386:258],carryB3);
ADD128 B4 (in_a[513:387],in_b[513:387],1'b1,SUM2[513:387],carryB4);
Smux M1 (SUM1[257:129],SUM2[257:129],carryA1,result[257:129]);
Cmux CM1 (carryA2,carryB2,carryA1,carryC1);
Smux M2 (SUM1[386:258],SUM2[386:258],carryC1,result[386:258]);
Cmux CM2 (carryA3,carryB3,carryC1,carryC2);
Smux M3 (SUM1[513:387],SUM2[513:387],carryC2,result[513:387]);
Cmux CM3 (carryA4,carryB4,carryC2,carryC3);
assign result[514] = carryC3 ^ subtract;


assign result[128:0] = SUM1[128:0];

reg [513:0] in_a,in_b;
wire rst;
assign rst = ~rstn;
assign done = 1;
always @ (posedge clk)
begin
        if (rst) begin 
                    in_a <= 514'd0;
                    in_b <= 514'd0;
                 end
        else if (start) begin         
                in_a <= A;
                in_b <= muxB;
     end
           
end

endmodule
