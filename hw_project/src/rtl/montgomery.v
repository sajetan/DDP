`timescale 1ns / 1ps

module montgomery_tst(
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
    
    //reg [513:0] C,A,HTM, C_tmp; //HTM >> HoYa,Tejas,Mo
    reg [513:0] HTM; //HTM >> HoYa,Tejas,Mo
    reg [513:0] HTM2;
    reg [9:0] ctr;  //counter
    reg[1:0] HTM_signal;
    
    reg regC_shift,D,ctr_dec; //D for done
    
     // mux  B & M
                reg           mux_sel_BM;
                wire [513:0] mux_Out_BM;
                assign mux_Out_BM = mux_sel_BM ? in_m : in_b;
           
                assign adder_in_b = mux_Out_BM;    
   
    
    // reg C
        reg          regC_en;
        wire [513:0] regC_D;
        reg  [513:0] regC_Q;
        always @(posedge clk)
        begin
            if(rst)             regC_Q <= 514'd0; 
            else if (regC_en && regC_shift == 0)   regC_Q <= regC_D;
            else if (regC_en && regC_shift) regC_Q <= regC_D >> 1;
        end
        
        assign adder_in_a = regC_Q;
        
        
        // mux  C & adder_result
         reg           mux_sel_C;
         wire [513:0] mux_Out_C;
         assign mux_Out_C = mux_sel_C ? regC_Q : adder_result;
        
         assign regC_D = mux_Out_C;        

        
        
        // reg A
        reg          regA_shift;
        reg          regA_en;
        reg  [513:0] regA;
            always @(posedge clk)
            begin
                if(rst)             regA <= 514'd0;
                else if (regA_en && regA_shift == 0)   regA <= in_a;
                else if (regA_en && regA_shift) regA <= regA >> 1;
            end          
    
        
         
     //Instantiate an Adder
    
       
        CLA dut (
        .clk      (clk     ),
        .rstn   (resetn  ),
        .start    (adder_start   ),
        .subtract (adder_subtract),
        .A     (adder_in_a    ),
        .B     (adder_in_b    ),
        .result   (adder_result  ),
        .done     (adder_done    ));
        
        
        
        
        always @ (posedge clk)
        begin
                if (rst == 1) ctr <= 10'd512;
                if (ctr_dec == 1) ctr <= ctr-1;
                HTM2 <= adder_result;
                            if (HTM_signal == 2'b00) HTM <= 514'b0;
                else if (HTM_signal == 2'b01) HTM <= regC_Q;
                else if (HTM_signal ==2'b10 ) HTM <= HTM ;
                else HTM <= 514'b0;
                
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

                                mux_sel_BM <= 1'b0;   // mux_out = in_b
                                regC_shift <= 1'b0;
                                regC_en <= 1'b0;
                                regA_shift <= 1'b0;
                                regA_en <= 1;
                                ctr_dec <= 1'b0;
                                D  <= 1'b0;
                                adder_start <= 1'b0;
                                adder_subtract <= 1'b0;
                                HTM_signal <= 2'b00;
                                mux_sel_C <=1;
                          end
                     
                     4'd1: begin
                                if (ctr == 0) begin
                                                //nextstate = 4'd7;
                                                ctr_dec <= 0;
                                                //HTM <= 514'd0;
                                                HTM_signal <= 2'b00;
                                                D  <= 1'b0;
                                                regC_shift <= 1'b0;
                                                regC_en <= 1'b1;
                                                regA_shift <= 1'b0;
                                                regA_en <= 0;
                                                adder_start <= 1'b0;
                                                adder_subtract <= 1'b0;
                                                mux_sel_BM <= 1'b1;
                                                mux_sel_C <=1;
                                                //HTM <= C;
                                                //HTM2 <= 517'd0;
                                              end  
                                else begin
                                            if (regA[0] == 0) begin
                                                                 mux_sel_C <=1;
                                                                 regC_en <= 1;
                                                                 regC_shift <= 0;
                                                                 regA_shift <=0;
                                                                 regA_en <=0;
                                                                 ctr_dec <= 0;
                                                                 //HTM <= 514'd0;
                                                                 HTM_signal <= 2'b00;
                                                                 D  <= 1'b0;
                                                                 adder_start <= 1'b0;
                                                                 adder_subtract <= 1'b0;
                                                                 mux_sel_BM <= 1'b0;
                                                              end   
                                            else
                                                begin
                                                    adder_start <= 1;
                                                    adder_subtract <= 0;
                                                    mux_sel_BM <= 0;  // to select B
                                                    mux_sel_C <= 0;
                                                    regC_en <= 1;
                                                    regC_shift <=0;
                                                    regA_shift <=0;
                                                    regA_en <=0;
                                                    ctr_dec <= 0;
                                                    //HTM <= 514'd0;
                                                    HTM_signal <= 2'b00;
                                                    D  <= 1'b0;
                                                end    
                                end
                            end

                    4'd2 : begin
                                 adder_start <= 0;
                                 adder_subtract <= 1'b0;
                                 mux_sel_C <= 0;
                                 regC_en <= 1;
                                 regC_shift <=0;
                                 regA_shift <=0;
                                 ctr_dec <= 0;
                                 //HTM <= 514'd0;
                                 HTM_signal <= 2'b00;
                                 D  <= 1'b0;
                                 regA_en <= 0;
                                 mux_sel_BM <= 1'b0;
//                                 C <= adder_result;
                           end     
                           
                    4'd3: begin 
                                if (regC_Q[0] == 1) 
                                  begin
                                                adder_start <= 1;
                                                adder_subtract <=0;
                                                mux_sel_BM <= 1;  // to select M
                                                mux_sel_C <= 1;
                                                regC_en <= 1;
                                                regC_shift <=0;
                                                regA_shift <=0;
                                                ctr_dec <= 0;
                                                //HTM <= 514'd0;
                                                HTM_signal <= 2'b00;
                                                D  <= 1'b0;
                                                regA_en <= 0;
                                   end
                                   
                                else begin 
                                        adder_start <= 0;
                                        adder_subtract <=0;
                                        //HTM <= 514'd0;
                                        HTM_signal <= 2'b00;
                                        ctr_dec <= 1'b0;
                                        D  <= 1'b0;
                                        regC_shift <= 1'b1;
                                        regC_en <= 1'b1;
                                        mux_sel_C <=1;
                                        regA_shift <= 1'b0;
                                        regA_en <= 0;
                                        mux_sel_BM <= 1'b0;
                                        //regC_shift <= 1;
                                        //regC_en <= 1;
                                        //mux_sel_C <= 1;
                                        //regA_shift <=0;
                                        //ctr_dec <= 0;
                                     end   
                                                
                           end
                    4'd4: begin
                                adder_start <= 0;
                                adder_subtract <= 1'b0;
                                mux_sel_C <= 0;
                                regC_en <= 1;
                                regC_shift <=1;
                                regA_shift <=0;
                                ctr_dec <= 0;
                                //HTM <= 514'd0;
                                HTM_signal <= 2'b00;
                                D  <= 1'b0;
                                regA_en <= 0;
                                mux_sel_BM <= 1'b1;
//                                C <= adder_result;
                          end
                     4'd5: begin
                                     regC_shift <= 1'b0;
                                     regC_en <= 1;
                                     mux_sel_C <= 1;  
                                     regA_shift <=1;   
                                     ctr_dec <= 1;     
                                     //HTM <= 514'd0;
                                     HTM_signal <= 2'b00;  
                                     D  <= 1'b0;  
                                     regA_en <= 1;  
                                     adder_start <= 1'b0;  
                                     adder_subtract <= 1'b0;   
                                     mux_sel_BM <= 1'b0;                
                                end 

                     4'd6: begin
                            adder_start <= 1;
                            adder_subtract <=1;
                            mux_sel_BM <= 1;  // to select M
                            ctr_dec <= 0;
                            //HTM <= regC_Q;
                            HTM_signal <= 2'b01;
                            D  <= 1'b0;
                            regC_shift <= 1'b0;
                            regC_en <= 1'b1;
                            mux_sel_C <= 1;
                            regA_shift <= 1'b0;
                            regA_en <= 0;
                           end
                                  
                     4'd7: begin
                            adder_start <= 0;
                            adder_subtract <= 1'b1;
                            //HTM2 <= adder_result;
                            mux_sel_C <= 0;
                            regC_en <= 1;
                            regC_shift <= 0;
                            ctr_dec <= 0;
                            //HTM <= HTM;
                            HTM_signal <= 2'b10;
                            D  <= 1'b0;
                            regA_shift <= 1'b0;
                            regA_en <= 0;
                            mux_sel_BM <= 1'b1;
                            //C    <= adder_result; 
                           end
                           
                    4'd8:  begin  
                            ctr_dec <= 1'b0;      
                            if (HTM2[513] == 0) begin            // if (C > M)  
                               //HTM <= regC_Q ;
                               HTM_signal <= 2'b01; 
                               D  <= 1'b0;
                               regC_shift <= 1'b0;
                               regC_en <= 1'b1;
                               mux_sel_C <= 1;
                               regA_shift <= 1'b0;
                               regA_en <= 0;
                               adder_start <= 0;
                               adder_subtract <= 1'b0;
                               mux_sel_BM <= 1'b1;
                            end
                            else begin 
                                     //HTM <= HTM ;
                                     HTM_signal <= 2'b10; 
                                     D <= 1'b1;
                                     regC_shift <= 1'b0; 
                                     regC_en <= 1'b1;
                                     mux_sel_C <= 1;
                                     regA_shift <= 1'b0;
                                     regA_en <= 0;
                                     adder_start <= 0;
                                     adder_subtract <= 1'b0;
                                     mux_sel_BM <= 1'b1;
                                 end        
                           end 
                           
                          default: begin
                                mux_sel_BM <= 1'b0;   // mux_out = in_b
                                regC_shift <= 1'b0;
                                regC_en <= 1'b0;
                                regA_shift <= 1'b0;
                                regA_en <= 1;
                                ctr_dec <= 1'b0;
                                D  <= 1'b0;
                                adder_start <= 1'b0;
                                adder_subtract <= 1'b0;
                                //HTM <= 512'd0;
                                HTM_signal <= 2'b00;
                                mux_sel_C <=1;
                            end
                     

        
                endcase
            end
        
            // next_state logic description
        
            always @(*)
            begin
                case(state)
                    4'd0: begin
                        if(start==1)
                            nextstate <= 4'd1;
                        else
                            nextstate <= 4'd0;
                        end
                    4'd1   : begin
                                if (ctr == 0) nextstate <= 4'd6;
                                else begin 
                                //nextstate <= 4'd1;
                                    if (regA[0] == 0) nextstate <=4'd3;
                                    else nextstate <= 4'd2;
                                end    
                             end   
                    4'd2   : begin
                            if (adder_done ==1) nextstate <= 4'd3;
                            else nextstate <= 4'd2;
                        end
                    4'd3   :  begin
                                    if (regC_Q[0] == 1) nextstate <=4'd4;
                                    else nextstate <= 4'd5;
                              end
                    4'd4   :  begin
                                    if (adder_done == 1) nextstate <= 4'd5;
                                    else nextstate <= 4'd4;
                              end    
                    4'd5   :  nextstate <= 4'd1;     
                    4'd6   :  nextstate <= 4'd7;
                    4'd7   :  begin
                                    if (adder_done ==1) nextstate <= 4'd8;
                                    else nextstate <= 4'd7;
                              end
                    4'd8   :  begin
                                    if (HTM2[513] == 0)   nextstate <= 4'd6;
                                    else nextstate <= 4'd0;
                              end
                                    
                    default: nextstate <= 4'd0;
                endcase
            end
        

 assign result = HTM [511:0];
 assign done = D ;
          
    
    
    
    // 2. Use the Adder to implement the Montgomery multiplier in hardware.
    // 3. Use tb_montgomery.v to simulate your design.
    

     
   
    
    
//     This always block was added to ensure the tool doesn't trim away the montgomery module.
//     Feel free to remove this block
//    reg [511:0] r_result;
//    always @(posedge(clk))
//    begin
//        r_result <= {512{1'b1}};
//    end
//    assign result = r_result;

//    assign done = 1;
endmodule