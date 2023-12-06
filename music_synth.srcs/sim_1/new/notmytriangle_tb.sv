module notmytriangle_tb();

    timeunit 1ns;
    timeprecision 1ns;
        
    localparam int ACCUMULATOR_BITS = 22;
    localparam int OUTPUT_BITS = 16;
    localparam int FREQ_WORD_BITS = 22;
    real expected_frequency;
    logic Clk;
    logic Reset;
    logic Clk_441;
    logic en_ringmod;   
    logic ringmod_source;
    logic [FREQ_WORD_BITS - 1:0] frequency_word;
    logic [OUTPUT_BITS-1:0] dout;            
    logic [ACCUMULATOR_BITS-1:0] accumulator;
    logic pdm_out;
    logic [1:0] SW_S_osc;
    logic [15:0] sine_out;    
    logic sine_cos_lut_valid;
    logic gate_tvalid;
    
    Clock_divider2 osc_441_tg(.clock_in(Clk), 
                              .clock_out(Clk_441),
                              .en_441(1'b1),
                              .Reset,
                              .frequency_word(22'b0));
                                  
    tone_generator_triangle #(.ACCUMULATOR_BITS(ACCUMULATOR_BITS), .OUTPUT_BITS(OUTPUT_BITS)) 
                            u_tg_tri_test(.accumulator(accumulator),
                                          .dout(dout),
                                          .en_ringmod(en_ringmod),
                                          .ringmod_source(ringmod_source));

    lfo_mod_sine mod_sine_lfo(.Clk(Clk_441), 
                              .m_axis_data_tdata(sine_out), 
                              .m_axis_data_tvalid(sine_cos_lut_valid), 
                              .s_axis_config_tdata(frequency_word), 
                              .s_axis_config_tvalid(gate_tvalid)); 
                              
    pdm_dac pdm_dac_test(.clk(Clk), .Reset(Reset), .din(sine_out), .dout(pdm_out), .waveform_sel(SW_S_osc));                                          
    
    always_ff @(posedge Clk) begin
        if(Reset) begin
            accumulator <= 0;
        end else begin
            accumulator <= accumulator + (frequency_word / 12'h8dc) ;
        end
    end
                                                           
    always begin: CLOCK_GENERATION
        #5 Clk = ~Clk;
    end
    
    initial begin: CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin: TEST_VECTORS
        Reset = 1;
        frequency_word = 22'hFFFF;
        SW_S_osc = 0;
        expected_frequency = frequency_word * (100*10**6) / (2**22);
        en_ringmod = 0;
        ringmod_source = 0;
        #100
        gate_tvalid = 1;
        Reset = 0;
    end    
endmodule
