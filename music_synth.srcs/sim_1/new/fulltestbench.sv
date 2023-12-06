module fulltestbench();

    timeunit 1ns;
    timeprecision 1ns;
    //general signals
    logic Clk;
    logic Reset;
    //keymapper signals
    logic [1:0] waveform_sel; //for oscs            
    logic S_but_filt_sel_up, S_but_filt_sel_dn;
    logic [7:0] keycode0_gpio, keycode1_gpio;    
    logic [5:0] filter_sel;
    logic filter_sel_en;
    logic gate_tvalid; //for oscs
    logic [21:0] frequency_word; //for oscs           
    //pwm signals
    //clk(Clk)
    //rst(Reset)
    //dty()
    logic [15:0] dty;
    //pwm()
    logic pwm_lfo, pwm_osc;
    //lfo signals
    logic [15:0] lfo_out;
    //logic [21:0] frequency_word_lfo;
    logic mux_bypass;
    assign mux_bypass = 0;
    //osc signals
    logic [15:0] osc_out;
    //fir signals
    logic SW_filt_bp_S;
    logic [15:0] data_in;
    logic [15:0] data_out;
    assign data_in = osc_out; //filter gets osc for this
    oscillator_core core_full_test(
                                   .Clk(Clk), //i
                                   .Reset(Reset), //i
                                   .osc_waveform_sel(waveform_sel), //i
                                   .mux_bypass(mux_bypass), //i
                                   .gate_tvalid(gate_tvalid), //i
                                   .frequency_word_osc(frequency_word),//i
                                   .osc_out(osc_out) //o
                                   );
    
    low_freq_osc lfo_full_test(
                               .Clk(Clk), //i
                               .Reset(Reset), //i
                               .lfo_waveform_sel(waveform_sel), //i
                               .mux_bypass(mux_bypass), //i
                               .gate_tvalid(gate_tvalid), //i
                               .frequency_word_lfo(frequency_word), //i
                               .lfo_out(lfo_out) //o
                               );
                             
    pwm pwm_full_test_filt(
                          .clk(Clk), //i
                          .rst(Reset), //i
                          .dty(data_out), //i //filt_out
                          .pwm(pwm_lfo) //o
                          );
                          
    pwm pwm_full_test_osc(
                         .clk(Clk), //i
                         .rst(Reset), //i
                         .dty(osc_out), //i
                         .pwm(pwm_osc) //o
                         );  
    
    lowpass_FIR fir_full_test(
                              .Clk(Clk), //i
                              .Reset(Reset), //i
                              .filter_bypass(SW_filt_bp_S), //i
                              .filter_sel_en(filter_sel_en), //i
                              .filter_sel(filter_sel), //i
                              .data_in(data_in), //i
                              .data_out(data_out) //o
                              );
                              
    keymapper km_full_test(.Clk(Clk), //i
                           .Reset(Reset), //i
                           .keycode0_gpio(keycode0_gpio), //i
                           .keycode1_gpio(keycode1_gpio), //i
                           .S_but_filt_sel_up(S_but_filt_sel_up), //i
                           .S_but_filt_sel_dn(S_but_filt_sel_dn), //i
                           .filter_sel(filter_sel), //o
                           .filter_sel_en(filter_sel_en), //o
                           .gate_tvalid(gate_tvalid), //o
                           .frequency_word(frequency_word)//o
                           );                              
    
    int C4  = 4'd4;
    int Cs4 = 5'd22;
    int D4  = 3'd7;
    int Ds4 = 4'd9;
    int E4  = 4'd10;
    int F4  = 4'd11;
    int Fs4 = 4'd13;
    int G4  = 4'd14;
    int Gs4 = 4'd15;
    int A4  = 6'd51;
    int As4 = 6'd52;
    int HF  = 5'd29;
    int space = 'd44;
 
