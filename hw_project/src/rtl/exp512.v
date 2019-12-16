`timescale 1ns / 1ps


module exp_512( 
input clk,resetn,start,
input [1023:0] C,
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

wire [511:0] Cl,Ch;
assign Cl = C[511:0];
assign Ch = C[1023:512];
//declaration of signals   
reg mont_start;
reg mux_sel_A,mux_sel_C;  //mux for mon. inputs  
reg [1:0] mux_sel_mont_2,mux_sel_mont_1;  
wire mont_done;    
wire [514:0] adder_result;
wire [511:0] mont_result;
wire [513:0] mont_in_a,mont_in_b,mont_in_m,add_in_a,add_in_b;
reg x,xsub;   
reg mux_sel_add_in_b;
reg D, regDone; // for done




reg rstn_mont;
//Instantiating montgomery module 1
montgomery montgomery_instance1(
.clk    (clk    ),
.resetn (rstn_mont ),
.start  (mont_start  ),
.in_a   (mont_in_a   ),
.in_b   (mont_in_b   ),
.in_m   (mont_in_m   ),
.add_in_a (add_in_a),
.add_in_b (add_in_b),
.x (x),
.xsub(xsub),
.result (mont_result ),
.done   (mont_done   ));


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
assign regC_D = mux_sel_C ? C : mont_result;



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


assign mont_in_a =  mux_sel_mont_1[1] ?  regC_Q :(mux_sel_mont_1[0] ? Ch : regA_Q) ; 
assign mont_in_b =  mux_sel_mont_2[1] ? 514'd1 : ( mux_sel_mont_2 [0] ? R2: regA_Q );
assign mont_in_m =  m;

 
                     
                                    
// assign inputs for mont. if it's used as adder.
assign add_in_a = regC_Q;
assign add_in_b = mux_sel_add_in_b ? Cl : m ;

//    assign regres_D = adder_result;

    
//    assign adder_in_b = m;
//    assign adder_in_a = mux_sel[1] ? R2 :(mux_sel[0]? R : regres_Q) ; 
    
    
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
                                    mux_sel_mont_1 <= 2'b11;
                                    mux_sel_mont_2 <= 2'b01;
                                    rstn_mont <= 1'b0;   // rst montogomery
                                    ctr_dec <= 1'd0;
                                    x <= 1'b0;
                                    xsub <=1'b0;
                                    D <= 1'b0;
                                    mux_sel_add_in_b <= 1'b1;
                               end 
                               
                         5'd10 : begin   // starting mont.
                                      ctr_dec <= 1'd0;
                                      regA_en <= 1'b0;
                                      regE_en <= 1'b1;
                                      regE_shift <= 1'b0;
                                      mux_sel_A <= 1'b1;
                                      x <= 1'b0;
                                      xsub <=1'b0;
                                      mux_sel_mont_1 <= 2'b01;
                                      mux_sel_mont_2 <= 2'b01;
                                      D <= 1'b0;  
                                      rstn_mont <= 1'b1;
                                      mux_sel_C <= 1'b0; // to take mont result.
                                      mux_sel_add_in_b <= 1'b1; 
                                      if (mont_done ==1) begin
                                                            regC_en <= 1'b0;
                                                            mont_start <= 1'b0;
                                                         end   
                                      else               begin 
                                                             regC_en <= 1'b1;
                                                             mont_start <= 1'b1;
                                      end                       
                                 end      
                           
                         5'd11 : begin   // reset mont. and value is saved in regC.
                                     regC_en <= 1'b0;
                                     mux_sel_C <= 1'b0;
                                     mont_start <=1'b0;
                                     regA_en <= 1'b0;
                                     mux_sel_A <= 1'b1;
                                     mux_sel_mont_1 <= 2'b11;
                                     mux_sel_mont_2 <= 2'b01;
                                     rstn_mont <= 1'b0;   // rst montogomery
                                     regE_en <= 1'b0;
                                     regE_shift <= 1'b0;
                                     ctr_dec <= 1'd0;
                                     x <= 1'b0;
                                     xsub <=1'b0;
                                     D <= 1'b0;
                                     mux_sel_add_in_b <= 1'b1; 
                                 end     
                                 
                          5'd12 : begin  // adder Cp
                                        regE_en <= 1'b0;
                                        regE_shift <= 1'b0;
                                        D <= 1'b0; 
                                        regA_en <= 1'b0;  
                                        mux_sel_mont_1 <= 2'b11;
                                        mux_sel_mont_2 <= 2'b01;
                                        mux_sel_A <= 1'b1;                                   
                                        mux_sel_add_in_b <= 1'b1;  // Cl
                                        x <= 1'b1;
                                        xsub <= 1'b0;
                                        mont_start <= 1'b1;
                                        rstn_mont <= 1'b1; 
                                        if(mont_done == 1 ) regC_en <= 1'b1;
                                        else                regC_en <= 1'b0;
                                        mux_sel_C <= 1'b0;
                                        ctr_dec <= 1'd0;
                                  end       
                           
                           5'd13 : begin  // reset mont. and value is saved in regC.
                                       D <= 1'b0;
                                       x <=1'b0;
                                       xsub <=1'b0;
                                       regC_en <= 1'b0;
                                       mont_start <=1'b0;
                                       regA_en <= 1'b0;
                                       mux_sel_A <= 1'b1;
                                       mux_sel_mont_1 <= 2'b11;
                                       mux_sel_mont_2 <= 2'b01;
                                       rstn_mont <= 1'b0;   // rst montogomery
                                       regE_en <= 1'b0;
                                       regE_shift <= 1'b0;
                                       ctr_dec <= 1'd0;
                                       mux_sel_C <= 1'b0;
                                       mux_sel_add_in_b <= 1'b1; 
                                   end
                           
                            5'd14 : begin   // start of module sub.
                                        mux_sel_add_in_b <= 1'b0;  // p
                                        x <= 1'b1;
                                        xsub <= 1'b1;
                                        mont_start <= 1'b1;
                                        rstn_mont <= 1'b1; 
                                        regC_en <= 1'b0;
                                        mux_sel_C <= 1'b0;
                                        D <= 1'b0; 
                                        regA_en <= 1'b0;
                                        mux_sel_A <= 1'b1;
                                        regE_en <= 1'b0;
                                        regE_shift <= 1'b0;
                                        mux_sel_mont_1 <= 2'b11;
                                        mux_sel_mont_2 <= 2'b01;
                                        ctr_dec <= 1'd0;
                                    end
                           5'd15 : begin
                                         mux_sel_add_in_b <= 1'b0;
                                         ctr_dec <= 1'd0;
                                         mont_start <=1'b0;
                                         rstn_mont <= 1'b0;
                                         mux_sel_mont_1 <= 2'b11;
                                         mux_sel_mont_2 <= 2'b01;
                                         regA_en <= 1'b0;
                                         mux_sel_A <= 1'b1;
                                         regE_en <= 1'b0;
                                         regE_shift <= 1'b0;
                                         D <= 1'b0;
                                         x <= 1'b1;
                                         xsub <= 1'b1;
                                         mux_sel_C <= 1'b0;
                                         if (mont_result [510] == 0) regC_en <= 1'b1;
                                         else                        regC_en <= 1'b0;                              
                                   end 
                                 
                         // this state is meant only to X~ = X  + make sure that I'm starting with the first M.S.B = 1
                         5'd1 : begin
                                   D <= 1'b0;
                                   x <= 1'b0;
                                   xsub <= 1'b0;
                                   mont_start <=1'b0;
                                   regA_en <= 1'b0;
                                   mux_sel_A <= 1'b1;
                                   regC_en <= 1'b0;
                                   mux_sel_C <= 1'b1;
                                   mux_sel_mont_1 <= 2'b11;
                                   mux_sel_mont_2 <= 2'b01;
                                   rstn_mont <= 1'b0;   // rst montogomery
                                   mux_sel_add_in_b <= 1'b0;
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
                                    mux_sel_mont_1 <= 2'b11;
                                    mux_sel_mont_2 <= 2'b01;
                                    rstn_mont <=1'b1;
                                    ctr_dec <= 1'd0;
                                    x <= 1'b0;
                                    xsub <=1'b0;
                                    D <= 1'b0;
                                    mux_sel_add_in_b <= 1'b0;
                               end  
                      5'd3 : begin   // this state only to reset montogomery to be used again
                                   mont_start <=1'b0;
                                   regA_en <= 1'b0;
                                   mux_sel_A <= 1'b1;
                                   mux_sel_mont_1 <= 2'b11;
                                   mux_sel_mont_2 <= 2'b01;
                                   rstn_mont <= 1'b0;   // rst montogomery
                                   regE_en <= 1'b0;
                                   regE_shift <= 1'b0;
                                   ctr_dec <= 1'd0;
                                   x <= 1'b0;
                                   xsub <=1'b0;
                                   D <= 1'b0;
                                   regC_en <= 1'b0;
                                   mux_sel_C <= 1'b1;
                                   mux_sel_add_in_b <= 1'b0;
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
                                    x <= 1'b0;
                                    xsub <=1'b0;
                                    D <= 1'b0;
                                    mux_sel_add_in_b <= 1'b0;
                              end  
                        5'd5 : begin // this state only to reset montogomery to be used again and save result of mont. to A
                                  mont_start <=1'b0;
                                  regA_en <= 1'b0;
                                  mux_sel_A <= 1'b1;
                                  regC_en <= 1'b0;
                                  mux_sel_C <= 1'b0; 
                                  mux_sel_add_in_b <= 1'b0;
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
                                  mux_sel_mont_1 <= 2'b11;
                                  mux_sel_mont_2 <= 2'b00;
                                  rstn_mont <= 1'b0;   // rst montogomery
                                  x <= 1'b0;
                                  xsub <=1'b0;  
                                  D <= 1'b0;
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
                                      mux_sel_mont_1 <= 2'b11;
                                      mux_sel_mont_2 <= 2'b00;
                                      rstn_mont <= 1'b1;
                                      ctr_dec <= 1'd0;
                                      x <= 1'b0;
                                      xsub <=1'b0;
                                      D <= 1'b0;
                                      mux_sel_add_in_b <= 1'b0;
                               end 
                              
                        5'd7 : begin // this state only to reset montogomery to be used again and save result of mont. to A
                                      mont_start <=1'b0;
                                      regA_en <= 1'b0;
                                      mux_sel_A <= 1'b1;
                                      regC_en <= 1'b0;
                                      mux_sel_C <= 1'b0; 
                                      regE_en <= 1'b1;
                                      regE_shift <= 1'b1;
                                      mux_sel_mont_1 <= 2'b11;
                                      mux_sel_mont_2 <= 2'b00;
                                      rstn_mont <= 1'b0;   // rst montogomery
                                      ctr_dec <= 1'd1; 
                                      x <= 1'b0;
                                      xsub <=1'b0;
                                      D <= 1'b0;
                                      mux_sel_add_in_b <= 1'b0;
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
                                             x <= 1'b0;
                                             xsub <=1'b0;
                                             D <= 1'b0;
                                             mux_sel_add_in_b <= 1'b0;
                                      end 

                        5'd9 : begin // this state only to reset montogomery to be used again and save result of mont. to A
                                      mont_start <=1'b0;
                                      regA_en <= 1'b0;
                                      mux_sel_A <= 1'b1;
                                      regC_en <= 1'b0;
                                      mux_sel_C <= 1'b0; 
                                      regE_en <= 1'b0;
                                      regE_shift <= 1'b0;
                                      mux_sel_mont_1 <= 2'b11;
                                      mux_sel_mont_2 <= 2'b00;
                                      rstn_mont <= 1'b0;   // rst montogomery
                                      ctr_dec <= 1'd0; 
                                      x <= 1'b0;
                                      xsub <=1'b0;
                                      D <= 1'b1;
                                      mux_sel_add_in_b <= 1'b0;
                               end
                                  
                              
                                     
                        default : begin
                                    mont_start <=1'b0;
                                    regA_en <= 1'b0;
                                    mux_sel_A <= 1'b1;
                                    regC_en <= 1'b0;
                                    mux_sel_C <= 1'b1;
                                    regE_en <= 1'b1;
                                    regE_shift <= 1'b0;
                                    mux_sel_mont_1 <= 2'b11;
                                    mux_sel_mont_2 <= 2'b01;
                                    rstn_mont <= 1'b0;   // rst montogomery
                                    ctr_dec <= 1'd0;
                                    x <= 1'b0;
                                    xsub <=1'b0;
                                    D <= 1'b0;
                                    mux_sel_add_in_b <= 1'b0;
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
                                    if (mont_done == 1 ) nextstate <= 5'd11;
                                    else nextstate <= 5'd10;
                                end 
                        5'd11: nextstate <= 5'd12;
                        5'd12 : begin 
                                    if (mont_done == 1) nextstate <= 5'd13;
                                    else nextstate <= 5'd12;
                                end   
                        5'd13 : nextstate <= 5'd14;
                        5'd14 : begin
                                    if (mont_done == 1 ) nextstate <= 5'd15;
                                    else nextstate <= 5'd14;
                                end            
                                
                        5'd15 : begin 
                                    if (mont_result[510] ==0 ) nextstate <= 5'd14;
                                    else                       nextstate <= 5'd1;
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
                       default : nextstate <= 5'd0;     
                               
                    endcase
                end
    
    
    
    
assign result = regA_Q;
assign done = regDone; 
    
endmodule




