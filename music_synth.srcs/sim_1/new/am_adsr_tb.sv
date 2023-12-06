module am_adsr_tb();
    
    timeunit 1ns;
    timeprecision 1ns;
    
    localparam int DATA_BITS = 16;
    logic Clk;
    //logic Clk_441;
    //AM message
    logic Reset;
    logic clk_441;
    logic [21:0] frequency_word_message;
    logic gate_tvalid;
    logic [15:0] sine_out;
    //logic sine_cos_lut_valid;
    
    //AM "carrier"
    logic [15:0] carrier_out;
    logic [21:0] frequency_word_carrier;
    
    //modulator
    logic [DATA_BITS - 1:0] AM_data_out;
    
    //adsr
    logic [3:0] a, d, s, r;
    logic [7:0] amplitude;
    
    Clock_divider2 osc_441_AM(.clock_in(Clk), 
                              .clock_out(clk_441),
                              .en_441(1'b1),
                              .Reset,
                              .frequency_word(22'b0));
                                   
    LUTsine lutsine_AM_message(.Clk(clk_441), 
                               .tune_in_dds(frequency_word_message), 
                               .tune_valid_dds(gate_tvalid), 
                               .sine_cos_out(sine_out), 
                               .sine_cos_lut_valid());

    LUTsine lutsine_AM_carrier(.Clk(clk_441), 
                               .tune_in_dds(frequency_word_carrier), 
                               .tune_valid_dds(gate_tvalid), 
                               .sine_cos_out(carrier_out), 
                               .sine_cos_lut_valid());
    
    ADSR_gen u_adsr_test(.Clk(clk_441), .Reset(Reset), .gate_tvalid(gate_tvalid), .a, .d, .s, .r, .amplitude);
                                   
    AM_mod #(.DATA_BITS(DATA_BITS)) u_am_modulator_test 
                              (.Clk(clk_441), 
                               .Reset(Reset), 
                               .amplitude(amplitude), 
                               .AM_data_in(sine_out), 
                               .AM_data_out(AM_data_out));                               
                                                           
    always begin: CLOCK_GENERATION
        #5 Clk = ~Clk;
    end
    
    initial begin: CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin: TEST_VECTORS
        Reset = 1;
        frequency_word_message = 22'hFFFF; //690 hz
        frequency_word_carrier = 22'h1FFFF; //1380 hz (2*690 hz)
        a = 0;
        d = 0;
        s = 0;
        r = 0;
        gate_tvalid = 0;
        #2268
        Reset = 0;
        #10 
        gate_tvalid = 1;
        #1000000
        a = 1;
        d = 1;
        s = 1;
        r = 1;
        #1000000
        gate_tvalid = 0;
    end
    
    
endmodule
