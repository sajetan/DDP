`timescale 1ns / 1ps

module montgomery(
    input          clk,
    input          resetn,
    input          start,
    input  [513:0] in_a,
    input  [513:0] in_b,
    input  [513:0] in_m,
    output [511:0] result,  
    output         done
     );
 
 
    wire rst;
    assign rst = ~resetn ;
    
    wire [513:0] adder_in_a,adder_in_b;
    reg adder_start,adder_subtract;
    wire adder_done;
    wire [514:0] adder_result;
    
    reg [513:0] C,A,HTM; //HTM >> HoYa,Tejas,Mo
    reg [516:0] HTM2;
    reg [9:0] ctr;  //counter
    
    reg shift,D; //D for done
    
    // Student tasks:
    
         // mux
             reg           mux_sel;
             wire [513:0] mux_Out;
             assign mux_Out = mux_sel ? in_m : in_b;
        
        
//        //
         assign adder_in_a = C;
         assign adder_in_b = mux_Out;
    // 1. Instantiate an Adder
    
       
        mpadder dut (
        .clk      (clk     ),
        .rstn   (resetn  ),
        .start    (adder_start   ),
        .subtract (adder_subtract),
        .A     (adder_in_a    ),
        .B     (adder_in_b    ),
        .C   (adder_result  ),
        .done     (adder_done    ));
        
        
        
        always @(posedge clk) 
        begin
                if (shift == 1'b1) begin
                     C <= C >> 1 ;
                     A <= A >> 1 ;
                     ctr <= ctr - 1'b1;   
                end 
                else begin
                    C <= C; 
                    A <= A;
                end         
        end
     // state machine registers description
        
            reg [3:0] state, nextstate;
        
            always @(posedge clk)
            begin
                if(rst)        state <= 4'd0;
                else        state <= nextstate;
            end
        
            // States definition and signals at each state
            always @(*)
            begin
                case(state)
                    
                    4'd0: begin
                                C <= 514'b0;
                                HTM <= 514'b0;
                                A <= in_a;
                                ctr <= 10'd512;
                                shift <= 1'b0;
                                D  <= 1'b0;
                          end
                     
                     4'd1: begin
                                if (ctr == 0) begin
                                                nextstate = 4'd7;
                                                HTM <= C;
                                                HTM2 <= 517'd0;
                                              end  
                                else begin
                                            if (A[0] == 0) begin
                                                    C <= C;
                                            end
                                            else begin
                                                    adder_start <= 1;
                                                    adder_subtract <= 0;
                                                    mux_sel <= 0;  // to select B
                                            end    
                                end
                            end

                    4'd2 : begin
                                 adder_start <= 0;
                                 C <= adder_result;
                           end     
                           
                    4'd3: begin 
                                if (C[0] == 1) begin
                                                adder_start <= 1;
                                                adder_subtract <=0;
                                                mux_sel <= 1;  // to select M
                                   end
                                else adder_start <= 0;
                                                
                           end
                    4'd4: begin
                                adder_start <= 0;
                                C <= adder_result;
                          end
                     4'd5: begin
                                     shift <= 1'b1;
                                end 
                     4'd6: begin
                                shift <= 1'b0;  // wait for one clk cycle waiting for division to be carried out  
                           end
                           
                     4'd7: begin
                            adder_start <= 1;
                            adder_subtract <=1;
                            mux_sel <= 1;  // to select M
                           end
                                  
                     4'd8: begin
                            adder_start <= 0;
                            HTM2 <= adder_result;
                            C    <= adder_result; 
                           end
                           
                    4'd9:  begin        
                            if (HTM2[516] == 1) begin            // if (C > M)  
                                                HTM <= C ; 
                                             end
                            else begin HTM <= HTM ; D <= 1'b1; end        
                           end 
                           
                          default: begin
                                    C <= 514'b0;
                                    HTM <= 514'b0;
                                    A <= in_a;
                                    ctr <= 10'd3;
                                    shift <= 1'b0;
                                    D  <= 1'b0;
                          end
                     

        
                endcase
            end
        
            // next_state logic description
        
            always @(*)
            begin
                case(state)
                    4'd0: begin
                        if(start)
                            nextstate <= 4'd1;
                        else
                            nextstate <= 4'd0;
                        end
                    4'd1   : begin 
                                if (A[0] == 0) nextstate <=4'd3;
                                else nextstate <= 4'd2;
                             end   
                    4'd2   : begin
                            if (adder_done ==1) nextstate = 4'd3;
                            else nextstate = 4'd2;
                        end
                    4'd3   :  begin
                                    if (C[0] == 1) nextstate <=4'd4;
                                    else nextstate <= 4'd5;
                              end
                    4'd4   :  begin
                                    if (adder_done == 1) nextstate <= 4'd5;
                                    else nextstate <= 4'd4;
                              end    
                    4'd5   :  nextstate <= 4'd6;     
                    4'd6   :  nextstate <= 4'd1; 
                    4'd7   :  nextstate <= 4'd8;
                    4'd8   :  begin
                                    if (adder_done ==1) nextstate <= 4'd9;
                                    else nextstate <= 4'd8;
                              end
                    4'd9   :  begin
                                    if (C[513] == 1)   nextstate <= 4'd7;
                                    else nextstate <= 4'd0;
                              end
                                    
                    default: nextstate <= 4'd0;
                endcase
            end
        

 assign result = HTM [511:0];
 assign done = D ;
          
    
    
    
    // 2. Use the Adder to implement the Montgomery multiplier in hardware.
    // 3. Use tb_montgomery.v to simulate your design.
    

     
   
    
    
    // This always block was added to ensure the tool doesn't trim away the montgomery module.
    // Feel free to remove this block
//    reg [511:0] r_result;
//    always @(posedge(clk))
//    begin
//        r_result <= {512{1'b1}};
//    end
//    assign result = r_result;

//    assign done = 1;
endmodule