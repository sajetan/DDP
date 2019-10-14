`timescale 1ns / 1ps

//Implementation of adder and subtractor

module mpadder(
    input  wire         clk,
    input  wire         rstn,
    input  wire         start,
    input  wire         subtract,
    input  wire [513:0] A,
    input  wire [513:0] B,
    output wire [514:0] C, 
    output wire         done);


    assign rst = ~rstn ;
    reg Mo ;  //this reg is dedicated in memory of our great engineer. It indicates if enabled consider the first two bits of the adder while right shifting.
    wire Cout;
    
    
    // mux selction for B or ~B
        
    wire [513:0] muxB;
    assign muxB = (subtract == 0) ? B : ~B ;
        
       
    // 514-bit register for A
    // It will save the input data when enable signal is high
      
    reg          regA_en;
    wire [513:0] regA_D;
    reg  [513:0] regA_Q;
    always @(posedge clk)
    begin
        if(rst)             regA_Q <= 514'd0;
        else if (regA_en)   regA_Q <= regA_D;
    end

    
    // 514-bit register for B

    reg          regB_en;
    wire [513:0] regB_D;
    reg  [513:0] regB_Q;
    always @(posedge clk)
    begin
        if(rst)             regB_Q <= 514'd0;
        else if (regB_en)   regB_Q <= regB_D;
    end

    // 2-input 514-bit Multiplexer for A
    // It should select either of these two:
    //   - the input A
    //   - the output of regA shifted-right by 128
    // Also connect the output of Mux to regA's input

    reg          muxA_sel;
    wire [513:0] muxA_Out;
    assign muxA_Out = (muxA_sel == 0) ? A : {128'b0,regA_Q[513:128]};

    assign regA_D = muxA_Out;

    // 2-input 514-bit Multiplexer for B
    // (always statement for combinatorial logic)

    reg          muxB_sel;
    reg  [513:0] muxB_Out;
    always@(*) begin
        if (muxB_sel==1'b0) muxB_Out <= muxB;
        else                muxB_Out <= {128'b0,regB_Q[513:128]};
    end

    assign regB_D = muxB_Out;

    
    // Adder description
    // It should be a combinatorial logic:
    // Its inputs are two 128-bit operands and 1-bit carry-in
    // Its outputs are one 128-bit result  and 1-bit carry-out

    wire [127:0] operandA;
    wire [127:0] operandB;
    wire        carry_in;
    wire [127:0] result;
    wire        carry_out;

    assign {carry_out,result} = operandA + operandB + carry_in;

    // 514-bit register for storing the result
    // The register should store adder's outputs at the msb 128-bits
    // and the shift the previous 128 msb bits to lsb.

    reg          regResult_en;
    reg  [513:0] regResult;
    always @(posedge clk)
    begin
        if(rst)                 regResult <= 514'b0;
        else if (regResult_en && ~Mo )  regResult <= {result, regResult[513:128]};  // for the first 4 cycles
        else if (regResult_en && Mo  )  regResult <= {result[1:0],regResult[513:2]};  // for the 5th cycle.
    end

    // 1-bit register for storing the carry-out

    reg  regCout_en;
    reg  regCout;
    always @(posedge clk)
    begin
        if(rst)              regCout <= 1'b0;
        else if (regCout_en) regCout <= carry_out;
    end
    
    // mux for the first carry in
                   
   reg  carry_add_sub;
   always@(*) begin
       if (subtract == 0) carry_add_sub <= 0;
       else               carry_add_sub <= subtract;
   end


    
    // 1-bit multiplexer for selecting carry-in
    // It should select either of these two:
    //   - 0
    //   - carry-out

    reg  muxCarryIn_sel;
    wire muxCarryIn;

    assign muxCarryIn = (muxCarryIn_sel == 0) ? carry_add_sub: regCout;

    // Connect the inputs of adder to the outputs of A and B registers
    // and to the carry mux

    assign operandA = regA_Q;
    assign operandB = regB_Q;
    assign carry_in = muxCarryIn;


    // output - concatenate the registers of carry_out and result

    assign Cout = regCout ^ subtract;
    assign C = {Cout,regResult};
    
    // state machine registers description

    reg [2:0] state, nextstate;

    always @(posedge clk)
    begin
        if(rst)		state <= 3'd0;
        else        state <= nextstate;
    end

    // States definition and signals at each state
    always @(*)
    begin
        case(state)

            // Idle state; Here the FSM waits for the start signal
            // Enable input registers to fetch the inputs A and B when start is received
            
            3'd0: begin
                        regA_en        <= 1'b1;
                        regB_en        <= 1'b1;
                        regResult_en   <= 1'b0;
                        regCout_en     <= 1'b0;
                        muxA_sel       <= 1'b0;
                        muxB_sel       <= 1'b0;
                        muxCarryIn_sel <= 1'b0;
                        Mo <= 0;
                  end
            // Add 1:
            // Disable input registers (not sure! disable a good practice but it is ok!)
            // Calculate the first addition
            3'd1: begin
                        regA_en        <= 1'b1;
                        regB_en        <= 1'b1;
                        regResult_en   <= 1'b1;
                        regCout_en     <= 1'b1;
                        muxA_sel       <= 1'b1;
                        muxB_sel       <= 1'b1;
                        muxCarryIn_sel <= 1'b0;
                        Mo <=0;
                  end
            
            // Add 2:
            // Disable input registers (not sure! disable a good practice but it is ok!)
            // Calculate the first addition
            3'd2: begin
                        regA_en        <= 1'b1;
                        regB_en        <= 1'b1;
                        regResult_en   <= 1'b1;
                        regCout_en     <= 1'b1;
                        muxA_sel       <= 1'b1;
                        muxB_sel       <= 1'b1;
                        muxCarryIn_sel <= 1'b1;
                        Mo <=0;
                  end
            
            // Add 3:
            // Disable input registers (not sure! disable a good practice but it is ok!)
            // Calculate the first addition
            3'd3: begin
                        regA_en        <= 1'b1;
                        regB_en        <= 1'b1;
                        regResult_en   <= 1'b1;
                        regCout_en     <= 1'b1;
                        muxA_sel       <= 1'b1;
                        muxB_sel       <= 1'b1;
                        muxCarryIn_sel <= 1'b1;
                        Mo <= 0;
                  end

            // Add 4:
            // Disable input registers (not sure! disable a good practice but it is ok!)
            // Calculate the first addition
            3'd4: begin
                        regA_en        <= 1'b1;
                        regB_en        <= 1'b1;
                        regResult_en   <= 1'b1;
                        regCout_en     <= 1'b1;
                        muxA_sel       <= 1'b1;
                        muxB_sel       <= 1'b1;
                        muxCarryIn_sel <= 1'b1;
                        Mo <=0;
                  end

            // Add 5:
            // Disable input registers (not sure! disable a good practice but it is ok!)
            // Calculate the first addition
            3'd5: begin
                        regA_en        <= 1'b0;
                        regB_en        <= 1'b0;
                        regResult_en   <= 1'b1;
                        regCout_en     <= 1'b0;
                        muxA_sel       <= 1'b1;
                        muxB_sel       <= 1'b1;
                        muxCarryIn_sel <= 1'b1;
                        Mo <= 1;
                  end
            

                  default: begin
                        regA_en        <= 1'b0;
                        regB_en        <= 1'b0;
                        regResult_en   <= 1'b1;
                        regCout_en     <= 1'b0;
                        muxA_sel       <= 1'b0;
                        muxB_sel       <= 1'b0;
                        muxCarryIn_sel <= 1'b0;
                        Mo <= 0;
                  end

        endcase
    end

    // next_state logic description

    always @(*)
    begin
        case(state)
            3'd0: begin
                if(start)
                    nextstate <= 3'd1;
                else
                    nextstate <= 3'd0;
                end

                3'd1   : nextstate <= 3'd2;
                3'd2   : nextstate <= 3'd3;
                3'd3   : nextstate <= 3'd4;
                3'd4   : nextstate <= 3'd5;
                3'd5   : nextstate <= 3'd6;
                3'd6   : nextstate <= 3'd0;
                default: nextstate <= 3'd0;
        endcase
    end

    // done signal description
    // It should be high at the same clock cycle when the output ready

                reg regDone;
                always @(posedge clk)
                begin
                    if(rst)     regDone <= 1'd0;
                    else        regDone <= (state==3'd5) ? 1'b1 : 1'b0;;
                end

                assign done = regDone;

endmodule
