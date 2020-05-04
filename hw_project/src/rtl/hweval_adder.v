`timescale 1ns / 1ps

module hweval_adder (
    input   clk     ,
    input   resetn  ,
    output  data_ok );

    reg          start;
    reg          subtract;
    reg  [513:0] in_a;
    reg  [513:0] in_b;
    wire [514:0] result;
    wire         done;
       
    // Instantiate the adder    
    mpadder dut (
        clk,
        resetn,
        start,
        subtract,
        in_a,
        in_b,
        result,
        done);

    reg [1:0] state;

    always @(posedge(clk)) begin
    
        if (!resetn) begin
            in_a     <= 514'b1;
            in_b     <= 514'b1;
            subtract <= 1'b0;
                    
            start    <= 1'b0;           
            
            state    <= 2'b00;
        end else begin
    
            if (state == 2'b00) begin
                in_a     <= in_a;
                in_b     <= in_b;
                subtract <= subtract;
                
                start    <= 1'b1;            
                
                state    <= 2'b01;        
            
            end else if(state == 2'b01) begin
                in_a     <= in_a;
                in_b     <= in_b;
                subtract <= subtract;
                        
                start    <= 1'b0;           
                
                state    <= done ? 2'b10 : 2'b01;
            end
            
            else begin
                in_a     <= in_b ^ result[513:0];
                in_b     <= result[513:0];
                subtract <= result[514];
                                    
                start    <= 1'b0;
                            
                state    <= 2'b00;
            end
        end
    end    
    
    assign data_ok = done & result[514];
    
endmodule