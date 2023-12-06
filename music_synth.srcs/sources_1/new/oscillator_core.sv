module oscillator_core(input logic Clk,
                       input logic Reset,
                       input logic [1:0] osc_waveform_sel,
                       input logic mux_bypass,
                       input logic gate_tvalid,
                       input logic [21:0] frequency_word_osc,
                       output logic [15:0] osc_out);
                       
    localparam int ACCUMULATOR_BITS = 22;
    localparam int OUTPUT_BITS = 16;
    localparam int FREQ_WORD_BITS = 22;
    logic [OUTPUT_BITS-1:0] dout;            
    logic [ACCUMULATOR_BITS-1:0] accumulator;                
    logic [15:0] sine_out, tri_out, saw_out, sq_out;
    logic sq_o_tmp;
    logic [15:0] output_last;
    logic sine_cos_lut_valid, tune_valid_dds, saw_valid;
    logic [15:0] other_tri;
    logic osc_441;
    logic [21:0] frequency_word_saw,  temp_freq_word;
    logic Clk_5MHz;
    assign frequency_word_saw = frequency_word_osc >> 6;
    assign temp_freq_word = frequency_word_osc >> 10; //explicitly dividing frequency word by 2268 is too slow. use 2048 as an approximation
    //lutsine produces output frequency of half the desired amount. decreased bitwidth of phase accumulator by 1 -> effectively multiplying by 2
   
    Clock_divider2 osc_441_clk(.clock_in(Clk), 
                              .clock_out(osc_441),
                              .en_441(1'b1),
                              .Reset,
                              .frequency_word(22'b0));
                              
    LUTsine lutsine_osc(.Clk(osc_441), //.LUT_Clk(Clk), 
                        .tune_in_dds(frequency_word_osc), 
                        .tune_valid_dds(gate_tvalid), //tie to 1 for test
                        .sine_cos_out(sine_out), 
                        .sine_cos_lut_valid(sine_cos_lut_valid));
                        
    //FREQUENCY WORD MUST BE ASSERTED BEFORE TVALID!!!! VERY IMPORTANT                   
    saw_generator saw_gen_osc(.Clk(osc_441), 
                              .tune_in_dds(frequency_word_saw), //sawtooth 2x freq of sine so i divide it by 64 (was 32)
                              .tune_valid_dds(gate_tvalid), //tie to 1 for test
                              .saw_out(saw_out),
                              .saw_valid(saw_valid)); 
                              
    //still works because of parametric divisor calculation
    //actually no it doesnt, have to change parametric calculation bc
    //sine sample clock is lower. so the frequency of the square wave
    //will be greater than that of the sine or sawtooths for the same
    //frequency word.                       

    //try clocking @ 44.1                              
    //TriangleWaveGenerator tgosc(.Clk(osc_441), .Reset(Reset), .tuning_word(frequency_word_osc), .triangle(tri_out));
    
    tone_generator_triangle #(.ACCUMULATOR_BITS(ACCUMULATOR_BITS), .OUTPUT_BITS(OUTPUT_BITS)) 
                            real_tg_osc(.accumulator(accumulator),
                                          .dout(tri_out),
                                          .en_ringmod(1'b0),
                                          .ringmod_source(1'b0));

    sine2square s2s_osc(.sine_in(sine_out), .sq_out(sq_out));                        
    
    always_ff @ (posedge Clk) begin
        if(Reset) begin
            output_last <= 16'b0;
            accumulator <= 0;
        end
        else begin
            output_last <= osc_out;
            accumulator <= accumulator + temp_freq_word ;
        end
    end
    //add gate logic here. we should
    always_comb begin: output_mux
        if(gate_tvalid) begin
            if(mux_bypass == 1'b0) begin
                unique case(osc_waveform_sel)
                    2'b00: osc_out = sine_out;
                    2'b01: osc_out = tri_out;
                    2'b10: osc_out = saw_out;
                    2'b11: osc_out = sq_out;
                endcase
            end
            else begin
                osc_out = output_last;
            end
       end else begin
            osc_out = 16'b0;
       end     
    end
    /*
    fo = P*fclk / (2 ^ N bits in P)
    P is phase increment
    so required P = fout * (2^N) / fclk
    */    
endmodule