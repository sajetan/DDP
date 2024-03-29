`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg  [513:0]  in_a;
    reg  [513:0]  in_b;
    reg           start;
    reg           subtract;
    wire [514:0]  result;
    wire          done;

    reg  [514:0]  expected;
    reg           result_ok;

    // Instantiating adder
    mpadder dut (
        .clk      (clk     ),
        .rstn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .A     (in_a    ),
        .B     (in_b    ),
        .result   (result  ),
        .done     (done    ));

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals to zero
    initial begin
        in_a     <= 0;
        in_b     <= 0;
        subtract <= 0;
        start    <= 0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    task perform_add;
        input [513:0] a;
        input [513:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd0;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    task perform_sub;
        input [513:0] a;
        input [513:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd1;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    initial begin

    #`RESET_TIME

    /*************TEST ADDITION*************/
    
    $display("\nAddition with testvector 1");
    
    // Check if 1+1=2
    #`CLK_PERIOD;
    perform_add(514'h1, 
                514'h1);
    expected  = 515'h2;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;   
    
    $display("\nAddition with testvector 2");

    // Test addition with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
    perform_add(514'h25a168a552f4f012bc5739d778d3359e6a6d93301e0e1fd39eb387b99035be1253bde7845f04952d67729b6d628cf2c781c97fc9e09abd1a8ccf07df631a25376,
                514'h3d98f4d0b19bd93b7555963ef02a487f598c28d335344a5ecc8cf9d98caf08748a7558f1691857923f52d4fc8c055b094eb9712cad132a8352826246b67bd3899);
    expected  = 515'h633a5d760490c94e31acd01668fd7e1dc3f9bc0353426a326b4081931ce4c686de334075c81cecbfa6c57069ee924dd0d082f0f68dade79ddf516a261995f8c0f;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;     
    
    /*************TEST SUBTRACTION*************/

    $display("\nSubtraction with testvector 1");
    
    // Check if 1-1=0
    #`CLK_PERIOD;
    perform_sub(514'h10, 
                514'h5);
    expected  = 515'h5;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;    


    $display("\nSubtraction with testvector 2");

    // Test subtraction with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
   // perform_sub(514'h329e3c39498f09ad105029d84a0cd39bfae260be1a2c18a9b6765a619e1f7114e3d6f85471846dca91071d6001a5c69db3fd36bada0499566a037125b70466b62,
     //           514'h21bd2189a5b2de4b579ba4b0eeeb74645d6ab55875fcf441ccae3f63df9bd513aebaf0902c4e718e6d75354f4cc4927536318016eda7745db1c2d9688ddb90a54);
   // expected  = 515'h10e11aafa3dc2b61b8b485275b215f379d77ab65a42f2467e9c81afdbe839c01351c07c44535fc3c2391e810b4e134287dcbb6a3ec5d24f8b84097bd2928d610e;
  
      perform_sub(514'h107f1f1415d4d7b73a3651599b1c09effd6d9838668a6fedc2e50ae01b4a23f8f130c6d9a4564c731370ba537bc88a21a103e7b35b6b8cf7421b4121c0c78fb2f,
                514'hf8f635bfae6507fc726853e48b8ff18f8037f58fbef63debba0381f2a7da936679f14a270b1129a730d905d283459a275b4dd75470965dfa6386b5321563997d);
    expected  = 515'hefbbb81aee8737730fcc1b52630ad7056a18df6a9b0c0f0744d2c0f0cc7ac28991b23733a539d8a06329f65394307f2b4f0a3e146227179be2d5ce9f71561b2;
     
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;     

    $finish;

    end

endmodule