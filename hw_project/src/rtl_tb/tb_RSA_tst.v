`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_RSA_tst();
    
    reg          clk;
    reg          resetn;
    reg          start;
    reg  [1023:0] Cipher;
    reg  [511:0] E;
    reg  [511:0] m;
    reg  [511:0] R2;
    reg  [511:0] R;
    wire [511:0] result;
    wire         done;

    reg  [511:0] expected;
    reg          result_ok;
    
    //Instantiating montgomery module
    exp_tst exp( .clk    (clk    ),
                                    .resetn (resetn ),
                                    .start  (start  ),
                                    .Cipher (Cipher),
                                    .E   (E  ),
                                    .m   (m  ),
                                    .R2   (R2  ),
                                    .R   (R  ),
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
        m     <= 512'hc3950043c9a0fc8f18f843cbb3a61c563af4dc98504f830f85bef62be4931d3708a0ce1ecc4e6d46bec3f67da21a59b07c7be88046a9eb9867d766080575f93f;
        R     <= 512'h3c6affbc365f0370e707bc344c59e3a9c50b2367afb07cf07a4109d41b6ce2c8f75f31e133b192b9413c09825de5a64f8384177fb9561467982899f7fa8a06c1;
        R2      <= 512'h39ca2753baea45553d246ea315c807af7c4e2255b4e47b1d63a77c32d9ca362e4ecc398d1763a24f15caa3db1115bf2ab246d9466bd7dcc7402eea71429509c9;
        E <= 512'h123b70344dbadfc6321f5960454fd7e19cbfc78011d8a5e53c3ac3bf2434da88842d5b1adc62d4a32749f1ce9fa1c8863db2caf4a455cb6562dab2b0740d37ab;
        Cipher <= 1023'h7bd00b852e5d60b3e7a44d595cc9b2cb11db8efec8aac6dbd611ba58c8c6c8d1ab0cd772d125b7c208b2843588e1c15e88f197d448fc6c4346e69673953b86da2cf6d1bfbde1dc14f2cb8bee5b41601497e97332b42aec8331ca82b7db16207e71dc5ca76ccaba73f363a7b6662b07a165f565ab8458b170da0d33242eec3ff9;
        
        
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