//    int filt_minus = 10'd45;
//    int filt_plus = 10'd46;
//    int filt_bp = 'd47;
        
    always begin: CLOCK_GENERATION
        #10 Clk = ~Clk;
    end                                                                                           //C4 = 4'd4;           
                                                                                                  //Cs4 = 5'd22;         
    initial begin: CLOCK_INITIALIZATION                                                           //D4 = 3'd7;           
        Clk = 0;                                                                                  //Ds4 = 4'd9;          
    end                                                                                           //E4 = 4'd10;          
                                                                                                  //F4 = 4'd11;          
    initial begin: TEST_VECTORS                                                                   //Fs4 = 4'd13;         
    Reset = 1;
    waveform_sel = 2'b00;                                                                                    //G4 = 4'd14;          
    keycode0_gpio = 8'b0;                                                                         //Gs4 = 4'd15;         
    SW_filt_bp_S = 1; //keep filt bypassed at first                                               //A4 = 6'd51;          
    keycode1_gpio = 8'b0;
    S_but_filt_sel_dn = 0;
    S_but_filt_sel_up = 0;                                                                        //As4 = 6'd52;         
    #100                                                                                          //HF = 5'd29;          
    Reset = 0;
    #100
    //keycode0_gpio = lshift;
//    #10000
//    keycode0_gpio = Cs4;
//    #10000
//    keycode0_gpio = D4;
//    #10000 
//    keycode0_gpio = Ds4;
//    #10000
//    keycode0_gpio = E4;
//    #10000 
//    keycode0_gpio = F4;
//    #10000 
//    keycode0_gpio = Fs4;
//    #10000
//    keycode0_gpio = G4;
//    #10000 
//    keycode0_gpio = Gs4;
//    #10000
//    keycode0_gpio = A4;
//    #10000 
//    keycode0_gpio = As4;
//    #10000
//    keycode0_gpio = HF;
//    #10000
//    keycode0_gpio = 8'h0;
    SW_filt_bp_S = 0;
    #1000
    S_but_filt_sel_up = 1;                                                                                 //filt_minus = 10'd45; 
    #1000
    S_but_filt_sel_up = 0;
    #150
    S_but_filt_sel_up = 1;
    #50
    S_but_filt_sel_up = 0;
    #50
    S_but_filt_sel_up = 1;
    #100
    S_but_filt_sel_up = 0;               
    #1000
    S_but_filt_sel_up = 1;                                                                                 //filt_minus = 10'd45; 
    #1000
    S_but_filt_sel_up = 0;
    #1000
    S_but_filt_sel_up = 1;                                                                                 //filt_minus = 10'd45; 
    #1000
    S_but_filt_sel_up = 0;
//    #1000
//    S_but_filt_sel_dn = 1;                                                                                 //filt_minus = 10'd45; 
//    #1000
//    S_but_filt_sel_dn = 0;
//    #1000
//    S_but_filt_sel_dn = 1;                                                                                 //filt_minus = 10'd45; 
//    #1000
//    S_but_filt_sel_dn = 0;
//    #1000
//    S_but_filt_sel_dn = 1;                                                                                 //filt_minus = 10'd45; 
//    #1000
//    S_but_filt_sel_dn = 0;
//    #1000
//    S_but_filt_sel_dn = 1;                                                                                 //filt_minus = 10'd45; 
//    #1000
//    S_but_filt_sel_dn = 0;                    
    #1
    keycode0_gpio = space;
    #1000
    SW_filt_bp_S = 1;
    #1000
    SW_filt_bp_S = 0;
    #1000
    S_but_filt_sel_dn = 0;
    #10
    S_but_filt_sel_dn = 1;                                                                                 //filt_minus = 10'd45; 
    #10
    S_but_filt_sel_dn = 0;
    #10000
    S_but_filt_sel_dn = 1;                                                                                 //filt_minus = 10'd45; 
    #10
    S_but_filt_sel_dn = 0;
    #10000
    S_but_filt_sel_dn = 1;                                                                                 //filt_minus = 10'd45; 
    #10
    S_but_filt_sel_dn = 0;                    
    end    
endmodule
