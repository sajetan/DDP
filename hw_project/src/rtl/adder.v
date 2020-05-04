`timescale 1ns / 1ps


module ADD66(
input wire [65:0] in_a,in_b,
input wire carry_in,
output [65:0] SUM,
output carry_out
);
assign {carry_out,SUM[65:0]} = in_a + in_b + carry_in;
endmodule 


module ADD64(
input wire [63:0] in_a,in_b,
input wire carry_in,
output [63:0] SUM,
output carry_out
);
assign {carry_out,SUM[63:0]} = in_a + in_b + carry_in;
endmodule 


module Smux(
input wire[63:0] a,b,
input wire sel,
output wire [63:0] C 
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

 
module mpadder
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
wire  carryA1,carryA2,carryA3,carryA4,carryA5,carryA6,carryA7,carryA8,carryB2,carryB3,carryB4,carryB5,carryB6,carryB7,carryB8,carryC1,carryC2,carryC3,carryC4,carryC5,carryC6,carryC7;

ADD66 A1 (in_a[65:0],in_b[65:0],subtract,SUM1[65:0],carryA1);
ADD64 A2 (in_a[129:66],in_b[129:66],1'b0,SUM1[129:66],carryA2);
ADD64 A3 (in_a[193:130],in_b[193:130],1'b0,SUM1[193:130],carryA3);
ADD64 A4 (in_a[257:194],in_b[257:194],1'b0,SUM1[257:194],carryA4);
ADD64 A5 (in_a[321:258],in_b[321:258],1'b0,SUM1[321:258],carryA5);
ADD64 A6 (in_a[385:322],in_b[385:322],1'b0,SUM1[385:322],carryA6);
ADD64 A7 (in_a[449:386],in_b[449:386],1'b0,SUM1[449:386],carryA7);
ADD64 A8 (in_a[513:450],in_b[513:450],1'b0,SUM1[513:450],carryA8);

ADD64 B2 (in_a[129:66],in_b[129:66],1'b1,SUM2[129:66],carryB2);
ADD64 B3 (in_a[193:130],in_b[193:130],1'b1,SUM2[193:130],carryB3);
ADD64 B4 (in_a[257:194],in_b[257:194],1'b1,SUM2[257:194],carryB4);
ADD64 B5 (in_a[321:258],in_b[321:258],1'b1,SUM2[321:258],carryB5);
ADD64 B6 (in_a[385:322],in_b[385:322],1'b1,SUM2[385:322],carryB6);
ADD64 B7 (in_a[449:386],in_b[449:386],1'b1,SUM2[449:386],carryB7);
ADD64 B8 (in_a[513:450],in_b[513:450],1'b1,SUM2[513:450],carryB8);

Smux M1 (SUM1[129:66],SUM2[129:66],carryA1,result[129:66]);
Cmux CM1 (carryA2,carryB2,carryA1,carryC1);
Smux M2 (SUM1[193:130],SUM2[193:130],carryC1,result[193:130]);
Cmux CM2 (carryA3,carryB3,carryC1,carryC2);
Smux M3 (SUM1[257:194],SUM2[257:194],carryC2,result[257:194]);
Cmux CM3 (carryA4,carryB4,carryC2,carryC3);

Smux M4 (SUM1[321:258],SUM2[321:258],carryC3,result[321:258]);
Cmux CM4 (carryA5,carryB5,carryC3,carryC4);
Smux M5 (SUM1[385:322],SUM2[385:322],carryC4,result[385:322]);
Cmux CM5 (carryA6,carryB6,carryC4,carryC5);
Smux M6 (SUM1[449:386],SUM2[449:386],carryC5,result[449:386]);
Cmux CM6 (carryA7,carryB7,carryC5,carryC6);

Smux M7 (SUM1[513:450],SUM2[513:450],carryC6,result[513:450]);
Cmux CM7 (carryA8,carryB8,carryC6,carryC7);


//Smux M1 (SUM1[257:129],SUM2[257:129],carryA1,result[257:129]);
//Cmux CM1 (carryA2,carryB2,carryA1,carryC1);
//Smux M2 (SUM1[386:258],SUM2[386:258],carryC1,result[386:258]);
//Cmux CM2 (carryA3,carryB3,carryC1,carryC2);
//Smux M3 (SUM1[513:387],SUM2[513:387],carryC2,result[513:387]);
//Cmux CM3 (carryA4,carryB4,carryC2,carryC3);


assign result[514] = carryC7^ subtract;
assign SUM2[65:0] = 0;

assign result[65:0] = SUM1[65:0];

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

