module testbench();

    timeunit 1ns;
    timeprecision 1ns;
    
    logic Clk;
    logic Reset;
    logic [1:0] lfo_waveform_sel;
    logic mux_bypass;
    logic gate_tvalid; //gate_tvalid
    logic [21:0] frequency_word_lfo; //frequency_word
    logic [15:0] lfo_out, osc_out;
    logic [1:0] osc_waveform_sel;
    logic [21:0] frequency_word_osc;
    
    //internal signals within lfo module
    logic [15:0] sine_out_osc, sine_out_lfo;
    logic [15:0] saw_out_osc, saw_out_lfo; 
    logic [15:0] sq_out_osc, sq_out_lfo;
    assign sine_out_lfo = lfo_test.sine_out;
    assign sq_out_lfo = lfo_test.sq_out;
    assign saw_out_lfo = lfo_test.saw_out;
    assign sine_out_osc = osc_c.sine_out;
    assign sq_out_osc = osc_c.sq_out;
    assign saw_out_osc = osc_c.saw_out;
    logic [15:0] tri_out;
    logic [15:0] output_last_lfo;
    logic [15:0] output_last_osc;
    assign output_last_lfo = lfo_test.output_last;   
    assign output_last_osc = osc_c.output_last;   
    logic sine_cos_lut_valid;
    logic saw_valid;
    logic [21:0] sq_count;
    logic [15:0] int_sq_out;
    logic [15:0] other_tri;
    logic pwm_out;
    logic [23:0] saw_out_opt;
    logic [15:0] sine_in;
    logic PWM_Out;
    logic pwm2;
    logic pwm_var;
    logic clk_100k;
    logic [31:0] sig_sum;
    logic [7:0] keycode1_gpio, keycode0_gpio;
    int actual_output_freq;
    int nom_clk_freq = 100000000;
    int num_bits = 22;
    logic [15:0] pwm_i;
    logic pwm_o;
    assign pwm_i = osc_out; //just assigning input to pwm
//    ClockDivider cd(.clk(clk), .rst(Reset), .divisor('d1000), .clk_out(clk_100k));
    low_freq_osc lfo_test(.Clk(Clk),
                          .Reset(Reset), 
                          .lfo_waveform_sel(lfo_waveform_sel), 
                          .mux_bypass(mux_bypass),
                          .gate_tvalid(gate_tvalid),
                          .frequency_word_lfo(frequency_word_lfo),
                          .lfo_out(lfo_out));

    oscillator_core osc_c(.Clk(Clk),
                          .Reset(Reset), 
                          .osc_waveform_sel(osc_waveform_sel), 
                          .mux_bypass(mux_bypass),
                          .gate_tvalid(gate_tvalid),
                          .frequency_word_osc(frequency_word_osc),
                          .osc_out(osc_out));
                          
     pwm #(.BITS(16)) testpwm(.clk(Clk), 
                                           .rst(Reset), 
                                           .dty(pwm_i), //assigned filter output to duty cycle control
                                           .pwm(pwm_o));   
    //music_synth_top whole_thang();
    always begin: CLOCK_GENERATION
        #5 Clk = ~Clk;
    end
    
    initial begin: CLOCK_INITIALIZATION
        Clk = 0;
    end
    
    initial begin: TEST_VECTORS
    Reset = 1;
    mux_bypass = 0;
    osc_waveform_sel = 0; //square
    lfo_waveform_sel = 0; //sine
    gate_tvalid = 0;    
    #1000 //hold reset for 100 clocks
    Reset = 0; //release reset
    frequency_word_lfo = 22'hFFFF;
    frequency_word_osc = 22'hFFFF;
    #10
    gate_tvalid = 1; //assert AFTER frequency word.
//    #100 
//    gate_tvalid = 1;
    #5000000
    lfo_waveform_sel = 1;
    osc_waveform_sel = 1;
    #5000000
    lfo_waveform_sel = 2;
    osc_waveform_sel = 2;
    #5000000
    frequency_word_lfo = 22'h1FFF;
    frequency_word_osc = 22'h1FFF;
    lfo_waveform_sel = 3;
    osc_waveform_sel = 3;
    #5000000
    frequency_word_lfo = 22'hFFFF;
    frequency_word_osc = 22'hFFFF;
    //#5000000
    //$stop;
    end
//    #5000
//    mux_bypass = 1;    
endmodule
