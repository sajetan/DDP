//backup 1

`timescale 1ns / 1ps

module exp_tst( 
input clk,resetn,start,
input [1023:0] Cipher,
input [511:0] E,
input [511:0] m,
input [511:0] R2,
input [511:0] R,
output [511:0] result,
output done
    );
    
    //result = C^E mod m;
wire rst;
assign rst = ~resetn ;


wire [511:0] Ch,Cl;
assign Ch = Cipher[1023:512];
assign Cl = Cipher[511:0];

//declaration of signals   
reg mont_start;
reg mux_sel_A,mux_sel_C;  //mux for mon. inputs  
reg [1:0] mux_sel_mont_2,mux_sel_mont_1;  
wire mont_done;    
wire [511:0] mont_result;
wire [513:0] mont_in_a,mont_in_b,mont_in_m;   
reg D , regDone;// for done


// Declarations for adder
reg rstn_adder,adder_start,adder_subtract;
wire [513:0] adder_in_a,adder_in_b;
wire [514:0] adder_result;
wire adder_done;
reg  mux_sel_adder_in_a,mux_sel_adder_in_b;



reg rstn_mont;
//Instantiating montgomery module 1
montgomery montgomery_instance1(
.clk    (clk    ),
.resetn (rstn_mont ),
.start  (mont_start  ),
.in_a   (mont_in_a   ),
.in_b   (mont_in_b   ),
.in_m   (mont_in_m   ),
.result (mont_result ),
.done   (mont_done   ));

// Instantiating Adder module
mpadder dut (
.clk      (clk     ),
.rstn   (rstn_adder  ),
.start    (adder_start   ),
.subtract (adder_subtract),
.A     (adder_in_a    ),
.B     (adder_in_b    ),
.result   (adder_result  ),
.done     (adder_done    ));


//reg A        
reg          regA_en;
wire [511:0] regA_D;
reg  [511:0] regA_Q;
always @(posedge clk)
begin
    if(rst)             regA_Q <= 512'd0; 
    else if (regA_en ==1)                regA_Q <= regA_D;
    else regA_Q <= regA_Q;
end    
assign regA_D = mux_sel_A ? R : mont_result;


//reg C~        
reg          regC_en;
wire [511:0] regC_D;
reg  [511:0] regC_Q;
always @(posedge clk)
begin
    if(rst)             regC_Q <= 512'd0; 
    else if (regC_en ==1)                regC_Q <= regC_D;
    else regC_Q <= regC_Q;
end 
//assign regC_D = mux_sel_C ? C : mont_result;
assign regC_D = mux_sel_C ? adder_result : mont_result;



// reg E
reg          regE_shift;
reg          regE_en;
reg  [511:0] regE;
always @(posedge clk)
begin
    if(rst)             regE <= 512'd0;
    else if (regE_en == 0 && regE_shift == 0 ) regE <= regE;
    else if (regE_en && regE_shift == 0)   regE <= E;
    else if (regE_en && regE_shift) regE <= regE << 1;
end  


//assign mont_in_a =  mux_sel_mont_1 ?  regC_Q : regA_Q ; 
assign mont_in_a =  mux_sel_mont_1[1] ? regC_Q : ( mux_sel_mont_2 [0] ? Ch : regA_Q );
assign mont_in_b =  mux_sel_mont_2[1] ? 514'd1 : ( mux_sel_mont_2 [0] ? R2: regA_Q );
assign mont_in_m =  m;

//Muxes for adder inputs
assign adder_in_a = mux_sel_adder_in_a ? regC_Q: adder_result;
assign adder_in_b = mux_sel_adder_in_b ? Cl : m ; 
                     
                                    
    
    
reg [9:0] ctr;  //counter
reg ctr_dec;  // ctr_dec = 1 >>> decrement the counter by 1    
//reg ctr_start;

   always @ (posedge clk)
   begin
        if (rst == 1) 
        begin 
            ctr <= 10'd512;
            //ctr_start <=1'd0;
        end
        if (ctr_dec == 1) ctr <= ctr-1;
        if (D == 1) regDone <= 1'b1;
        else regDone <= regDone;

   end
    // state machine registers description
            
                reg [4:0] state, nextstate;
            
                always @(posedge clk)
                begin
                    if(rst)        state <= 5'd0;
                    else        state <= nextstate;
                end
    
    
    
                // States definition and signals at each state
                always@(*)
                begin
                    case(state)
                        5'd0 : begin
                                    mont_start <=1'b0;
                                    regA_en <= 1'b0;
                                    mux_sel_A <= 1'b1;
                                    regC_en <= 1'b0;
                                    mux_sel_C <= 1'b1;
                                    regE_en <= 1'b1;
                                    regE_shift <= 1'b0;
                                    mux_sel_mont_1 <= 2'b10;
                                    mux_sel_mont_2 <= 2'b01;
                                    rstn_mont <= 1'b0;   // rst montogomery
                                    ctr_dec <= 1'd0;
                               end 
                               
                         5'd10 : begin    // montgomery (Ch,R2p,p)
                                    if (mont_done ==1) begin
                                                            mont_start <= 1'b0;
                                                            regC_en <= 1'b1;
                                                        end     
                                     else               begin
                                                             mont_start <=1'b1;
                                                             regC_en <= 1'b0;
                                                        end  
                                     mux_sel_C <= 1'b0;                      
                                     regA_en <=1'b0;
                                     mux_sel_A <=1'b1;
                                     regE_en <= 1'b0;
                                     regE_shift <= 1'b0;
                                     mux_sel_mont_1 <= 2'b01; //Ch
                                     mux_sel_mont_2 <= 2'b01;  // R2p
                                     rstn_mont <=1'b1;
                                     ctr_dec <= 1'd0;                                     
                                 end  
                                 
                      5'd11 : begin   // this state only to reset montogomery to be used again + store mont result in regC_Q
                                              mont_start <=1'b0;
                                              regA_en <= 1'b0;
                                              regC_en <= 1'b0;
                                              mux_sel_A <= 1'b1;
                                              mux_sel_mont_1 <= 2'b01;
                                              mux_sel_mont_2 <= 2'b01;
                                              rstn_mont <= 1'b0;   // rst montogomery
                                              regE_en <= 1'b0;
                                              regE_shift <= 1'b0;
                                              ctr_dec <= 1'd0;
                                              //
                                              rstn_adder <= 1'b0;
                                              adder_start <= 1'b0;
                                          end                                       
                          
                      5'd12: begin   // adder + Cl
                                   mont_start <=1'b0;
                                   regA_en <= 1'b0;
                                   mux_sel_A <= 1'b1;
                                   mux_sel_mont_1 <= 2'b01;
                                   mux_sel_mont_2 <= 2'b01;
                                   rstn_mont <= 1'b0;   // rst montogomery
                                   regE_en <= 1'b0;
                                   regE_shift <= 1'b0;
                                   ctr_dec <= 1'd0;
                                   mux_sel_adder_in_a <= 1'b1; // from regC_Q
                                   mux_sel_adder_in_b <= 1'b1;
                                   adder_start <= 1'b1;
                                   adder_subtract <= 1'b0;
                                   rstn_adder <= 1'b1;
                                   regC_en <= 1'b0;
                                   mux_sel_C <= 1'b1;  // take adder result.
                               end  
                               
                                                 
                          5'd13 : begin  // adder _ result will be available here 
                                  mont_start <=1'b0;
                                  regA_en <= 1'b0;
                                  mux_sel_A <= 1'b1;
                                  mux_sel_mont_1 <= 2'b01;
                                  mux_sel_mont_2 <= 2'b01;
                                  rstn_mont <= 1'b0;   // rst montogomery
                                  regE_en <= 1'b0;
                                  regE_shift <= 1'b0;
                                  ctr_dec <= 1'd0;
                                  mux_sel_adder_in_a <= 1'b1; // from regC_Q
                                  mux_sel_adder_in_b <= 1'b1;
                                  adder_start <= 1'b1;
                                  adder_subtract <= 1'b0;
                                  rstn_adder <= 1'b1;
                                  regC_en <= 1'b1;
                                  mux_sel_C <= 1'b1;  // take adder result.                          
                                  end       
                          
                          5'd14 : begin   // resert adder _ store the result of adder in regC_Q
                                      mont_start <=1'b0;
                                      regA_en <= 1'b0;
                                      mux_sel_A <= 1'b1;
                                      mux_sel_mont_1 <= 2'b01;
                                      mux_sel_mont_2 <= 2'b01;
                                      rstn_mont <= 1'b0;   // rst montogomery
                                      regE_en <= 1'b0;
                                      regE_shift <= 1'b0;
                                      ctr_dec <= 1'd0;
                                      mux_sel_adder_in_a <= 1'b1; // from regC_Q
                                      mux_sel_adder_in_b <= 1'b1;
                                      adder_start <= 1'b0;
                                      adder_subtract <= 1'b0;
                                      rstn_adder <= 1'b0;
                                      regC_en <= 1'b0;
                                      mux_sel_C <= 1'b1;  // take adder result. 
                                  end   
                          
                          5'd15 : begin  // stimulate subtraction
                                      mont_start <=1'b0;
                                      regA_en <= 1'b0;
                                      mux_sel_A <= 1'b1;
                                      mux_sel_mont_1 <= 2'b01;
                                      mux_sel_mont_2 <= 2'b01;
                                      rstn_mont <= 1'b0;   // rst montogomery
                                      regE_en <= 1'b0;
                                      regE_shift <= 1'b0;
                                      ctr_dec <= 1'd0;
                                      mux_sel_adder_in_a <= 1'b1; // from regC_Q
                                      mux_sel_adder_in_b <= 1'b0;  // p
                                      adder_start <= 1'b1;
                                      adder_subtract <= 1'b1;
                                      rstn_adder <= 1'b1;
                                      regC_en <= 1'b0;
                                      mux_sel_C <= 1'b1;  // take adder result.     
                                  end  
                              
                               5'd16 : begin  // subtraction result is available and will be checked[513] ==0
                                  mont_start <=1'b0;
                                  regA_en <= 1'b0;
                                  mux_sel_A <= 1'b1;
                                  mux_sel_mont_1 <= 2'b01;
                                  mux_sel_mont_2 <= 2'b01;
                                  rstn_mont <= 1'b0;   // rst montogomery
                                  regE_en <= 1'b0;
                                  regE_shift <= 1'b0;
                                  ctr_dec <= 1'd0;
                                  if (adder_result[513]==0) begin
                                                                mux_sel_adder_in_a <= 1'b1; // from regC_Q
                                                                mux_sel_adder_in_b <= 1'b0;  // p
                                                                regC_en <= 1'b1;
                                                                mux_sel_C <= 1'b1;  // take adder result. 
                                                             end
                                  else                       begin
                                                               mux_sel_adder_in_a <= 1'b1; // from regC_Q
                                                               mux_sel_adder_in_b <= 1'b0;  // p
                                                               regC_en <= 1'b0;
                                                               mux_sel_C <= 1'b1;  // take adder result.  
                                                             end   
                                  adder_start <= 1'b0;
                                  adder_subtract <= 1'b1;
                                  rstn_adder <= 1'b1;
                                  
                                      
                              end                           
                         // this state is meant only to X~ = X  + make sure that I'm starting with the first M.S.B = 1
                         5'd1 : begin
                                   mont_start <=1'b0;
                                   regA_en <= 1'b0;
                                   mux_sel_A <= 1'b1;
                                   //regC_en <= 1'b1;
                                   regC_en <= 1'b0;
                                   mux_sel_C <= 1'b1;
                                   mux_sel_mont_1 <= 2'b10;
                                   mux_sel_mont_2 <= 2'b01;
                                   rstn_mont <= 1'b0;   // rst montogomery
                                   
                                   if (regE[511] == 0) begin
                                                            ctr_dec <= 1'd1;
                                                            regE_shift <= 1'b1;
                                                            regE_en <= 1'b1;
                                                       end
                                   else                begin   
                                                            ctr_dec <= 1'd0;
                                                            regE_shift <= 1'b0;
                                                            regE_en <= 1'b0;
                                                       end                         
                                end       
                       
                        5'd2 : begin
                                    if (mont_done ==1) begin
                                                            mont_start <= 1'b0;
                                                            regC_en <= 1'b1;
                                                       end     
                                    else               begin
                                                            mont_start <=1'b1;
                                                            regC_en <= 1'b0;
                                                       end  
                                    mux_sel_C <= 1'b0;                      
                                    regA_en <=1'b1;
                                    mux_sel_A <=1'b1;
                                    regE_en <= 1'b0;
                                    regE_shift <= 1'b0;
                                    mux_sel_mont_1 <= 2'b10;
                                    mux_sel_mont_2 <= 2'b01;
                                    rstn_mont <=1'b1;
                                    ctr_dec <= 1'd0;
                               end  
                      5'd3 : begin   // this state only to reset montogomery to be used again
                                   mont_start <=1'b0;
                                   regA_en <= 1'b0;
                                   mux_sel_A <= 1'b1;
                                   mux_sel_mont_1 <= 2'b10;
                                   mux_sel_mont_2 <= 2'b01;
                                   rstn_mont <= 1'b0;   // rst montogomery
                                   regE_en <= 1'b0;
                                   regE_shift <= 1'b0;
                                   ctr_dec <= 1'd0;
                               end    
                                                              
                       5'd4 : begin
                                     if (mont_done ==1) begin 
                                                            mont_start <= 1'b0;
                                                            regA_en <=1'b1;
                                                        end
                                     else               begin 
                                                            mont_start <=1'b1;
                                                            regA_en <=1'b0;
                                                        end 
                                    regC_en <= 1'b0;
                                    mux_sel_C <= 1'b0;                    
                                    mux_sel_A <= 1'b0;
                                    regE_en <= 1'b0;
                                    regE_shift <= 1'b0;
                                    mux_sel_mont_1 <= 2'b00;
                                    mux_sel_mont_2 <= 2'b00;
                                    rstn_mont <= 1'b1;
                                    ctr_dec <= 1'd0;
                              end  
                        5'd5 : begin // this state only to reset montogomery to be used again and save result of mont. to A
                                  mont_start <=1'b0;
                                  regA_en <= 1'b0;
                                  mux_sel_A <= 1'b1;
                                  regC_en <= 1'b0;
                                  mux_sel_C <= 1'b0; 
                                  
                                  if (regE[511] == 0)     begin 
                                                            regE_shift <= 1'b1;
                                                            regE_en <= 1'b1;
                                                            ctr_dec <= 1'd1;
                                                        end     
                                  else                  begin 
                                                            regE_shift <= 1'b0;
                                                            regE_en <= 1'b0;
                                                            ctr_dec <= 1'd0;
                                                        end     
                                  mux_sel_mont_1 <= 2'b10;
                                  mux_sel_mont_2 <= 2'b00;
                                  rstn_mont <= 1'b0;   // rst montogomery
                                    
                              end      
                              
                        5'd6 : begin
                                     if (mont_done ==1) begin 
                                                            mont_start <= 1'b0;
                                                            regA_en <=1'b1;
                                                        end
                                     else               begin 
                                                            mont_start <=1'b1;
                                                            regA_en <=1'b0;
                                                        end 
                                      regC_en <= 1'b0;
                                      mux_sel_C <= 1'b0;                    
                                      mux_sel_A <= 1'b0;
                                      regE_en <= 1'b0;
                                      regE_shift <= 1'b0;
                                      mux_sel_mont_1 <= 2'b10;
                                      mux_sel_mont_2 <= 2'b00;
                                      rstn_mont <= 1'b1;
                                      ctr_dec <= 1'd0;
                                      
                               end 
                              
                        5'd7 : begin // this state only to reset montogomery to be used again and save result of mont. to A
                                      mont_start <=1'b0;
                                      regA_en <= 1'b0;
                                      mux_sel_A <= 1'b1;
                                      regC_en <= 1'b0;
                                      mux_sel_C <= 1'b0; 
                                      regE_en <= 1'b1;
                                      regE_shift <= 1'b1;
                                      mux_sel_mont_1 <= 2'b10;
                                      mux_sel_mont_2 <= 2'b00;
                                      rstn_mont <= 1'b0;   // rst montogomery
                                      ctr_dec <= 1'd1; 
                               end
                               
                        5'd8 : begin
                                            if (mont_done ==1) begin 
                                                                   mont_start <= 1'b0;
                                                                   regA_en <=1'b1;
                                                               end
                                            else               begin 
                                                                   mont_start <=1'b1;
                                                                   regA_en <=1'b0;
                                                               end 
                                             regC_en <= 1'b0;
                                             mux_sel_C <= 1'b0;                    
                                             mux_sel_A <= 1'b0;
                                             regE_en <= 1'b0;
                                             regE_shift <= 1'b0;
                                             mux_sel_mont_1 <= 2'b00;
                                             mux_sel_mont_2 <= 2'b10;
                                             rstn_mont <= 1'b1;
                                             ctr_dec <= 1'd0;
                                      end 

                        5'd9 : begin // this state only to reset montogomery to be used again and save result of mont. to A
                                      mont_start <=1'b0;
                                      regA_en <= 1'b0;
                                      mux_sel_A <= 1'b1;
                                      regC_en <= 1'b0;
                                      mux_sel_C <= 1'b0; 
                                      regE_en <= 1'b0;
                                      regE_shift <= 1'b0;
                                      mux_sel_mont_1 <= 2'b10;
                                      mux_sel_mont_2 <= 2'b00;
                                      rstn_mont <= 1'b0;   // rst montogomery
                                      ctr_dec <= 1'd0; 
                                      D <= 1'b1;
                               end
                                  
                              
                                     
                        default : begin
  
                                  end    
                    endcase
                end
    
    
    
                // next state logic  
                always@(*)
                begin
                    case(state)
                        5'd0 : begin
                                    if (start ==1 )
                                            nextstate <= 5'd10;
                                    else 
                                            nextstate <= 5'd0;        
                               end 
                         
                        5'd10 : begin 
                                        if (mont_done ==1 ) nextstate <=5'd11;
                                        else nextstate <= 5'd10;
                                end
                        5'd11 : nextstate <= 5'd12;
                        5'd12 : nextstate <= 5'd13;
                        5'd13 : nextstate <= 5'd14;
                        5'd14 : nextstate <= 5'd15;
                        5'd15 : nextstate <= 5'd16;
                        5'd16 : begin 
                                        if (adder_result[513] == 0) nextstate <= 5'd15;
                                        else nextstate <= 5'd1;
                                end                          
                        5'd1 : begin 
                                    if (regE[511] == 0) nextstate <= 5'd1;
                                    else nextstate <= 5'd2;                        
                                                            
                               end
                        5'd2 : begin
                                    if (mont_done ==1 ) nextstate <= 5'd3;
                                   else nextstate <= 5'd2;
                               end   
                        5'd3 : nextstate <= 5'd4;         
                        5'd4 : begin
                                  // if (ctr_start==0) nextstate <= 5'd4;                                        
                                  // else begin                               
                                       if (ctr == 0) nextstate <= 5'd8;
                                    else begin 
                                            if (mont_done ==1 ) nextstate <= 5'd5;
                                            else nextstate <= 5'd4;
                                        end  
                                   end  
                              //end 
                        5'd5 : begin
                                    if (regE[511] == 0) nextstate <= 5'd4;
                                    else nextstate <= 5'd6;
                               end
                        5'd6 : begin 
                                    if (mont_done ==1 ) nextstate <= 5'd7;
                                    else nextstate <= 5'd6;
                               end
                        5'd7 : nextstate <= 5'd4;    
                        5'd8 : begin
                                    if (mont_done ==1 ) nextstate <= 5'd9;
                                    else nextstate <= 5'd8;
                               end    
                          
                       5'd9 : nextstate <= 5'd0;        
                               
                    endcase
                end
    
    
    
assign result = regA_Q;
assign done = regDone;    

    
endmodule
