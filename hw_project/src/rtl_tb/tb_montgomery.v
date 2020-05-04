`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_montgomery();
    
    reg          clk;
    reg          resetn;
    reg          start;
    reg  [513:0] in_a;
    reg  [513:0] in_b;
    reg  [513:0] in_m;
    wire [511:0] result;
    wire         done;

    reg  [513:0] expected;
    reg          result_ok;
    
    //Instantiating montgomery module
    montgomery montgomery_instance( .clk    (clk    ),
                                    .resetn (resetn ),
                                    .start  (start  ),
                                    .in_a   (in_a   ),
                                    .in_b   (in_b   ),
                                    .in_m   (in_m   ),
                                    .result (result ),
                                    .done   (done   ));

    //Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end
    
    //Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end
    
    // Test data
    initial begin

        #`RESET_TIME
        
        // You can generate your own with test vector generator python script
        //in_a     <= 512'ha;
        //in_b     <= 512'h1;
        //in_m     <= 512'h7;
        //expected <= 512'h3f869127d962ca1ee7a3e30025438f9a13e884e22346ad294bbb9d5c4491aa217feb11b6b8529c3db9f55d8641bf66b39586d7959545d8ff0379679228f637c3;
        //in_a     <= 514'h87b21d93a10f35511c8d56264a6f95f0245d8004e0d3557c7ec2b396b4ed3cabda34f88e0c8154e9ffab2761e626a720eef1da7ee31ce6c31fcdeaec38eb9589;
        //in_b     <= 514'h901702c94e8d7f3c733aafa46a6b43948148fd2f08761b134bc6815c3a69f4fc4ca4cbec55a2e1e70178549683bf79db5fec9631717e6ae69a5ea5c9eb2a118d;
        //in_m     <= 514'hf8f635bfae6507fc726853e48b8ff18f8037f58fbef63debba0381f2a7da936679f14a270b1129a730d905d283459a275b4dd75470965dfa6386b5321563997d;
        //expected     <= 514'hefbbb81aee8737730fcc1b52630ad7056a18df6a9b0c0f0744d2c0f0cc7ac28991b23733a539d8a06329f65394307f2b4f0a3e146227179be2d5ce9f71561b2;
        in_a     <= 512'h9387414a60962237b24975d124135a563036f10770b0543aa1eb576d59c8390961105d2ac5d5c839fe20eaf12dd971886d49d3d49254d3929f37ea38d55e8657;
        in_b     <= 512'h1;
        in_m     <= 512'hc3950043c9a0fc8f18f843cbb3a61c563af4dc98504f830f85bef62be4931d3708a0ce1ecc4e6d46bec3f67da21a59b07c7be88046a9eb9867d766080575f93f;
        expected     <= 514'hefbbb81aee8737730fcc1b52630ad7056a18df6a9b0c0f0744d2c0f0cc7ac28991b23733a539d8a06329f65394307f2b4f0a3e146227179be2d5ce9f71561b2;


        start<=1;
        #`CLK_PERIOD;
        start<=0;
        
        wait (done==1);
        
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD;   

        
        $finish;
    end
           
endmodule