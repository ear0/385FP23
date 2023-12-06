module triWave_tb();
    
    timeunit 1ns;
    timeprecision 1ns;
    
    logic Clk;
    logic Reset;
    logic Clk_441;
    logic [21:0] frequency_word, tuning_word;
    //logic [21:0] frequency_word_saw;
    //logic gate_tvalid;
    logic [15:0] saw_out, tri_out, twave;
    logic ns_clk_out;
    //logic saw_valid;

    Clock_divider2 u_cd2_tri_test(.clock_in(Clk), .clock_out(Clk_441), .en_441(1'b1), .Reset(Reset));
    
    test_TriangleWaveGenerator u_triangle_test(.Clk(Clk), .Reset(Reset), .tuning_word(frequency_word), .triangle(tri_out));
    
    tri_plz tp(.clk(Clk_441), .rst(Reset), .tuning_word(frequency_word), .triangle_wave(twave));
    
    nonsynth_clockdivider nsd(.clock_in(Clk), .clock_out(ns_clk_out), .en_441(1'b0), .Reset(Reset), .frequency_word(frequency_word));
                                                       
    always begin: CLOCK_GENERATION
        #5 Clk = ~Clk;
    end
    
    initial begin: CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin: TEST_VECTORS
        Reset = 1;
        //gate_tvalid = 1;
        frequency_word = 'h1FFFF;
        #50
        Reset = 0;
//        #1000000
//        frequency_word = 'h0FFF;
    end
    

endmodule

module nonsynth_clockdivider #(parameter int NOM_DIVISOR = 2268, parameter int FIVEMEG_DIVISOR = 113 )
                    (input logic clock_in,
                     input logic en_441,
                     input logic Reset,
                     output logic clock_out,
                     input logic [21:0] frequency_word
                            );
                          
    logic [27:0] counter; 
    int clk_in_freq = 100_000_000.0;          //divisor wont update properly if i dont use real???? 
    //real clk_ratio = clk_in_freq / (44100.0);  //divisor wont update properly if i dont use real????
    real div_ratio_use = 2268.0;     //hardcode to 2268 if u clock at 100MHz
    real  lol_2_to_the_22_haha = 4194304.0; //this has to be a real in every case - divisor is wrong if its an int
    logic [31:0] DIVISOR; //used to be clk_in_freq / freq
    
    //fclk for this is 2268x the sample clock for the DDS generators. so we could divide by 2268 to normalize
    
    always_comb begin
    //always_comb begin
        if(en_441) begin
            DIVISOR = 'd2268;
        end else begin
            DIVISOR = (div_ratio_use * (lol_2_to_the_22_haha)) / frequency_word;     
        end
    end
    
    always_ff @(posedge clock_in)
    begin
        if(Reset) begin
            counter <= 0;
        end else begin
            counter <= counter + 28'd1;
            if(counter>=(DIVISOR-1))
                counter <= 28'd0;
                clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
        end        
    end
    
endmodule

