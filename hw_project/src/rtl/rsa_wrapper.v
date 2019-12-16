`timescale 1ns / 1ps

module rsa_wrapper #(
    parameter TX_SIZE = 1024
) (
    // The clock and active low reset
    input                clk, 
    input                resetn,
    
    input  [31:0]        arm_to_fpga_cmd,
    input                arm_to_fpga_cmd_valid,
    output               fpga_to_arm_done,
    input                fpga_to_arm_done_read,

    input                arm_to_fpga_data_valid,
    output               arm_to_fpga_data_ready,
    input  [TX_SIZE-1:0] arm_to_fpga_data,
    
    output               fpga_to_arm_data_valid,
    input                fpga_to_arm_data_ready,
    output [TX_SIZE-1:0] fpga_to_arm_data,
    
    output [3:0]         leds

    );


wire [1023:0] RSA_Cipher;
wire [511:0]RSA_result;
wire [511:0] dp,p,R2p,Rp;
reg RSA_start;
wire  RSA_done;

    //Instantiating montgomery module
    exp_512 expon ( .clk    (clk    ),
                                    .resetn (resetn ),
                                    .start  (RSA_start  ),
                                    .C (RSA_Cipher),
                                    .E   (dp  ),
                                    .m   (p  ),
                                    .R2   (R2p  ),
                                    .R   (Rp  ),
                                    .result (RSA_result ),
                                    .done   (RSA_done   ));

    ////////////// - State Machine 

    /// - State Machine Parameters

    localparam STATE_BITS           = 3;    
    localparam STATE_WAIT_FOR_CMD   =      3'h0;  
    localparam STATE_READ_DATA_Cipher =    3'h1;
    localparam STATE_READ_DATA_pdp      =   3'h2;
    localparam STATE_READ_DATA_R2pRp    = 3'h3;
    localparam STATE_COMPUTE        =      3'h4;
    localparam STATE_COMPUTE_WAIT   =      3'h5;
    localparam STATE_WRITE_DATA     =      3'h6;
    localparam STATE_ASSERT_DONE    =      3'h7;
    

    reg [STATE_BITS-1:0] r_state;
    reg [STATE_BITS-1:0] next_state;
    
    localparam CMD_READ_Cipher             = 32'h0;
    localparam CMD_READ_pdp                 = 32'h1;
    localparam CMD_READ_R2pRp            = 32'h2;
    localparam CMD_COMPUTE                 = 32'h3;    
    localparam CMD_WRITE                   = 32'h4;

    /// - State Transition

    always @(*)
    begin
        if (resetn==1'b0)
            next_state <= STATE_WAIT_FOR_CMD;
        else
        begin
            case (r_state)
                STATE_WAIT_FOR_CMD:
                    begin
                        if (arm_to_fpga_cmd_valid) begin
                            case (arm_to_fpga_cmd)
                                CMD_READ_Cipher:
                                    next_state <= STATE_READ_DATA_Cipher;
                                CMD_READ_pdp:
                                    next_state <= STATE_READ_DATA_pdp; 
                                CMD_READ_R2pRp:
                                    next_state <= STATE_READ_DATA_R2pRp;
                                CMD_COMPUTE:                            
                                    next_state <= STATE_COMPUTE;
                                CMD_WRITE: 
                                    next_state <= STATE_WRITE_DATA;
                                default:
                                    next_state <= r_state;
                            endcase
                        end else
                            next_state <= r_state;
                    end

                STATE_READ_DATA_Cipher:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;

                STATE_READ_DATA_pdp:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;

                STATE_READ_DATA_R2pRp:
                        next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;
                STATE_COMPUTE: 
                    next_state <= STATE_COMPUTE_WAIT;
                STATE_COMPUTE_WAIT:
                    if(RSA_done) next_state <= STATE_ASSERT_DONE ;
                    else next_state <= STATE_COMPUTE_WAIT;                    

                STATE_WRITE_DATA:
                    next_state <= (fpga_to_arm_data_ready) ? STATE_ASSERT_DONE : r_state;

                STATE_ASSERT_DONE:
                    next_state <= (fpga_to_arm_done_read) ? STATE_WAIT_FOR_CMD : r_state;

                default:
                    next_state <= STATE_WAIT_FOR_CMD;

            endcase
        end
    end

    /// - Synchronous State Update

    always @(posedge(clk))
        if (resetn==1'b0)
            r_state <= STATE_WAIT_FOR_CMD;
        else
            r_state <= next_state;   

    ////////////// - Computation



    //reg [TX_SIZE-1:0] core_data;
        
    reg[1023:0] Cipher;
    reg [1023:0]pdp,R2pRp;
    assign p = pdp[1023:512];
    assign dp = pdp[511:0];
    assign RSA_Cipher = Cipher;
    assign R2p = R2pRp[1023:512];
    assign Rp = R2pRp[511:0];
    
    always @(posedge(clk)) begin
        if (resetn==1'b0) begin
            //core_data <= 'b0;
            Cipher <=1;
            pdp <=0;
            R2pRp <=0;
            RSA_start <= 0;
        end
        else begin
            case (r_state)
                STATE_READ_DATA_Cipher: begin
                    if (arm_to_fpga_data_valid) Cipher <= arm_to_fpga_data[1023:0];
                    else                        Cipher <= Cipher; 
                end
                
                STATE_READ_DATA_pdp: begin
                    if (arm_to_fpga_data_valid) pdp <= arm_to_fpga_data;
                    else                        pdp <= pdp; 
                end
                
                STATE_READ_DATA_R2pRp: begin
                    if (arm_to_fpga_data_valid) R2pRp <= arm_to_fpga_data;
                    else                        R2pRp <= R2pRp; 
                end
                
                STATE_COMPUTE: begin
                    // Bitwise-XOR the most signficant 32-bits with 0xDEADBEEF
                    //core_data <= {core_data[TX_SIZE-1:TX_SIZE-32]^32'hDEADBEEF, core_data[TX_SIZE-33:0]};
                    RSA_start <= 1'b1;
                end
                
                default: begin
                Cipher <=Cipher;
                pdp <=pdp;
                R2pRp <=R2pRp;
                RSA_start <= RSA_start;
                end
                
            endcase
        end
    end
    
    assign fpga_to_arm_data[1023:512]       = RSA_result;

    ////////////// - Valid signals for notifying that the computation is done

    /// - Port handshake

    reg r_fpga_to_arm_data_valid;
    reg r_arm_to_fpga_data_ready;

    always @(posedge(clk)) begin
        r_fpga_to_arm_data_valid = (r_state==STATE_WRITE_DATA);
        r_arm_to_fpga_data_ready = (r_state==STATE_READ_DATA_Cipher) | (r_state==STATE_READ_DATA_pdp) | (r_state==STATE_READ_DATA_R2pRp) ;
    end
    
    assign fpga_to_arm_data_valid = r_fpga_to_arm_data_valid;
    assign arm_to_fpga_data_ready = r_arm_to_fpga_data_ready;
    
    /// - Done signal
    
    reg r_fpga_to_arm_done;

    always @(posedge(clk))
    begin        
        r_fpga_to_arm_done <= (r_state==STATE_ASSERT_DONE);
    end

    assign fpga_to_arm_done = r_fpga_to_arm_done;
    
    ////////////// - Debugging signals
    
    // The four LEDs on the board can be used as debug signals.
    // Here they are used to check the state transition.

    assign leds             = {r_state,RSA_done};

endmodule




