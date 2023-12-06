module low_freq_osc(input logic Clk,
                    input logic Reset,
                    input logic [1:0] lfo_waveform_sel,
                    input logic mux_bypass,
                    input logic gate_tvalid,
                    input logic [21:0] frequency_word_lfo,
                    output logic [15:0] lfo_out);
                    
    localparam int ACCUMULATOR_BITS = 22;
    localparam int OUTPUT_BITS = 16;
    localparam int FREQ_WORD_BITS = 22;      
    logic [OUTPUT_BITS-1:0] dout;            
    logic [ACCUMULATOR_BITS-1:0] accumulator;          
    logic [15:0] sine_out, tri_out, saw_out, sq_out;
    logic [15:0] output_last;
    logic sine_cos_lut_valid, tune_valid_dds, saw_valid;
    logic [15:0] other_tri;
    logic sq_o_tmp;
    logic lfo_441;
    logic Clk_5MHz;
    logic [21:0] frequency_word_saw, temp_freq_word;
    assign frequency_word_saw = frequency_word_lfo >> 6;
    assign temp_freq_word = frequency_word_lfo >> 10;
    //lutsine produces output frequency of half the desired amount. decreased bitwidth of phase accumulator by 1 -> effectively multiplying by 2
    
    Clock_divider2 lfo_441_clk(.clock_in(Clk), 
                              .clock_out(lfo_441),
                              .en_441(1'b1),
                              .Reset,
                              .frequency_word(22'b0));
    
//    LUTsine lutsine_lfo(.Clk(lfo_441), //.LUT_Clk(Clk), 
//                        .tune_in_dds(frequency_word_lfo), 
//                        .tune_valid_dds(gate_tvalid), //tie to 1 for test
//                        .sine_cos_out(sine_out), 
//                        .sine_cos_lut_valid(sine_cos_lut_valid));
                        
    lfo_mod_sine mod_sine_lfo(.Clk(lfo_441), 
                              .m_axis_data_tdata(sine_out), 
                              .m_axis_data_tvalid(sine_cos_lut_valid), 
                              .s_axis_config_tdata(frequency_word_lfo), 
                              .s_axis_config_tvalid(gate_tvalid)); 
                                                     
    //FREQUENCY WORD MUST BE ASSERTED BEFORE TVALID!!!! VERY IMPORTANT                     
    saw_generator saw_gen_lfo(.Clk(lfo_441), 
                              .tune_in_dds(frequency_word_saw), // 64 gets the periods of sawtooth to match those of square/sine
                              .tune_valid_dds(gate_tvalid),        // /64 = /(2**6) so I could just reduce the phase accumulator to 16 bits
                              .saw_out(saw_out),                   // but that might break the frequency word stuff
                              .saw_valid(saw_valid));

    sine2square s2s_lfo(.sine_in(sine_out), .sq_out(sq_out));
    
    //TriangleWaveGenerator tglfo(.Clk(lfo_441), .Reset(Reset), .tuning_word(frequency_word_lfo), .triangle(tri_out));
    
    tone_generator_triangle #(.ACCUMULATOR_BITS(ACCUMULATOR_BITS), .OUTPUT_BITS(OUTPUT_BITS)) 
                            real_tg_lfo(.accumulator(accumulator),
                                          .dout(tri_out),
                                          .en_ringmod(1'b0),
                                          .ringmod_source(1'b0));

    //sine2square s2s_osc(.sine_in(sine_out), .sq_out(sq_out));                        
    
    always_ff @ (posedge Clk) begin
        if(Reset) begin
            output_last <= 16'b0;
            accumulator <= 0;
        end
        else begin
            output_last <= lfo_out;
            accumulator <= accumulator + temp_freq_word ;
        end
    end
    
    always_comb begin: output_mux
        if(gate_tvalid) begin
            if(mux_bypass == 1'b0) begin
                case(lfo_waveform_sel)
                    2'b00: lfo_out = sine_out;
                    2'b01: lfo_out = tri_out; 
                    2'b10: lfo_out = saw_out;
                    2'b11: lfo_out = sq_out;
                endcase
            end
            else begin
                lfo_out = output_last;
            end
       end else begin
            lfo_out = 16'b0;
       end     
    end
    /*
    fo = P*fclk / (2 ^ N bits in P)
    P is phase increment
    so required P = fout * (2^N) / fclk
    */    
endmodule

